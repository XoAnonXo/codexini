class Aura < Formula
  desc "Local voice bridge for Claude Code and Codex"
  homepage "https://codexini.com"
  version "0.3.1"
  # Proprietary, all rights reserved. The repo is public for
  # auditability + brew distribution, but use beyond running the
  # signed binaries from this tap requires explicit written
  # permission (see LICENSE in the source repo). Homebrew's DSL
  # represents non-SPDX licenses with :cannot_represent.
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/XoAnonXo/XOaura/releases/download/v0.3.1/aura-0.3.1-aarch64-apple-darwin.tar.gz"
      sha256 "b3a0e4820ffd2b04dca08941cfaae1728bda6b7737ba5fda9efbaf81bbef00a6"
    end
    on_intel do
      url "https://github.com/XoAnonXo/XOaura/releases/download/v0.3.1/aura-0.3.1-x86_64-apple-darwin.tar.gz"
      sha256 "3c0771ab436db4e4fa2c5ecbc6d6d657c416d0b5ba62d5fb04d0108b27c52df1"
    end
  end

  def install
    bin.install "bin/aura"
    bin.install "bin/aura-orb"
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

      On the very first launch, macOS may show a Gatekeeper
      dialog: "macOS cannot verify aura is free of malware."
      Click Open. Aura is signed with a real Developer ID
      cert (Apple Team TVN7W8K9JV) — Apple's notary queue is
      occasionally backlogged so some releases ship signed
      but not yet fully notarized. The signature is still
      verified.

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
