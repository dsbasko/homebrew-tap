class Rmd < Formula
  desc "Render markdown files into one self-contained HTML page in the browser"
  homepage "https://github.com/dsbasko/rmd"
  url "https://github.com/dsbasko/rmd/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "e1beab7d212635d2673714f16ca40efca15b73399938f4dbd2a077b2149f2a72"
  license "MIT"
  head "https://github.com/dsbasko/rmd.git", branch: "main"

  depends_on "go" => :build

  def install
    # All page assets (fonts, mermaid, KaTeX) are committed and embedded via
    # go:embed, so the build itself needs no network access.
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=#{version}"),
           "./cmd/rmd"
  end

  test do
    assert_match "rmd version #{version}", shell_output("#{bin}/rmd -version")
    # No file argument is a usage error: shell_output asserts the exit status.
    shell_output("#{bin}/rmd 2>&1", 2)
  end
end
