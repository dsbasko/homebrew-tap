class Dndmode < Formula
  desc "Keep macOS awake and shield all displays with a black lock overlay"
  homepage "https://github.com/dsbasko/dndmode"
  url "https://github.com/dsbasko/dndmode/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "6e4dd94748a39ee50c6bbccbe3bf432014c70468e8262e89f7bfe3652ff84200"
  license "MIT"
  head "https://github.com/dsbasko/dndmode.git", branch: "main"

  depends_on "go" => :build
  depends_on arch: :arm64      # Apple Silicon only
  depends_on macos: :sonoma    # cgo built with -mmacosx-version-min=14.0

  def install
    ENV["CGO_ENABLED"] = "1"
    system "go", "build", *std_go_args(output: bin/"dndmode"), "./cmd/dndmode"

    # Re-apply the ad-hoc signature with the stable identifier the binary
    # relies on for Accessibility (TCC) and to avoid the stale-signature SIGKILL
    # on Apple Silicon. `go build` does not sign, so this must run every build.
    system "codesign", "--force", "--sign", "-",
           "--identifier", "com.dsbasko.dndmode", bin/"dndmode"
  end

  def caveats
    <<~EOS
      dndmode requires the Accessibility permission to intercept input:
        System Settings -> Privacy & Security -> Accessibility

      Because the binary is ad-hoc signed, its code identity changes on every
      build, so you must re-grant Accessibility after each `brew upgrade`.
    EOS
  end

  test do
    # Go's flag package prints usage and exits 2; assert the binary runs.
    assert_match "timer", shell_output("#{bin}/dndmode --help 2>&1", 2)
  end
end
