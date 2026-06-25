# Contributing to ChainReaction

Thank you for your interest in contributing to **ChainReaction**! This document provides guidelines for contributing to this project.

---

## Repository Constraints

This project follows a strict **Path A (JS/Static)** architecture. Please adhere to these guidelines to ensure consistency:

### 1. Single-File Constraints
All application structure, styles, and logic must live within `app/index.html`.
- **CSS**: Place all styling in the `<style>` block in `app/index.html`. Do not create separate `.css` files.
- **JS**: Place all frontend logic in the `<script>` blocks in `app/index.html`. Do not split logic into separate files unless modifying the 3D URDF simulator in `app/sim.js`.
- **Dependencies**: Use ONLY pinned CDN imports. Never use `@latest` or unpinned version paths.

### 2. Robot SDK Conventions
- **Never call `navigator.mediaDevices.getUserMedia()`** for robot audio. Always capture audio from the WebRTC incoming video track, falling back to standard user media if not present:
  ```js
  const vid = document.getElementById('remoteVideo');
  const robotAudio = vid?.srcObject?.getAudioTracks?.() || [];
  const stream = robotAudio.length ? new MediaStream(robotAudio) : await navigator.mediaDevices.getUserMedia({ audio: true });
  ```
- **Never call `robot.setMicMuted(false)`** — this triggers audio loopback through the physical robot speakers.
- **WAV formatting**: Use `webmBlobToWav()` before sending audio to the 0G Whisper API. 0G Whisper does not accept raw WebM blobs.
- **Wake command**: Always invoke `await robot.ensureAwake()` immediately after `startSession()` to prevent motor commands from silently failing.

### 3. Ethers v6 Syntax
All smart contract interactions must use Ethers v6 syntax:
```js
// Ethers v6 (correct)
const provider = new ethers.BrowserProvider(window.ethereum);
const signer = await provider.getSigner();

// Ethers v5 (incorrect - will fail)
const provider = new ethers.providers.Web3Provider(window.ethereum);
```

### 4. 0G Compute Providers & Keys
Inference calls require pairing keys to their designated hosts:
- **Chat/LLM (GLM-5)**: `compute-network-1.integratenetwork.work`
- **Whisper STT**: `compute-network-16.integratenetwork.work`

---

## Local Development Workflow

1. **Install Dependencies**:
   This project uses static assets, but http-server is configured via package.json to test local deployments.
   ```bash
   npm install
   ```

2. **Run Dev Server**:
   ```bash
   npm run dev
   ```
   Open `http://localhost:8765` in your browser.

3. **Code Quality & Style**:
   - Keep styles clean, modern, and high-performance.
   - Avoid neon glow effects, heavy purple/cyan gradients, and non-functional HUD animations.
   - Maintain clear typography hierarchy and proportional padding/margins.

---

## Deployments

- **Vercel**: Pushes to `main` are auto-deployed to Vercel. Ensure `vercel.json` redirects root traffic correctly to `/app/index.html`.
- **Hugging Face Spaces**: Deploy your static application to a static Hugging Face Space for live robot pairing.
