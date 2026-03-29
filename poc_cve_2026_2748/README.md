# CVE-2026-2748 educational PoC (whitespace in S/MIME cert email)

This folder is a **lab-only** demonstration of the **identity-binding** problem described around [CVE-2026-2748](https://www.sentinelone.com/vulnerability-database/cve-2026-2748/): **SEPPmail Secure Email Gateway** before **15.0.1** could mishandle S/MIME certificates whose **rfc822Name** (email in Subject Alternative Name) contains **whitespace**, leading to **improper certificate validation** (CWE-295) and **signature spoofing** from the recipient’s point of view.

This repository does **not** contain SEPPmail. The scripts **model** the issue: **OpenSSL `smime -verify`** confirms the **cryptographic** signature and trust chain, while a **separate** “gateway” check decides whether the **signer’s certificate email** is allowed to match the message **From** address.

## Ethics and scope

Use this only on systems you own or are explicitly authorized to test. Do not use it to mislead people or to attack production mail infrastructure. The demo CA and certificates are **fake** and exist only under `demo_out/`.

## What you will observe

1. A **demo CA** issues an **attacker** certificate whose SAN email is literally `ceo@ company.com` (note the space).
2. A signed S/MIME message uses **`From: ceo@company.com`** (no space).
3. **`openssl smime -verify`** succeeds: the signature is **valid** and chains to the demo CA.
4. A **naïve binding** rule that **removes all whitespace** before comparing addresses wrongly says **MATCH**.
5. A **strict binding** rule that **rejects** any SAN email containing whitespace matches the **vendor fix description** (normalize/reject malformed addresses) and **REJECT**s this certificate.

Official product detail and patching: follow **SEPPmail** advisories (e.g. upgrade to **15.0.1+**). Third-party summaries: [SentinelOne CVE-2026-2748](https://www.sentinelone.com/vulnerability-database/cve-2026-2748/).

## Prerequisites

- `bash`
- `python3` (stdlib only)
- `openssl` **3.x** recommended (`-addext` / `-copy_extensions` as used in the scripts)

## Run

From the repository root:

```bash
./poc_cve_2026_2748/scripts/run_poc.sh
```

Or from this directory:

```bash
./scripts/run_poc.sh
```

Artifacts are written to `demo_out/` (ignored by git via `.gitignore`).

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/01_gen_ca_and_attacker.sh` | Demo CA; attacker key/cert with `subjectAltName=email:ceo@ company.com` |
| `scripts/02_build_and_sign_message.sh` | Builds `unsigned_message.eml` with `From: ceo@company.com`, outputs `signed_spoof.pem` |
| `scripts/03_gateway_binding_check.py` | Runs verify, extracts signer SAN email, prints **vulnerable** vs **strict** binding outcomes |
| `scripts/run_poc.sh` | Runs the three steps in order |

## Mitigation (defensive)

- **Product**: upgrade affected SEPPmail gateways per vendor guidance (**≥ 15.0.1** for this CVE class).
- **Custom validators**: treat rfc822Name values with **embedded ASCII whitespace** as **invalid** for identity binding, or apply **strict RFC 5322** parsing and **reject** non-conforming addresses before comparing to `From`.
