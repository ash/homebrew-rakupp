class Rakupp < Formula
  desc "From-scratch Raku implementation in C++17 (interpreter + native compiler)"
  homepage "https://github.com/ash/rakupp"
  url "https://github.com/ash/rakupp/archive/refs/tags/v0.7.1.tar.gz"
  sha256 "89a7210cb3af8b043b544aeaacc8e6daacdc30c2815eab4e84817fc0d430a6ad"
  license "Artistic-2.0"

  head "https://github.com/ash/rakupp.git", branch: "main" do
    depends_on "cmake" => :build
  end

  # macOS installs the prebuilt universal binary (arm64 + x86_64, macOS 11+) —
  # no compile on either architecture. Linux builds from the source tarball.
  on_macos do
    url "https://github.com/ash/rakupp/releases/download/v0.7.1/rakupp-macos-universal.tar.gz"
    sha256 "2a3e546dfa468822f36d3e826ba9f8e4848c8438b9bae798be314abd790c2725"
    version "0.7.1"
  end
  on_linux do
    depends_on "cmake" => :build
  end

  def install
    if File.exist?("bin/rakupp")
      # Prebuilt binary tarball: bin/, lib/librakupp_rt.a, include/rakupp/*.
      bin.install "bin/rakupp"
      lib.install "lib/librakupp_rt.a"
      (include/"rakupp").install Dir["include/rakupp/*"]
    else
      # Source build. findRuntime() resolves the symlinked binary back into the
      # Cellar, so `--exe` locates the runtime library and headers automatically.
      system "cmake", "-S", ".", "-B", "build", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end
  end

  test do
    assert_equal "3", shell_output("#{bin}/rakupp -e 'say 1 + 2'").strip
    assert_equal "1267650600228229401496703205376",
                 shell_output("#{bin}/rakupp -e 'say 2 ** 100'").strip
  end
end
