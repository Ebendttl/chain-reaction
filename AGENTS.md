# AGENTS.md — ChainReaction

Guidance for AI coding agents (Claude Code, Cursor, Codex, Copilot, etc.) working on the **ChainReaction** project.

---

## What this project is

**ChainReaction** is a single-file web app (`app/index.html`) that connects a Reachy Mini robot to the 0G blockchain stack.
It is a **Path A (JS/Static)** app — no build step, no npm, no bundler. Everything is a CDN import or inline.

**The three 0G services and why each is non-negotiable:**
- **0G Compute** → Whisper STT + LLM inference. Without it the robot is deaf and mute.
- **0G Chain** → `BehaviorGate.sol` gates premium behaviors. Without it there is no product differentiation.
- **0G Storage** → Behavior library JSON. Without it the robot has no choreography to execute.

---

## Repo layout

```
chain-reaction/
├── app/
│   ├── index.html        ← MAIN FILE. All app logic lives here. Single file, no bundler.
│   └── sim.js            ← 3D browser sim. Do not modify unless fixing a bug.
├── contracts/
│   └── BehaviorGate.sol  ← Solidity. Only modify to add new features — do not break the ABI.
├── behaviors.json        ← Uploaded to 0G Storage. Edit here, re-upload, update root hash.
├── docs/
│   ├── SETUP.md          ← Keys, wallet, deploy, run. The source of truth for setup.
│   ├── ARCHITECTURE.md   ← Full system diagram and data flow.
│   └── BUILD-PLAN.md     ← Phased checklist with checkpoints.
└── README.md             ← Project overview and quick start.
```

---

## Coding conventions

### Single-file constraint
`app/index.html` is one file. This is intentional. Do not split it into multiple files.
All CSS is in `<style>`. All JS is in `<script>`. External dependencies are CDN imports only.

### CDN versions — always pin, never use @latest
```html
<!-- ✅ Correct -->
<script src="https://cdn.jsdelivr.net/npm/ethers@6.13.1/dist/ethers.umd.min.js"></script>
<script type="module">
  import { ReachyMini } from 'https://cdn.jsdelivr.net/gh/pollen-robotics/reachy_mini@v1.7.1/js/reachy-mini.js';
</script>

<!-- ❌ Wrong -->
<script src="https://cdn.jsdelivr.net/npm/ethers@latest/..."></script>
```

### Robot SDK — critical gotchas (read before touching robot code)

1. **Never call `navigator.mediaDevices.getUserMedia()`** for robot audio.
   Capture from the WebRTC incoming track:
   ```js
   const vid = document.getElementById('remoteVideo');
   const robotAudio = vid?.srcObject?.getAudioTracks?.() || [];
   const stream = robotAudio.length ? new MediaStream(robotAudio) : await navigator.mediaDevices.getUserMedia({ audio: true });
   ```

2. **Never call `robot.setMicMuted(false)`** — causes audio loopback through the robot speaker.

3. **Always call `await robot.ensureAwake()` after `startSession()`** or all motion commands silently no-op.

4. **WebM/opus → WAV before Whisper** — use `webmBlobToWav()`. 0G Whisper rejects raw webm blobs.

### 0G Compute API — key/host pairing
Each provider has its own host. Sending the wrong key to a host returns:
`400 Provider proxy: validate session: missing or invalid Authorization header`

| Service | Host | Key variable |
|---|---|---|
| Chat (GLM/DeepSeek) | `compute-network-1.integratenetwork.work` | `OG_CHAT_KEY` |
| Whisper STT | `compute-network-16.integratenetwork.work` | `OG_STT_KEY` |

**Never reuse keys across services.**

### 0G Chain — always use ethers v6 syntax
The app uses ethers.js v6 (not v5). Syntax differs:
```js
// v6 ✅
const provider = new ethers.BrowserProvider(window.ethereum);
const signer = await provider.getSigner();

// v5 ❌ (will break)
const provider = new ethers.providers.Web3Provider(window.ethereum);
```

### LLM responses — always JSON
The system prompt instructs the model to return only a JSON object. Always `JSON.parse()` the response.
Handle parse failures gracefully — fall back to treating the full response as `reply` with no behavior.

```js
let parsed;
try {
  parsed = JSON.parse(raw);
} catch (_) {
  parsed = { reply: raw, behavior: null, requires_payment: false };
}
```

---

## 0G Chain testnet config

```js
const OG_CHAIN = {
  chainId: '0x40D8',        // 16600 in hex
  chainName: '0G Chain Testnet',
  rpcUrls: ['https://evmrpc-testnet.0g.ai'],
  nativeCurrency: { name: '0G', symbol: '0G', decimals: 18 },
  blockExplorerUrls: ['https://testnet.0gscan.ai'],
};
```

To add the network to MetaMask:
```js
await window.ethereum.request({ method: 'wallet_addEthereumChain', params: [OG_CHAIN] });
```

---

## BehaviorGate ABI (minimal — use this in the frontend)

```js
const GATE_ABI = [
  "function isUnlocked(address user, string key) view returns (bool)",
  "function unlock(string key) payable",
  "function behaviorPrice(string key) view returns (uint256)",
  "function checkBatch(address user, string[] keys) view returns (bool[])",
];
```

---

## Behavior keys (must match contract + behaviors.json)

| Key | Tier | Price |
|---|---|---|
| `wave` | free | 0 |
| `nod` | free | 0 |
| `shake` | free | 0 |
| `sleep` | free | 0 |
| `wake` | free | 0 |
| `dance` | premium | 0.01 0G |
| `fortune` | premium | 0.005 0G |
| `backflip` | premium | 0.02 0G |

---

## What to load before starting work

Before making any changes, read:
1. This file (you are here)
2. `docs/ARCHITECTURE.md` — understand the full data flow
3. `docs/BUILD-PLAN.md` — understand which phase you are in
4. The relevant section of `app/index.html` for the area you are changing

For Reachy Mini SDK questions: https://github.com/pollen-robotics/reachy_mini/blob/main/AGENTS.md
For 0G API questions: https://docs.0g.ai/ai-context
For hackathon context: https://github.com/0gfoundation/reachy-mini-hackathon/blob/main/hackathon-guide.md

---

## Definition of done

A feature is done when:
1. It works in the **3D simulator** (sim mode)
2. It works with **real 0G API keys** (not mocked)
3. It handles errors gracefully (no unhandled rejections, user sees a readable message)
4. It fits in `app/index.html` without creating new files
