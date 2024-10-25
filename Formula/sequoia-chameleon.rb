class SequoiaChameleon < Formula
  desc "Reimplementation of gpg and gpgv using Sequoia"
  homepage "https://sequoia-pgp.org"
  url "https://gitlab.com/sequoia-pgp/sequoia-chameleon-gnupg/-/archive/v0.11.2/sequoia-chameleon-gnupg-v0.11.2.tar.gz"
  sha256 "e254146d42facc704bd68c33fec174f15edf6921dd1bc578b37c93ae61c99781"
  license "GPL-3.0-or-later"

  depends_on "rust" => :build

  # the test suite needs a `gpgconf` executable in path
  depends_on "gnupg" => :test

  depends_on "gmp"
  depends_on "nettle"
  depends_on "openssl@3"

  uses_from_macos "bzip2"
  uses_from_macos "sqlite"

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    (testpath / "batch.gpg").write <<~EOS
      Key-Type: RSA
      Key-Length: 4096
      Subkey-Type: RSA
      Subkey-Length: 2048
      Name-Real: Alice
      Name-Email: alice@foo.bar
      Expire-Date: 1d
      %no-protection
      %commit
      Key-Type: RSA
      Key-Length: 4096
      Subkey-Type: RSA
      Subkey-Length: 2048
      Name-Real: Bob
      Name-Email: bob@foo.bar
      Expire-Date: 1d
      %no-protection
      %commit
    EOS
    begin
      mkdir testpath / ".gnupg"
      chmod 0700, ".gnupg"

      system bin / "gpg-sq", "--verbose", "--batch", "--gen-key", "batch.gpg"
      (testpath / "test.txt").write "Hello World!"
      system bin / "gpg-sq", "--verbose", "--sign", "--encrypt", "--local-user", "alice@foo.bar", "--recipient",
"bob@foo.bar", "--output", "test.gpg", "test.txt"
      system bin / "gpg-sq", "--verbose", "--decrypt", "--local-user", "bob@foo.bar", "--output", "test2.txt",
"test.gpg"
      (testpath / "test.txt").read == (testpath / "test2.txt").read
    end
  end
end
