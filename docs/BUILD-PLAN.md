# 📋 ChainReaction — Phased Build Plan

Designed for a 1–2 day hackathon sprint.
Each phase has a clear checkpoint — do not move to the next phase until the checkpoint passes.

---

## Pre-work (Before Hackathon Day)

Complete everything in `docs/SETUP.md`:

- [ ] Wallet funded with testnet 0G tokens
- [ ] Both provider sub-accounts funded on pc.0g.ai (chat + whisper — separately)
- [ ] Both API keys minted (`OG_CHAT_KEY`, `OG_STT_KEY`) and smoke-tested with curl
- [ ] BehaviorGate contract deployed — `GATE_CONTRACT_ADDRESS` saved
- [ ] Behavior prices set on contract (dance, fortune, backflip)
- [ ] `behaviors.json` uploaded to 0G Storage — `BEHAVIORS_ROOT_HASH` saved
- [ ] HF Space created and initial push done
- [ ] App runs locally at `http://localhost:8765`

---

## Phase 1 — Voice Loop (Hours 1–3)

**Goal:** Speech in → AI out → robot moves + speaks.

### Tasks

- [ ] Copy `sim.js` from the reference starter into `app/`
- [ ] Set up `index.html` with the base layout (topbar, 3D viewport, conversation panel)
- [ ] Wire `initRobot()` for both sim and live WebRTC modes
- [ ] Implement `webmBlobToWav()` → `transcribe()` pipeline (0G Whisper)
- [ ] Implement `askAI()` with JSON-structured system prompt
- [ ] Parse the `{reply, behavior, requires_payment}` JSON response
- [ ] Wire basic free behaviors (wave, nod, shake) to robot animations
- [ ] Implement `speak()` TTS via Web Speech API

### ✅ Checkpoint 1

Speak a sentence → robot transcribes it → LLM replies with JSON → robot nods/waves + TTS speaks the reply.
The transcript appears in the conversation panel.
**Do not proceed until this works end-to-end.**

---

## Phase 2 — Chain Gate (Hours 3–6)

**Goal:** Premium behaviors require MetaMask payment on 0G Chain.

### Tasks

- [ ] Add ethers.js v6 via CDN to `index.html` (no npm needed)
- [ ] Add "Connect Wallet" button to topbar
- [ ] Implement `connectWallet()`:
  - [ ] `window.ethereum.request({ method: 'eth_requestAccounts' })`
  - [ ] Switch to 0G Chain testnet via `wallet_switchEthereumChain` / `wallet_addEthereumChain`
  - [ ] Create `ethers.BrowserProvider` + `ethers.Contract` instance
- [ ] On wallet connect: call `checkBatch()` for all behavior keys → cache unlock status
- [ ] In `sendMessage()`: if `requires_payment` and not unlocked → show payment modal
- [ ] Implement payment modal:
  - [ ] Shows behavior name, emoji, price in 0G
  - [ ] "Pay with MetaMask" button → calls `contract.unlock(behaviorKey, {value: priceWei})`
  - [ ] Shows spinner while tx pending
  - [ ] On `tx.wait()` confirmation: show tx hash, update cache, proceed to behavior
- [ ] Add "Chain Activity" feed — shows recent tx hashes with timestamp

### ✅ Checkpoint 2

Say "Do the happy dance" → LLM returns `requires_payment: true` → payment modal appears →
MetaMask prompts → user pays → tx confirms → tx hash shown in feed → robot dances.
**This is the demo moment. Nail it.**

---

## Phase 3 — Storage Integration (Hours 6–8)

**Goal:** Behavior definitions come from 0G Storage, not hardcoded values.

### Tasks

- [ ] Implement `fetchBehaviorLibrary(rootHash)` — fetch `behaviors.json` from 0G Storage on startup
- [ ] Replace all hardcoded animation sequences with data from the fetched library
- [ ] Implement `executeBehavior(behaviorKey, behaviorData)` — generic sequencer:
  - [ ] Iterates through the `sequence` array from behavior JSON
  - [ ] Applies head + antenna positions with `sleep()` delays
- [ ] Show "Powered by 0G Storage" attribution in the UI
- [ ] Handle fetch failure gracefully — fall back to embedded defaults

### ✅ Checkpoint 3

Change a behavior's TTS string in `behaviors.json`, re-upload to 0G Storage, paste new root hash in config.
The robot speaks the new string without touching `index.html`.
**Behavior library is now truly decentralized.**

---

## Phase 4 — Polish & Demo Story (Hours 8–10)

**Goal:** The 2-minute demo is airtight, visually stunning, and tells a clear story.

### Tasks

#### UI Polish
- [ ] Dark mode with 0G purple + neon green for confirmed tx chain feed
- [ ] Animated "Chain Activity" panel with live tx entries (slide-in on confirm)
- [ ] Behavior grid showing free vs premium with lock icons
- [ ] Payment modal: smooth slide-up animation
- [ ] Wallet address shown truncated in topbar when connected
- [ ] Robot status indicator (idle / listening / thinking / speaking / executing)

#### Demo Prep
- [ ] Set contract addresses + root hash as URL params so setup overlay auto-fills:
  `?gate=0x...&behaviors=<rootHash>`
- [ ] Rehearse the exact 2-minute script:
  1. Free behavior: "Say hi to everyone" → robot waves + greets
  2. Premium: "Do the happy dance" → payment modal → MetaMask → robot dances → tx hash shown
  3. Close: "What's happening on-chain?" → LLM reads wallet state, robot nods
- [ ] Know your closing line: *"Remove 0G from this — and the robot stops working."*

#### Pre-demo Checklist
- [ ] Switch app to "Live Robot" mode (not sim)
- [ ] Wallet connected and balance visible
- [ ] Verify premium behavior is locked (or reset it for the demo)
- [ ] HF Space URL ready to share

### ✅ Checkpoint 4 (Final)

Run the complete demo script end-to-end, timed.
- Under 3 minutes? ✅
- Live tx hash visible on screen? ✅
- Robot moves expressively? ✅
- Closing statement lands? ✅

**You're ready.**

---

## Contingency Plans

| If... | Then... |
|---|---|
| MetaMask won't connect | Pre-sign and broadcast the unlock tx, show a static tx hash for the demo |
| 0G Storage fetch fails | Fall back to embedded `behaviors.json` — no one will know |
| Robot doesn't respond to motions | Check `await robot.ensureAwake()` is called after `startSession()` |
| `reachy-mini.local` doesn't resolve | Use the IP posted at the demo station |
| `app-sk-` token rejected | Re-mint: `0g-compute-cli inference get-secret --provider <addr>` |
| Sim works but live robot doesn't | Ensure both laptop and robot are on the same network/SSID |

---

## Score at Each Phase

| After Phase | Expected 0G Score | Reason |
|---|---|---|
| Phase 1 | 4–5/10 | Compute only, working |
| Phase 2 | 8–9/10 | Compute + Chain, both essential |
| Phase 3 | 9–10/10 | All three services, all essential |
| Phase 4 | 9–10/10 + high Execution | Polish + airtight demo |
