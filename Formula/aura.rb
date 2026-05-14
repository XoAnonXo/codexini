class Aura < Formula
  desc "Local voice bridge for Claude Code and Codex"
  homepage "https://codexini.com"
  version "0.3.10"
  # Proprietary, all rights reserved. The repo is public for
  # auditability + brew distribution, but use beyond running the
  # signed binaries from this tap requires explicit written
  # permission (see LICENSE in the source repo). Homebrew's DSL
  # represents non-SPDX licenses with :cannot_represent.
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/XoAnonXo/XOaura/releases/download/v0.3.10/aura-0.3.10-aarch64-apple-darwin.tar.gz"
      sha256 "ff9670bb716958cabe8af547cd940910debcf398baa4180d10b523522cced479"
    end
    on_intel do
      url "https://github.com/XoAnonXo/XOaura/releases/download/v0.3.10/aura-0.3.10-x86_64-apple-darwin.tar.gz"
      sha256 "72a1196dc8446319d9adbe7b0ac713f30fe61209c043e7f1e968b545b60223ca"
    end
  end

  def install
    bin.install "bin/aura"
    bin.install "bin/AuraSwiftFrontend" => "aura-swift"
    # Legacy rollback app. Keep it out of PATH so Swift is the
    # canonical desktop surface, but ship it for emergency rollback.
    libexec.install "bin/aura-orb" => "aura-orb-legacy"
    # Stage the plugin tree so post_install can wire it into
    # the user's ~/.claude/plugins/ via aura register-plugin.
    # Use rename-install (`share.install "plugin" => "claude-aura"`)
    # rather than Dir["plugin/*"] — the latter does NOT match
    # dotfiles, so .claude-plugin/plugin.json (the critical
    # manifest aura register-plugin reads for version) would be
    # silently skipped.
    share.install "plugin" => "claude-aura"
    (share/"aura").install "install.sh", ".agents"
    prefix.install "README.md", "LICENSE" if File.exist?("LICENSE")
  end

  def post_install
    # aura register-plugin is non-interactive — no network,
    # no Keychain, no prompts. Idempotent upsert into
    # ~/.claude/plugins/installed_plugins.json.
    system "#{bin}/aura", "register-plugin",
           "--source", "#{share}/claude-aura"
  end

  def caveats
    <<~EOS
      Aura is installed. To start a voice call:

        aura call --onboarding

      To open the Swift desktop app from Terminal:

        aura-swift

      The first call asks for microphone access — click OK.
      Release builds include Aura activation for Codex
      onboarding, while Claude installs can also refresh
      activation through Claude Code OAuth.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aura --version")
  end
end
