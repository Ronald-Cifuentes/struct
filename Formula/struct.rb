# curl -L https://github.com/Ronald-Cifuentes/struct/archive/refs/tags/v1.0.0.tar.gz | shasum -a 256

class Struct < Formula
  desc "A CLI tool to generate folder structures like tree"
  homepage "https://github.com/Ronald-Cifuentes/struct"
  url "https://github.com/Ronald-Cifuentes/struct/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "759109173d59b726677286f72e56c941bdf3c078e84be268d54bbc2288e5f26f"
  license "MIT"

  def install
    bin.install "bin/struct.sh" => "struct"
  end

  test do
    # Simple test to verify installation
    system "#{bin}/struct", "--help"
  end
end