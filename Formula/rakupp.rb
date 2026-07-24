class Rakupp < Formula
  desc "From-scratch Raku implementation in C++17 (interpreter + native compiler)"
  homepage "https://github.com/ash/rakupp"
  url "https://github.com/ash/rakupp/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "e421d96443cf12e0628318d2012da3aeb83c88f7695b8fbd08ee44690f304b8a"
  license "Artistic-2.0"

  head "https://github.com/ash/rakupp.git", branch: "main" do
    depends_on "cmake" => :build
  end

  # macOS installs the prebuilt universal binary (arm64 + x86_64, macOS 11+) —
  # no compile on either architecture. Linux builds from the source tarball.
  on_macos do
    url "https://github.com/ash/rakupp/releases/download/v1.1.0/rakupp-macos-universal.tar.gz"
    sha256 "23a1c7548abc34fb6384cf16e7c06010b8267acb8b2fd7466f919898ea916635"
    version "1.1.0"
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
