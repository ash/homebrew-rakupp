# homebrew-rakupp

Homebrew tap for [rakupp](https://github.com/ash/rakupp) — a from-scratch Raku
implementation in C++17 (interpreter + native compiler).

## Install

```sh
brew install ash/rakupp/rakupp
```

or:

```sh
brew tap ash/rakupp
brew install rakupp
```

Track the development branch instead of the latest release:

```sh
brew install --HEAD ash/rakupp/rakupp
```

## Verify

```sh
rakupp -e 'say "hello, world"'
rakupp -e 'say (1..100).grep(*.is-prime).sum'   # → 1060
```
