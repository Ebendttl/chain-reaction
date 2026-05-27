# 🏗️ ChainReaction — Architecture

## System Overview

ChainReaction is a three-layer system: **decentralized inference** for the robot's brain, **on-chain gating** for behavior authorization, and **decentralized storage** for the behavior library.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            USER                                          │
│                    speaks into robot mic                                 │
└──────────────────────────┬──────────────────────────────────────────────┘
                           │ WebRTC audio stream (from robot or sim)
                           ▼
╔══════════════════════════════════════════════════════════════════════════╗
║  0G COMPUTE — Whisper STT                                               ║
║  Host: compute-network-16.integratenetwork.work                         ║
║  Key:  OG_STT_KEY  (app-sk-... for whisper provider)                   ║
║  Input:  WebM/opus blob → decoded to WAV via Web Audio API              ║
║  Output: transcript text string                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
                           │ "Do the happy dance"
                           ▼
╔══════════════════════════════════════════════════════════════════════════╗
║  0G COMPUTE — LLM (GLM-5-FP8 or DeepSeek)                             ║
║  Host: compute-network-1.integratenetwork.work                          ║
║  Key:  OG_CHAT_KEY  (app-sk-... for chat provider)                     ║
║  System prompt instructs the model to output structured JSON:           ║
║  { "reply": "...", "behavior": "dance", "requires_payment": true }      ║
╚══════════════════════════════════════════════════════════════════════════╝
                           │ parsed JSON response
              ┌────────────┴──────────────┐
              │ requires_payment: false    │ requires_payment: true
              ▼                            ▼
╔═════════════════════════╗  ╔══════════════════════════════════════════╗
║  0G STORAGE             ║  ║  0G CHAIN — BehaviorGate.sol            ║
║  Behavior library JSON  ║  ║  Network: 0G Chain Testnet (16600)      ║
║  Fetch behavior params  ║  ║  isUnlocked(walletAddr, behaviorKey)?   ║
║  by key from root hash  ║  ║  → false: show payment modal            ║
╚═══════════════╤═════════╝  ║  → true: proceed                        ║
                │            ║  unlock(behaviorKey){value: price}      ║
                │            ║  → emit BehaviorUnlocked(tx hash)       ║
                │            ╚════════════════╤═════════════════════════╝
                └────────────────────────────┘
                           │ behavior JSON + authorization confirmed
                           ▼
╔══════════════════════════════════════════════════════════════════════════╗
║  REACHY MINI — WebRTC JS SDK  (Path A / Static HF Space)               ║
║  robot.setHeadRpyDeg()  robot.setAntennasDeg()  robot.wakeUp()         ║
║  Web Speech API TTS: reads reply through robot speaker                  ║
║  UI: shows tx hash "✅ Verified on 0G Chain: 0x1a2b..."                ║
╚══════════════════════════════════════════════════════════════════════════╝
```

---

## Component Breakdown

### 1. Voice Capture — WebRTC Audio Track

The Reachy Mini streams audio from its onboard mic via the WebRTC peer connection.
**We never call `getUserMedia()`** — we capture the incoming robot audio track:

```js
const remoteVideo = document.getElementById('remoteVideo');
const robotAudio = remoteVideo?.srcObject?.getAudioTracks?.() || [];
const stream = robotAudio.length
  ? new MediaStream(robotAudio)
  : await navigator.mediaDevices.getUserMedia({ audio: true }); // sim fallback
```

### 2. STT — 0G Compute Whisper

The browser cannot send WebM/opus directly — 0G Whisper rejects it.
We decode and re-encode to PCM WAV using the Web Audio API before POSTing.

**Endpoint:** `https://compute-network-16.integratenetwork.work/v1/proxy/audio/transcriptions`
**Key:** `OG_STT_KEY` — separate from chat key. Wrong key = `400 missing or invalid Authorization header`.

### 3. LLM Intent Parsing — 0G Compute

The system prompt instructs the model to return a **single JSON object**, never plain text:

```
You are Reachy, an expressive desk robot powered by 0G decentralized compute.
Always respond with ONLY a valid JSON object (no markdown, no code fences):
{
  "reply": "<natural language reply, max 2 sentences>",
  "behavior": "<one of: wave|nod|shake|dance|fortune|backflip|sleep|wake|null>",
  "requires_payment": <true if the behavior is premium, else false>
}
Premium behaviors: dance, fortune, backflip.
Free behaviors: wave, nod, shake, sleep, wake.
```

We `JSON.parse()` the response and route accordingly.

### 4. BehaviorGate Contract — 0G Chain

Deployed on 0G Chain Testnet (chainId: 16600).
EVM-compatible — MetaMask connects to it natively.

**Key functions:**
- `isUnlocked(address user, string key) → bool` — view call, free
- `unlock(string key) payable` — pays to unlock, emits `BehaviorUnlocked` event
- `behaviorPrice(string key) → uint256` — price in wei
- `checkBatch(address, string[]) → bool[]` — batch check for UI init

**Flow:**
1. On wallet connect → call `checkBatch()` for all known behavior keys → cache results
2. When LLM returns `requires_payment: true` → check cache → if locked, show payment modal
3. User approves MetaMask tx → `unlock()` called → wait for confirmation
4. Show tx hash in UI: `"✅ Verified on 0G Chain: 0xABC..."`
5. Execute behavior on robot

### 5. Behavior Library — 0G Storage

`behaviors.json` is uploaded to 0G Storage at setup time.
At runtime, the app fetches behavior parameters (animation sequences, TTS strings) by key.

This means behaviors are:
- **Decentralized** — not hardcoded in the app
- **Community-ownable** — anyone can publish a behavior set to a different root hash
- **Immutable** — the root hash is content-addressed; it can't be tampered with

### 6. Reachy Mini — JS SDK (Path A)

We use the **JS/WebRTC path** (Path A) as recommended by Pollen's AGENTS.md.

- App is a single `index.html` — zero build step
- Hosted as a **Static HF Space** — required for OAuth + "Install to Robot"
- Robot auto-discovered via relay when on venue Wi-Fi
- `sim.js` provides an in-browser 3D sim for development

---

## Data Flow Sequence

```
User speaks
  → MediaRecorder captures WebRTC audio → webmBlobToWav() → transcribe() [0G Compute]
  → transcript → askAI() with structured JSON prompt [0G Compute]
  → parse JSON: {reply, behavior, requires_payment}
  → if requires_payment:
      → checkBatch() on BehaviorGate [0G Chain] (cached)
      → if locked: show PayModal → user approves MetaMask → unlock() [0G Chain]
      → await tx.wait() → show tx hash in Chain Feed panel
  → fetchBehavior(key) [0G Storage] → get animation sequence
  → executeBehavior(sequence) on robot [Reachy Mini SDK]
  → TTS reply through robot speaker [Web Speech API]
```

---

## Configuration Variables

| Variable | Where to get it | Used by |
|---|---|---|
| `OG_CHAT_KEY` | `0g-compute-cli inference get-secret --provider <CHAT_ADDR>` | LLM inference |
| `OG_STT_KEY` | `0g-compute-cli inference get-secret --provider <WHISPER_ADDR>` | Whisper STT |
| `GATE_CONTRACT_ADDRESS` | Output of `forge create BehaviorGate` | Chain gate |
| `BEHAVIORS_ROOT_HASH` | Output of `0g-storage upload behaviors.json` | Storage fetch |

---

## 0G Network Endpoints

| Service | Endpoint |
|---|---|
| Chat (GLM/DeepSeek) | `https://compute-network-1.integratenetwork.work/v1/proxy/chat/completions` |
| Whisper STT | `https://compute-network-16.integratenetwork.work/v1/proxy/audio/transcriptions` |
| 0G Chain RPC | `https://evmrpc-testnet.0g.ai` |
| 0G Chain Explorer | `https://testnet.0gscan.ai` |
| 0G Storage RPC | `https://rpc-storage-testnet.0g.ai` |
| 0G Faucet | `https://faucet.0g.ai` |
| 0G Compute Marketplace | `https://pc.0g.ai` |

---

## Why This Architecture Wins

The judging rubric awards **10 points** (40% of total) for 0G Integration, with the highest
score going to projects where "0G is essential to how it works."

In ChainReaction:
- **Remove Compute** → robot can't hear or understand anything
- **Remove Chain** → no behavior authorization, premium behaviors are ungated or broken
- **Remove Storage** → robot has no behaviors to execute

0G is not decorative. It is the skeleton.
