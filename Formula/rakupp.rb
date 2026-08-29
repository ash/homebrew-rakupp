# NOTE ON VERSION ORDERING — read before bumping.
#
# Homebrew compares versions token by token, numerically, so it ranks
# **3.14.0 ABOVE 3.7.0** (14 > 7). Upstream's v3.14.0 is a pi joke tagged on
# 2026-08-11, BETWEEN v3.1.0 and v3.5.0 — it is four releases OLDER than
# v3.7.0, not newer.
#
# Consequence, and it is not a mistake in this file: anyone who installed
# while the formula pinned 3.14.0 will never be offered 3.7.0 by
# `brew upgrade` — brew believes they already have something newer. A fresh
# `brew install rakupp` gets 3.7.0 correctly. There is no formula-level fix:
# Homebrew has no epoch for this, and `revision` only breaks ties within one
# version.
#
# It resolves at the next release, deliberately: upstream's policy is now
# plain monotonic versions and no cute numbers, with **the next release at
# least 3.20.0** precisely so it clears 3.14.0 and those users get offered
# the upgrade. See docs/dev/RELEASING.md, "Picking the number".
#
# So: do not "correct" a bump that looks like a downgrade. Check the TAG DATE
# against CHANGELOG.md, not the number.
class Rakupp < Formula
  desc "From-scratch Raku implementation in C++17 (interpreter + native compiler)"
  homepage "https://github.com/ash/rakupp"
  url "https://github.com/ash/rakupp/archive/refs/tags/v3.23.0.tar.gz"
  sha256 "6bdd2c6e393179c836fd56eb86b4dfacb9ec6bd9a8094c12c9857956a77bae12"
  license "Artistic-2.0"

  head "https://github.com/ash/rakupp.git", branch: "main" do
    depends_on "cmake" => :build
  end

  # macOS installs the prebuilt universal binary (arm64 + x86_64, macOS 11+) —
  # no compile on either architecture. Linux builds from the source tarball.
  on_macos do
    url "https://github.com/ash/rakupp/releases/download/v3.23.0/rakupp-macos-universal.tar.gz"
    sha256 "7c67ee6628a836665f790ec4655c58e5fa45c4c2b1b0725a35787f00c546f570"
    version "3.23.0"
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
