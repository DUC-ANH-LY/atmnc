# S/MIME demo (Shell + OpenSSL)

Standalone **normal-flow** lab: sign, verify, encrypt, and decrypt using PEM certificates and OpenSSL’s `smime` command. **CVE-related demos** live in sibling folders at the repository root (`poc_cve_*`, `CVE-*`), not here.

- **Sign** — Alice’s private key produces a CMS/PKCS#7 signature over the message; verifiers use Alice’s certificate and trust in the issuing CA.
- **Encrypt** — The message is encrypted for **Bob’s public key** (from Bob’s certificate); only Bob’s private key can decrypt.

This is for **learning only**. Keys and the demo CA are generated locally and are **not** safe for production.

## Prerequisites

- `bash`
- `openssl` on your `PATH`

## Run

From the repository root:

```bash
./smime-demo/scripts/run_all.sh
```

Or from this directory:

```bash
./scripts/run_all.sh
```

That creates `demo_out/`, generates a demo CA plus Alice and Bob certificates, signs and verifies [messages/hello.txt](messages/hello.txt), then encrypts and decrypts the same file. After a successful run:

- [demo_out/decrypted.txt](demo_out/decrypted.txt) matches the plaintext in `messages/hello.txt` (line endings normalized).
- [demo_out/signed.pem](demo_out/signed.pem) holds the S/MIME signature; verification runs during step 2 (output path is printed to the terminal).

OpenSSL often writes **CRLF** line endings and, with `-text` signing, a short **MIME header** before the body. The decrypt script normalizes line endings to Unix **LF** in `decrypted.txt`.

## Diagrams

### Full demo flow (flowchart)

```mermaid
flowchart TB
  runAll[run_all.sh]
  subgraph step01 [01_gen_certs]
    caMat[ca.key and ca.crt]
    aliceMat[alice.key and alice.crt]
    bobMat[bob.key and bob.crt]
    caMat --> aliceMat
    caMat --> bobMat
  end
  plain[hello.txt]
  subgraph step02 [02_sign_verify]
    signOp[openssl smime sign]
    signedOut[signed.pem]
    verifyOp[openssl smime verify]
    recvSig[verify output temp]
    signOp --> signedOut --> verifyOp --> recvSig
  end
  subgraph step03 [03_encrypt_decrypt]
    encOp[openssl smime encrypt]
    encOut[encrypted.pem]
    decOp[openssl smime decrypt]
    decPlain[decrypted.txt]
    encOp --> encOut --> decOp --> decPlain
  end
  runAll --> step01
  step01 --> step02
  step01 --> step03
  plain --> signOp
  plain --> encOp
  aliceMat --> signOp
  caMat --> verifyOp
  bobMat --> encOp
  bobMat --> decOp
```

### Alice, Bob, and CA (full sequence diagram)

```mermaid
sequenceDiagram
  participant run as run_all.sh
  participant ca as Demo_CA
  participant alice as Alice
  participant bob as Bob
  participant plain as hello.txt
  participant out as demo_out
  participant openssl as OpenSSL

  run->>out: create/refresh demo_out

  Note over run,bob: Step 1 - 01_gen_certs
  run->>openssl: generate CA keypair and cert
  openssl-->>ca: ca.key + ca.crt
  run->>openssl: generate Alice key + CSR
  run->>openssl: sign Alice CSR with CA
  ca->>alice: alice.key alice.crt
  run->>openssl: generate Bob key + CSR
  run->>openssl: sign Bob CSR with CA
  ca->>bob: bob.key bob.crt
  ca->>out: ca.crt

  Note over run,ca: Step 2 - 02_sign_verify
  run->>alice: invoke signing with alice.key/alice.crt
  alice->>plain: read
  alice->>openssl: smime -sign
  openssl-->>out: signed.pem
  run->>openssl: smime -verify with -CAfile ca.crt
  openssl->>out: read signed.pem
  openssl->>ca: validate signer chain to trusted CA
  openssl-->>out: verified_message.txt

  Note over run,bob: Step 3 - 03_encrypt_decrypt
  run->>alice: invoke encryption for Bob
  alice->>plain: read
  alice->>openssl: smime -encrypt with bob.crt
  openssl-->>out: encrypted.pem
  run->>bob: invoke decryption with bob.key
  bob->>openssl: smime -decrypt
  openssl->>out: read encrypted.pem
  openssl-->>out: decrypted.txt

  Note over out: decrypted.txt should match hello.txt
```
