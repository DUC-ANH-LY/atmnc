# CVE-2019-10740 educational PoC (multipart wrap)

Local-only demo of the **MIME packaging** pattern described in [CVE-2019-10740](https://nvd.nist.gov/vuln/detail/CVE-2019-10740): an attacker can **wrap** stolen **S/MIME** ciphertext as **nested multipart** sub-parts and re-send. In **Roundcube Webmail before 1.3.10**, a victim who **replies** in a real mail client could unknowingly **quote decrypted plaintext** back to the attacker ([roundcube#6638](https://github.com/roundcube/roundcubemail/issues/6638)).

This folder only builds a **`.eml` file** that embeds PKCS#7 from the **normal S/MIME demo** ([../smime-demo/README.md](../smime-demo/README.md)). It does **not** include a mail server or Roundcube.

## Prerequisites

- `bash`, `openssl`
- [../smime-demo/demo_out/encrypted.pem](../smime-demo/demo_out/encrypted.pem) exists — run the normal demo first:

```bash
./smime-demo/scripts/run_all.sh
```

## Run

From the repository root:

```bash
./poc_cve_2019_10740/scripts/run_poc.sh
```

Output: `poc_cve_2019_10740/demo_out/cve_2019_10740_trap.eml`

Confirm the inner envelope matches the lab ciphertext:

```bash
openssl smime -decrypt -in smime-demo/demo_out/encrypted.pem \
  -recip smime-demo/demo_out/bob.crt -inkey smime-demo/demo_out/bob.key
```

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/01_crafted_trap_email.sh` | Reads `smime-demo/demo_out/encrypted.pem` → writes `demo_out/cve_2019_10740_trap.eml` |
| `scripts/run_poc.sh` | Runs the step above |

## Mitigation

Upgrade Roundcube to **1.3.10 or later** (see [NVD](https://nvd.nist.gov/vuln/detail/CVE-2019-10740)).
