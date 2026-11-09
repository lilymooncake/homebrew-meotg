class Meotg < Formula
  desc "Telegram in the terminal: audited nchat build, Telegram only"
  homepage "https://github.com/d99kris/nchat"
  # Pinned to the nchat release audited on 2026-11-09. Do not bump without
  # re-auditing the diff (own code + vendored TDLib against upstream tdlib/td).
  url "https://github.com/d99kris/nchat/archive/refs/tags/v5.19.18.tar.gz"
  sha256 "69c3cf421871059f6726c58999d58a11f5a5a45a19828799a276c8b424992f52"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "gperf" => :build
  depends_on "help2man" => :build
  depends_on "libmagic"
  depends_on "ncurses"
  depends_on "openssl@3"
  depends_on "readline"
  depends_on "sqlite"

  def install
    args = %w[
      -DHAS_WHATSAPP=OFF
      -DHAS_SIGNAL=OFF
      -DHAS_TESTS=OFF
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    mv bin/"nchat", bin/"meotg"
    mv man1/"nchat.1", man1/"meotg.1"
    pkgshare.install "themes"

    (bin/"meotg-config").write <<~SH
      #!/bin/bash
      # Apply Ly's meotg settings: Enter sends, Option-Enter new line,
      # tomorrow-night theme, config dir readable by this user only.
      set -euo pipefail
      dir="${1:-$HOME/.config/nchat}"
      if pgrep -x meotg >/dev/null || pgrep -x nchat >/dev/null; then
        echo "meotg is running; quit it (Ctrl-q) first, it rewrites config on exit." >&2
        exit 1
      fi
      mkdir -p "$dir"
      set_key() {
        local file="$1" key="$2" value="$3"
        touch "$file"
        if grep -q "^${key}=" "$file"; then
          local tmp
          tmp="$(mktemp)"
          K="$key" V="$value" awk 'BEGIN{FS="="} $1==ENVIRON["K"]{print ENVIRON["K"] "=" ENVIRON["V"]; next} {print}' "$file" > "$tmp"
          mv "$tmp" "$file"
        else
          printf '%s=%s\\n' "$key" "$value" >> "$file"
        fi
      }
      set_key "$dir/key.conf" send_msg 'KEY_RETURN'
      set_key "$dir/key.conf" linebreak '\\33\\15'
      set_key "$dir/ui.conf" linefeed_on_enter '0'
      cp "#{pkgshare}/themes/tomorrow-night/"* "$dir/"
      chmod -R go-rwx "$dir"
      echo "Applied to $dir"
    SH
  end

  def caveats
    <<~EOS
      First login (needs the OTP from the Telegram app):
        meotg --setup

      Then apply Ly's settings (Enter sends, Option-Enter new line,
      tomorrow-night theme, config dir locked to your user):
        meotg-config

      Config and messages live in ~/.config/nchat.
      Inside tmux, add to ~/.zshrc for full colours:
        alias meotg="TERM=xterm-256color meotg"
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/meotg --version")
  end
end
