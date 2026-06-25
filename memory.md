# 🧠 ChainReaction — AI Memory & Context Manifest

This document serves as a persistent context ledger for any AI assistant or developer working on the **ChainReaction** repository. It outlines the current state, system constraints, deployment configurations, and architecture based directly on the codebase.

---

## 1. Project Overview

*   **Project Name**: ChainReaction
*   **Purpose**: A single-page, high-fidelity cybernetic command deck that connects a Pollen Robotics **Reachy Mini** robot (or its 3D WebGL simulator) to the **0G decentralized blockchain stack**.
*   **Target Audience**: Hackathon judges, developers, and engineers showcasing 0G decentralized infrastructure.
*   **Current Phase**: 100% Completed, verified, and active for presentation.

---

## 2. Tech Stack & Dependencies

### Core Frontend (Path A - Static SPA)
*   **Base Technologies**: HTML5, Vanilla CSS, Plain JavaScript (ES modules).
*   **No Build Step**: No bundlers (Vite/Webpack), no NPM modules compiled in the client, and no styling frameworks (Tailwind) are used in `app/index.html`.
*   **CDN Dependencies (Pinned)**:
    *   Ethers.js: `https://cdn.jsdelivr.net/npm/ethers@6.13.1/dist/ethers.umd.min.js`
    *   Reachy Mini SDK: `https://cdn.jsdelivr.net/gh/pollen-robotics/reachy_mini@v1.7.1/js/reachy-mini.js`

### 3D Simulator & Graphics
*   **Library**: Custom Three.js URDF robot simulator (`app/sim.js`).

### Blockchain & Smart Contracts
*   **Language**: Solidity (`BehaviorGate.sol`).
*   **Development & Build Tool**: Foundry (`forge` / `cast`).

### Local Dev Servers
*   Node.js 18+ HTTP Server via `npx http-server`.
*   Python 3 `http.server` as a fallback.

---

## 3. Project Architecture & Component Mapping

```
chain-reaction/
├── app/
│   ├── index.html        ← MAIN ENTRYPOINT. All styles, layout, and client logic live here.
│   ├── sim.js            ← Three.js WebGL simulator for the Reachy Mini robot model.
│   ├── behaviors.json    ← Sourced behavior sequences manifest copy.
│   └── README.md         ← HF Space configuration frontmatter with 0g-hackathon tag.
├── contracts/
│   ├── BehaviorGate.sol  ← Smart contract for gating premium robot behaviors on-chain.
│   └── deploy_output.log ← Record of local smart contract deployment address.
├── behaviors.json        ← Master copy of behavior specifications uploaded to 0G storage.
├── docs/
│   ├── SETUP.md          ← Deployment and credential setup guide.
│   ├── ARCHITECTURE.md   ← Full system telemetry and data flow guide.
│   └── BUILD-PLAN.md     ← Checklist tracking completed build phases.
└── README.md             ← Main developer landing page.
```

### Component Roles & Data Flow
1.  **Voice Loop (0G Compute)**: 
    *   Audio is recorded as WebM/Opus, converted to a 16-bit WAV PCM blob using the Web Audio API, and sent to **0G Whisper STT** (`compute-network-16.integratenetwork.work`).
    *   The transcribed query is sent to **0G LLM Compute** (`compute-network-1.integratenetwork.work`) via a structured system prompt, returning JSON: `{ "reply": "...", "behavior": "dance", "requires_payment": true }`.
2.  **On-Chain Gates (0G Chain)**:
    *   If `requires_payment` is `true`, the client queries the `BehaviorGate.sol` smart contract on **0G Chain Testnet (16600)** using `checkBatch()`.
    *   If locked, the user is prompted with a MetaMask payment modal. Triggering payment calls `unlock()` on the contract. 
3.  **Behavior Load (0G Storage)**:
    *   Upon validation, behavior parameters are loaded from the decentralized **0G Storage Root Hash** containing the serialized `behaviors.json` manifest.
4.  **Telemetry & Playback**:
    *   Motions execute inside the 3D Simulator (or the real robot via WebRTC streams), driving joint matrices.
    *   The UI updates real-time holographic gauges (Yaw, Pitch, Roll dials) on the viewport overlays.

---

## 4. Deployed Environments & Configurations

### Deployed Targets
*   **Vercel Production**: `https://chain-reaction-eight.vercel.app` (Direct, no-iframe deployment supporting full WebRTC and MetaMask access).
*   **Hugging Face Spaces**: `https://akindttl-chain-reaction.static.hf.space` (Static space for hackathon catalog indexing).
*   **Local Host**: `http://localhost:8765`

### 0G Chain Testnet Config
*   **RPC URL**: `https://evmrpc-testnet.0g.ai`
*   **Chain ID**: `16600` (Hex: `0x40D8`)
*   **Block Explorer**: `https://testnet.0gscan.ai`
*   **BehaviorGate Contract Address**: `0xC7EdB6191b34A12B2625902B7347aB4734De1766`
*   **0G Storage Gateway**: `https://rpc-storage-testnet.0g.ai`
*   **Behaviors JSON Root Hash**: `[NEEDS INPUT]` (Dynamic client configuration, updated in setup overlay).

---

## 5. Coding Conventions & Constraints

### Single-File Client Rule
*   All frontend application views, controllers, styles, and logic must remain in `app/index.html`. Do not split files or introduce modular build frameworks.

### WebRTC Audio Exception
*   Never call `navigator.mediaDevices.getUserMedia()` for robot-side audio. Always retrieve audio directly from the WebRTC incoming stream track:
    ```js
    const vid = document.getElementById('remoteVideo');
    const robotAudio = vid?.srcObject?.getAudioTracks?.() || [];
    ```
*   Never call `robot.setMicMuted(false)` to prevent audio feedback loops.

### Ethers.js Version
*   Must use Ethers v6 syntax: `new ethers.BrowserProvider(window.ethereum)`. Never use legacy Ethers v5 syntax.

### Parser Robustness
*   Always parse LLM responses defensively inside a `try-catch` block:
    ```js
    let parsed;
    try {
      parsed = JSON.parse(raw);
    } catch (_) {
      parsed = { reply: raw, behavior: null, requires_payment: false };
    }
    ```

---

## 6. Layout & Responsiveness Systems

*   **Compact Gateway Form**: The setup configuration gateway utilizes a non-expanding layout constrained to a maximum width of `460px` with uniform `24px` padding across both desktop and mobile viewports. This prevents vertical button cutoffs and removes scrolling requirements.
*   **Bottom Navigation Tabs on Mobile**: On screens `< 1024px`, the 3-column deck collapses into a tabbed layout controlled via a glassmorphic bottom navigation panel.
    *   **Tab 'library'**: Displays behaviors manifest list and composer lab.
    *   **Tab 'viewport'**: Displays the 3D Three.js simulator view and telemetry overlay, automatically triggering a `.resize()` event on load.
    *   **Tab 'logs'**: Displays the transaction feed, logs, and node streams.
*   **Scaled Telemetry Gauges**: Telemetry overlays and text elements automatically scale down to `140px` width on mobile screens to ensure the robot model remains visible.

---

## 7. Known Issues & Gaps

*   **0G Compute Key TTL**: Minted compute keys (`app-sk-...`) have a finite lifetime. If inference calls result in `400` validation errors, new keys must be minted using the CLI.
*   **Sandbox Simulation Mode**: Developer sandbox mode mimics transcribing and wallet block events locally for presentation robustness; ensure this mode is toggled off in the gateway config when showcasing live blockchain events.
*   **Vendor Prefixes**: The CSS includes minor vendor-prefix warnings (e.g. `-webkit-background-clip`, `appearance`) that are safe to ignore in modern browsers.
