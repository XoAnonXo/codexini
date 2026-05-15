class Aura < Formula
  desc "Local voice bridge for Claude Code and Codex"
  homepage "https://codexini.com"
  version "0.3.11"
  # Proprietary, all rights reserved. The repo is public for
  # auditability + brew distribution, but use beyond running the
  # signed binaries from this tap requires explicit written
  # permission (see LICENSE in the source repo). Homebrew's DSL
  # represents non-SPDX licenses with :cannot_represent.
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/XoAnonXo/XOaura/releases/download/v0.3.11/aura-0.3.11-aarch64-apple-darwin.tar.gz"
      sha256 "e10f636d7d42cf2e6f0707a42d5a6207050f7e95d5baa07e5aba8dcdbebc8e2c"
    end
    on_intel do
      url "https://github.com/XoAnonXo/XOaura/releases/download/v0.3.11/aura-0.3.11-x86_64-apple-darwin.tar.gz"
      sha256 "5e032f68c5efe13fbec2dd1f9abf06c08eeeee5ad52b4d60a050f5c4b1f8b588"
    end
  end

  def install
    bin.install "bin/aura"
    bin.install "bin/AuraSwiftFrontend" => "aura-swift"
    # Legacy rollback app is optional and absent from normal releases.
    if File.exist?("bin/aura-orb")
      libexec.install "bin/aura-orb" => "aura-orb-legacy"
    end
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
