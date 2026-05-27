# ⚙️ ChainReaction — Setup Guide

**Do every step in this document BEFORE the hackathon day.**
Steps 1–4 are the #1 day-of blocker for most teams. None of this takes more than 30 minutes.

---

## Step 0 — Clone your own repo

Create a new GitHub repo (e.g. `chain-reaction`) and clone it locally.
Copy the `chain-reaction/` folder from the reference repo into it:

```bash
cp -r reachy-mini-hackathon/chain-reaction/. ./chain-reaction
cd chain-reaction
git init
git add .
git commit -m "init: ChainReaction scaffold"
git remote add origin https://github.com/<YOUR_USER>/chain-reaction
git push -u origin main
```

---

## Step 1 — Get a wallet + testnet 0G tokens

1. Install MetaMask (or any EVM wallet): https://metamask.io
2. Add **0G Chain Testnet** to MetaMask manually:

   | Field | Value |
   |---|---|
   | Network Name | 0G Chain Testnet |
   | RPC URL | `https://evmrpc-testnet.0g.ai` |
   | Chain ID | `16600` |
   | Currency Symbol | `0G` |
   | Explorer | `https://testnet.0gscan.ai` |

3. Claim free testnet tokens from the faucet:

```
https://faucet.0g.ai
```

You need at least **5 0G** — enough for multiple provider deposits and contract interactions.

---

## Step 2 — Fund 0G Compute provider sub-accounts

> ⚠️ **Critical:** Each model has its own provider address. Funding the chat provider does NOT cover Whisper. They are separate escrow accounts.

1. Go to https://pc.0g.ai and connect your wallet.
2. Browse **AI Models** and locate these two:
   - **Chat**: `zai-org/GLM-5-FP8` (recommended) or `deepseek/deepseek-chat-v3-0324`
   - **Speech-to-text**: `openai/whisper-large-v3`
3. Click into **each** provider → deposit at least **1 0G** to that provider's sub-account.

---

## Step 3 — Mint per-provider API keys

Install the 0G CLI (requires Node.js 18+):

```bash
npm install -g @0glabs/0g-compute-cli
```

Mint a key for each provider you funded. The provider address is shown on the model card at pc.0g.ai:

```bash
0g-compute-cli inference get-secret --provider <CHAT_PROVIDER_ADDRESS>
```

```bash
0g-compute-cli inference get-secret --provider <WHISPER_PROVIDER_ADDRESS>
```

Save these as `OG_CHAT_KEY` and `OG_STT_KEY`. They look like `app-sk-<base64>`.

> ⚠️ These tokens have a TTL. If auth fails after working, re-mint with the same command.

---

## Step 4 — Smoke-test your keys with curl

Test the chat key:

```bash
curl -sS https://compute-network-1.integratenetwork.work/v1/proxy/chat/completions \
  -H "Authorization: Bearer $OG_CHAT_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"zai-org/GLM-5-FP8","messages":[{"role":"user","content":"hi"}],"max_tokens":5}'
```

Test the Whisper key:

```bash
curl -sS https://compute-network-16.integratenetwork.work/v1/proxy/audio/transcriptions \
  -H "Authorization: Bearer $OG_STT_KEY" \
  -F file=@any_audio.wav \
  -F model=openai/whisper-large-v3 \
  -F response_format=json
```

Both must return `200` with JSON. Fix any errors before building.

**Common errors:**

| Error | Cause | Fix |
|---|---|---|
| `missing or invalid Authorization header` | Wrong key for this host | Use the key that matches this specific provider's host |
| `insufficient balance` | Sub-account not funded | Deposit at pc.0g.ai for that specific provider |
| `400 Provider proxy:` | Wrong endpoint URL | Ensure URL ends in `/v1/proxy` then the path |

---

## Step 5 — Deploy the BehaviorGate smart contract

Install Foundry (the fastest EVM dev toolkit):

```bash
curl -L https://foundry.paradigm.xyz | bash
```

```bash
foundryup
```

Deploy to 0G Chain testnet:

```bash
cd contracts
forge create BehaviorGate \
  --rpc-url https://evmrpc-testnet.0g.ai \
  --private-key $WALLET_PRIVATE_KEY \
  --broadcast
```

Copy the `Deployed to:` address — this is your `GATE_CONTRACT_ADDRESS`.

Then set prices for premium behaviors (in wei):

```bash
cast send $GATE_CONTRACT_ADDRESS \
  "setPriceBatch(string[],uint256[])" \
  '["dance","fortune","backflip"]' \
  '[10000000000000000,5000000000000000,20000000000000000]' \
  --rpc-url https://evmrpc-testnet.0g.ai \
  --private-key $WALLET_PRIVATE_KEY
```

Verify on the explorer: https://testnet.0gscan.ai

---

## Step 6 — Upload behaviors.json to 0G Storage

Install the 0G storage client:

```bash
npm install -g @0glabs/0g-ts-sdk
```

Upload the behavior library:

```bash
0g-storage upload --file behaviors.json --rpc https://rpc-storage-testnet.0g.ai
```

Copy the returned **root hash** — you'll paste it into the app config.

---

## Step 7 — Run the app locally

Serve the `app/` directory over HTTP (required — file:// won't work with the SDK):

```bash
cd app
python3 -m http.server 8765
```

Open `http://localhost:8765` in your browser.

In the setup overlay, fill in:
- **Chat API key** → your `OG_CHAT_KEY`
- **Whisper key** → your `OG_STT_KEY`
- **Contract address** → your `GATE_CONTRACT_ADDRESS`
- **Behavior root hash** → from Step 6
- **Robot** → 3D Simulator (for dev), Live Robot (for demo)

---

## Step 8 — Publish to Hugging Face Space (Day 1)

> **Required.** OAuth (`robot.login()`) only works from `*.static.hf.space`. Also needed for "Install to Robot" at demo time.

1. Create a **Static** Space at https://huggingface.co/new-space
2. Push your `app/` directory:

```bash
git remote add hf https://huggingface.co/spaces/<YOUR_USER>/chain-reaction
git subtree push --prefix app hf main
```

Your app lives at `https://<YOUR_USER>-chain-reaction.static.hf.space/`

---

## Step 9 — Demo-day checklist

- [ ] HF Space is live and accessible from the venue laptop
- [ ] Contract is deployed on 0G testnet — verify at https://testnet.0gscan.ai
- [ ] All API keys tested with curl — no errors
- [ ] Behavior library uploaded — root hash in app config
- [ ] Demo script rehearsed — under 3 minutes, one clear "wow" moment
- [ ] Know the robot IP as fallback for `reachy-mini.local` (posted at demo station)
- [ ] `await robot.ensureAwake()` is called after `startSession()` — or motions silently no-op
- [ ] Demo on sim first, then switch to Live Robot mode for the actual demo slot
