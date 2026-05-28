# ⛓️ ChainReaction — 0G Cybernetic Command Deck

> *"The first expressive robot whose choreography and premium behaviors are gated by decentralized blockchain smart contracts."*

**ChainReaction** is an advanced cybernetic control dashboard built for the **Reachy Mini × 0G Hackathon**. It bridges decentralized AI compute, decentralized immutable storage, and on-chain EVM behavior gating to control an expressive desk robot (or its high-fidelity 3D URDF simulator) through voice commands.

This project has been transformed into an **EXTREMELY BLAZING HOT WORLD-STANDARD CYBERNETIC COMMAND DECK** with rich neon glassmorphism aesthetics, live holographic telemetry HUDs, a real-time blockchain node diagnostic console, and an interactive **0G Behavior Lab (Choreographer & Schema Exporter)**.

---

## 🚀 Key Visual & Functional Breakthroughs

### 1. Holographic Telemetry HUD
The 3D URDF viewport has been overlayed with a futuristic wireframe head-up display (HUD):
- **Live Joint Coordinate Gauges**: Tracks and updates head `Roll`, `Pitch`, `Yaw` angles and antenna degrees per frame from the Three.js model.
- **Rotating Scope Reticles**: Highly detailed rotating cybernetic target crosshair overlay with scanline feeds.
- **System State Tracker**: Real-time feedback indicators reading state vectors from the robot to display active state states (`SYSTEM READY` vs `EXECUTING_MOTION`).

### 2. 0G Behavior Lab (Choreographer Panel)
A full-featured visual robotics motion suite built directly into the sidebar:
- **Interactive Joint Sliders**: Drag coordinate sliders to instantly move Reachy's head and antennas in the 3D simulator.
- **Keyframe Manifest Builder**: Add poses, set transition durations (in ms), delete keyframes, and build complete motion macros.
- **TTS Integrator & Playback test**: Preview the combined vocal phrase and custom choreographed sequence live.
- **0G Storage Schema Exporter**: Generates a standardized, valid JSON configuration block ready to be uploaded to **0G Storage** or saved to behaviors manifests.

### 3. 0G Block Ledger Diagnostics
An integrated real-time blockchain monitor:
- **Live Block Height Indicator**: Automatically increments blocks simulating real-time minting on the 0G Chain.
- **MetaMask RPC Balance Binding**: Dynamically fetches and renders the user's authentic `0G` token balances from their connected wallet.
- **Ping Metrics**: Real-time escrows latency response tracker.
- **Transaction Streams Console**: Cybernetic command line showing gas costs, block signatures, transaction states, and links to the explorer.

### 4. Interactive Sandbox Gateway
Built-in **Developer Sandbox Mode** for frictionless showcases. 
- Allows judges to immediately test the entire voice-transcribe loop, chat completions, and smart-contract payment gates with a single click, requiring **zero pre-configured API keys or token deposits**.

---

## 🧩 Architectural Blueprint

| System Layer | Technology | Role |
|---|---|---|
| **Voice Processing** | 0G Compute · Whisper STT | High-speed transcription of incoming microphone WAV inputs |
| **Cognitive Brain** | 0G Compute · GLM-5-FP8 / DeepSeek | Intent parsing returning structured JSON: `{reply, behavior, requires_payment}` |
| **On-Chain Gate** | 0G Chain · `BehaviorGate.sol` | Secure Solidity gate: check behavior unlocks and process `0G` payments |
| **Decentralized Library** | 0G Storage · `behaviors.json` | Immutable, community-owned behavior manifest sets |
| **Cybernetic Body** | Reachy Mini · 3D URDF Sim / WebRTC | Real-time motion execution (Head RPY + antennas) + digital telemetry HUD |

---

## ⚡ Quick Start

### 1. Run the Command Deck Locally
Initialize the development server using npm:
```bash
npm run dev
```
*Behind the scenes, this runs `http-server` via `npx` to securely serve the static app on port `8765`.*

### 2. Launch the Gateway
1. Open `http://localhost:8765` in your browser.
2. Choose your entry route:
   - **Launch Developer Sandbox**: Instantly enters the workspace with preloaded mock environments, allowing complete flow tests (including transcribing and gated payments) in under 1 second.
   - **Start Live System**: Input your minted **0G Compute keys**, deployed **BehaviorGate contract address**, **0G Storage behavior root hash**, and start syncing live transactions!

---

## 🏆 Hackathon Winning Integration Points

- **Compute Gating**: The robot's ears (Whisper STT) and brain (GLM-5) are driven exclusively by 0G decentralized providers.
- **Chain Gating**: MetaMask handles payments via `BehaviorGate.sol` on the `0G Chain Testnet` (16600), displaying gas logs and explorer links directly on the command deck.
- **Storage Gating**: Dynamic movement schemas are fetched straight from content-addressed 0G Storage gateway hashes.
- **Authoring System**: The **0G Behavior Lab** closes the loop by allowing users to compose, test, and compile new behaviors directly to 0G Storage JSON specifications.
