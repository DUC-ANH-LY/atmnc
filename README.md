# atmnc — S/MIME demos

This repository has two kinds of content:

| Area | Path | Purpose |
|------|------|--------|
| **Normal S/MIME flow** | [smime-demo/](smime-demo/) | Local CA, Alice/Bob certs, sign/verify, encrypt/decrypt with OpenSSL `smime` — **no CVE harness**. |
| **CVE educational PoCs** | `poc_cve_*`, `CVE-*` | Isolated labs; see each folder’s README. |

## Normal flow (start here)

```bash
./smime-demo/scripts/run_all.sh
```

Full explanation and diagrams: [smime-demo/README.md](smime-demo/README.md).

## CVE-2019-10740 (educational PoC)

Multipart **`.eml`** embedding PKCS#7 from the normal demo’s `encrypted.pem`. Requires [smime-demo/demo_out/encrypted.pem](smime-demo/demo_out/encrypted.pem) (run the normal flow first):

```bash
./smime-demo/scripts/run_all.sh
./poc_cve_2019_10740/scripts/run_poc.sh
```

See [poc_cve_2019_10740/README.md](poc_cve_2019_10740/README.md).

## CVE-2025-15467 (OpenSSL CMS AEAD)

Docker PoC using artifacts from the normal demo. Details: [CVE-2025-15467/README.md](CVE-2025-15467/README.md).

```bash
./CVE-2025-15467/run.sh
```

## CVE-2026-2748 educational PoC

See [poc_cve_2026_2748/README.md](poc_cve_2026_2748/README.md).

```bash
./poc_cve_2026_2748/scripts/run_poc.sh
```
