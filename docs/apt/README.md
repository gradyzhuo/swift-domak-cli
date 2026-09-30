# domak APT repository

Published at `https://gradyzhuo.github.io/swift-domak-cli/apt/` by the
`pages.yml` GitHub Pages workflow (this directory is under `docs/`, which
that workflow watches).

Managed by [`reprepro`](https://mirrorer.alioth.debian.org/) — `conf/distributions`
is the only hand-maintained file; `db/`, `dists/`, and `pool/` are reprepro's
generated state (created on the first tagged release) and are committed as-is
so that `.github/workflows/release.yml` can add new `.deb`s incrementally on
every tagged release instead of rebuilding the repo from scratch.

`pubkey.gpg` is the repo's public signing key (private half lives only in the
`APT_SIGNING_KEY` repo secret, used by CI to sign `Release`).

## Install (end users)

```bash
curl -fsSL https://gradyzhuo.github.io/swift-domak-cli/apt/pubkey.gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/domak.gpg
echo "deb [signed-by=/usr/share/keyrings/domak.gpg] https://gradyzhuo.github.io/swift-domak-cli/apt stable main" \
  | sudo tee /etc/apt/sources.list.d/domak.list
sudo apt update && sudo apt install domak
```
