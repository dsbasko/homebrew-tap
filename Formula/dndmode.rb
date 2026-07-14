class Dndmode < Formula
  desc "Keep macOS awake and shield all displays with a black lock overlay"
  homepage "https://github.com/dsbasko/dndmode"
  url "https://github.com/dsbasko/dndmode/archive/refs/tags/v1.3.0.tar.gz"
  sha256 "db3422e8bd80969b73b986b0bce93cc868459c3f4d3ea2279564a2e245128810"
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
    # dndmode is a cgo/AppKit binary; running it under the sandboxed test
    # environment blocks on window-server framework init, so instead verify the
    # install step applied the ad-hoc signature with the stable identifier that
    # Accessibility (TCC) depends on.
    assert_path_exists bin/"dndmode"
    assert_match "Identifier=com.dsbasko.dndmode",
      shell_output("codesign -dvv #{bin}/dndmode 2>&1")
  end
end
