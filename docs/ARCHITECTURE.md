# 🏗️ ChainReaction — Architecture

## System Overview

ChainReaction is a high-fidelity cybernetic command deck that bridges **decentralized inference** (robot's voice/intent), **on-chain authorization gating** (premium behaviors), and **decentralized storage** (dynamic behavior manifest libraries).

It features a dual-mode telemetry deck: a high-fidelity 3D Urdf simulation overlayed with interactive neon joint dial HUDs, an on-chain transaction logs index, and a complete visual **Behavior Choreographer & 0G Storage Schema Builder**.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            USER                                         │
│                speaks or plays inside Behavior Lab                      │
└──────────────────────────┬──────────────────────────────────────────────┘
                           │ 1. Voice Transcripts (STT) or 2. Custom Slider Motions
                           ▼
╔══════════════════════════════════════════════════════════════════════════╗
║  0G COMPUTE — Whisper STT                                               ║
║  Host: compute-network-16.integratenetwork.work                         ║
║  Key:  OG_STT_KEY  (app-sk-... for whisper provider)                    ║
║  Input: WebM/opus blob → decoded to WAV via Web Audio API               ║
║  Output: transcript text string                                         ║
╚══════════════════════════════════════════════════════════════════════════╝
                           │ "Do the happy dance"
                           ▼
╔══════════════════════════════════════════════════════════════════════════╗
║  0G COMPUTE — LLM (GLM-5-FP8 or DeepSeek)                               ║
║  Host: compute-network-1.integratenetwork.work                          ║
║  Key:  OG_CHAT_KEY  (app-sk-... for chat provider)                      ║
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
║                         ║  ║  → true: proceed                        ║
║                         ║  ║  unlock(behaviorKey){value: price}      ║
║                         ║  ║  → emit BehaviorUnlocked(tx hash)       ║
╚═══════════════╤═════════╝  ╚════════════════╤═════════════════════════╝
                │            ║  await tx.wait() (verified on ledger)
                │            ╚════════════════╤═════════════════════════╝
                └────────────────────────────┘
                           │ confirmed payload + auth
                           ▼
╔══════════════════════════════════════════════════════════════════════════╗
║  CYBERNETIC TELEMETRY HUD & REACHY MINI JS SDK                          ║
║  • Holographic Telemetry HUD: Real-time Yaw/Pitch/Roll dials + progress ║
║  • 0G Behavior Lab: Sliders build sequences & export 0G Storage schema  ║
║  • 0G Block Diagnostics: Count block height live + MetaMask 0G balance ║
║  • TTS Audio: reads replies through speaker                             ║
╚══════════════════════════════════════════════════════════════════════════╝
```

---

## Technical Features

### 1. 0G Behavior Choreographer & Storage Schema Builder
The new **0G Behavior Lab** gives users a visual interface to choreograph new motions for Reachy.
- **Interactive sliders** map directly to the joints in the Three.js 3D URDF simulator, giving instant real-time posing feedback.
- **Keyframe Sequence Builder**: Users can add, delete, and preview keyframes in chronological order.
- **TTS Audio Integrator**: Combines motor steps with vocal phrases.
- **0G Storage Schema Generator**: Compiles custom choreographies into a standardized, valid JSON structure fully prepared for direct upload to **0G Storage**.

```json
{
  "tier": "custom",
  "label": "Bespoke Dance",
  "emoji": "⚡",
  "tts": "Check out my new moves!",
  "sequence": [
    { "head": { "roll": 10, "pitch": -10, "yaw": 20 }, "antennas": [30, -30], "duration_ms": 300 }
  ]
}
```

### 2. Holographic Telemetry HUD
Overlays the 3D viewport with real-time cybernetic gauges reading joint matrices.
- Dynamic telemetry variables: `Roll`, `Pitch`, `Yaw` angles, and `Left`/`Right` antenna degrees are tracked per frame.
- High-tech wireframe visual overlays, including rotating targeted scopes and horizontal neon progress stats.
- Integrated status engines reading the movement of the robot to output active state indicators (`SYSTEM READY` vs `EXECUTING_MOTION`).

### 3. 0G Block Ledger Diagnostics Deck
Displays the current condition of the connected decentralized network nodes.
- **Active Block Height**: Automatically counts up to represent active block minting on the 0G Chain Testnet.
- **MetaMask 0G Balance**: Connects directly to `window.ethereum` via standard Ethers.js providers to fetch and render the user's authentic `0G` token balances in real time.
- **Escrow Pings**: Measures response times to the decentralized node array.
- **Ledger Logs**: Feeds transactions, mined gas metrics, block signatures, and clickable block explorer links.

### 4. Interactive Sandbox Gateway
For ease of presentation and accessibility, the deck features a **Developer Sandbox Mode**.
- Intercepts API calls to simulate 0G Compute STT transcribing, chat completions (generating valid context-aware responses), and smart contract behavior purchases.
- Provides immediate showcase utility for hackathon judges who might not have active funded MetaMask accounts on 0G Chain Testnet yet.

---

## Sequence Matrix

```
[STT Voice input or choreo play]
       │
       ▼
[0G Whisper transcribes audio wav]
       │
       ▼
[0G GLM-5-FP8 returns behavior intent JSON]
       │
       ├─► (requires_payment: true) ─► check Batch Gates [0G Chain]
       │                                     │
       │                                     ▼ (if locked)
       │                               Show Pay Modal ─► Send Tx ─► [Await block confirmation]
       │
       ▼
[Fetch behavior sequence parameters] ◄─ [0G Storage]
       │
       ▼
[Play keyframe frames on 3D Sim / WebRTC] ◄─ (HUD telemetry dials spin in real-time)
       │
       ▼
[Speak SpeechSynthesis TTS vocal line]
```

---

## Why This System Architecture Wins

The judging rubric awards **10 points** (40% of total) for 0G Integration, looking specifically for applications where "0G is essential to how it works."

By introducing the **0G Behavior Choreographer & Schema Builder**:
1. **0G Storage** is now fully integrated as a dynamic write-target (payload builder) instead of just a read-only manifest.
2. **0G Chain** gating is showcased with both live MetaMask RPC balance bindings and interactive block diagnostic trackers.
3. **0G Compute** powers the dialogue loop with smart parser fallbacks.
4. **Developer Sandbox** guarantees judges can interact with every layer of the 0G mechanics instantly during live presentations.
