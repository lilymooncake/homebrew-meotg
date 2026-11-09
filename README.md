# homebrew-meotg

Personal Homebrew tap for **meotg**: Telegram in the terminal, built from
[nchat](https://github.com/d99kris/nchat) with Telegram only.

- Pinned to nchat **v5.19.18** by sha256; the source was reviewed before pinning
  (vendored TDLib 1.8.67 matches upstream tdlib/td@bc9c263, no telemetry, no update check).
- Built without WhatsApp and Signal.
- Never bumped without reviewing the upstream diff first.

## Install

```
brew tap lilymooncake/meotg
brew install meotg
meotg --setup        # choose 1. Telegram, enter phone + OTP
meotg-config         # Enter sends, Option-Enter new line, tomorrow-night theme
```

Config and messages live in `~/.config/nchat`.
In tmux, add `alias meotg="TERM=xterm-256color meotg"` to `~/.zshrc` for full colours.
