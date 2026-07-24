class Rmd < Formula
  desc "Render a markdown file into a self-contained HTML page in the browser"
  homepage "https://github.com/dsbasko/rmd"
  url "https://github.com/dsbasko/rmd/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "d27aa8e554c16a44e39ada6c771238200d136c77ca625239d71866668610a1dd"
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
