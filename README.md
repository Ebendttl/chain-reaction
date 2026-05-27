# ⛓️ ChainReaction — A Reachy Mini × 0G Chain App

> *"The only robot whose behaviors are gated by a smart contract."*

**ChainReaction** is a hackathon project built for the **Reachy Mini × 0G Hackathon**.
It combines decentralized AI inference, on-chain behavior gating, and expressive robotics
into a single live demo: speak a command → the blockchain decides what the robot does.

---

## 🧩 What It Does

| Layer | Technology | Role |
|---|---|---|
| **Voice Input** | 0G Compute · Whisper STT | Transcribes speech from the robot's mic |
| **AI Brain** | 0G Compute · GLM-5 / DeepSeek | Decides the reply and which behavior to trigger |
| **Behavior Gate** | 0G Chain · `BehaviorGate.sol` | Smart contract: is this behavior unlocked for this wallet? |
| **Behavior Library** | 0G Storage · `behaviors.json` | Community-owned behavior definitions (not hardcoded) |
| **Robot Body** | Reachy Mini · WebRTC / JS SDK | Executes the behavior: head, antennas, TTS via speaker |

Remove any one of these services — the product stops working. That's the point.

---

## 📁 Project Structure

```
chain-reaction/
├── app/
│   ├── index.html        ← Single-file web app (zero build step)
│   └── sim.js            ← 3D in-browser simulator (Three.js + URDF)
├── contracts/
│   └── BehaviorGate.sol  ← Solidity contract — deploy to 0G Chain
├── behaviors.json        ← Behavior library — upload to 0G Storage
├── docs/
│   ├── SETUP.md          ← Step-by-step: keys, wallet, deploy, run
│   ├── ARCHITECTURE.md   ← Full system diagram and data flow
│   └── BUILD-PLAN.md     ← Phased build checklist
└── README.md             ← You are here
```

---

## ⚡ Quick Start

1. **Read `docs/SETUP.md`** — do every step before the event
2. **Deploy the contract** — `contracts/BehaviorGate.sol` to 0G Chain testnet
3. **Upload behaviors** — `behaviors.json` to 0G Storage, copy the root hash
4. **Run the app** — `cd app && python3 -m http.server 8765`
5. **Open** `http://localhost:8765` and paste your keys in the setup overlay

For the full architecture explanation see `docs/ARCHITECTURE.md`.
For the phased build checklist see `docs/BUILD-PLAN.md`.

---

## 🏆 Judging Strategy

| Criterion | Target | How we hit it |
|---|---|---|
| 0G Integration | **9/10** | All 3 services: Compute (STT+LLM) + Chain (gate) + Storage (behaviors) |
| Reachy Mini Use | **4/5** | Robot mic, head + antennas, TTS through speaker |
| Creativity | **5/5** | On-chain-gated robot behaviors — never been done live |
| Execution | **4/5** | 2-min tight demo script with live tx hash shown on screen |
| **Total** | **22/25** | Tiebreaker won via 0G Integration score |

---

## 🔗 Links

- 0G Compute marketplace: https://pc.0g.ai
- 0G Chain testnet RPC: https://evmrpc-testnet.0g.ai (chainId: 16600)
- 0G testnet faucet: https://faucet.0g.ai
- Reachy Mini SDK: https://github.com/pollen-robotics/reachy_mini
- Hackathon guide (reference only): https://github.com/0gfoundation/reachy-mini-hackathon
