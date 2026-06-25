# Security Policy

## Supported Versions

We active support and patch security issues on the following versions:

| Version | Supported |
| --- | --- |
| 1.2.x | :white_check_mark: |
| < 1.2.0 | :x: |

---

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please do NOT create a public GitHub issue. Instead, report it via one of the following methods:

- **Email**: Send a detailed report to the maintainers' contact addresses.
- **Encrypted Communication**: Include a proof of concept or steps to reproduce when reporting.

We aim to respond and acknowledge receipt of vulnerability reports within 48 hours.

---

## Key Management Best Practices

ChainReaction interfaces directly with EVM wallets (MetaMask) and 0G Compute provider gateway networks. Follow these safety rules:

1. **Private Keys**: Never hardcode wallet private keys anywhere in the frontend or Git history. Deploys using Foundry `forge` should load private keys via local environment variables only.
2. **0G API Keys**: 0G Compute API keys (`OG_CHAT_KEY` and `OG_STT_KEY`) must only be entered via the initialization screen dialog or loaded via runtime environment variables. Never commit credentials to the code repository.
3. **Sandbox mode**: Use the built-in Developer Sandbox Mode to test the application locally without inputting your active keys or exposing funded credentials to public preview environments.
