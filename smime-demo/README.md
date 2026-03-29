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

### Alice, Bob, and CA (sequence diagram)

```mermaid
sequenceDiagram
  participant ca as Demo_CA
  participant alice as Alice
  participant bob as Bob
  participant plain as hello.txt
  participant out as demo_out
  Note over ca,bob: 01_gen_certs
  ca->>alice: alice.key alice.crt
  ca->>bob: bob.key bob.crt
  ca->>out: ca.crt
  Note over alice,out: 02_sign_verify
  alice->>plain: read
  alice->>out: sign with Alice private key to signed.pem
  out->>ca: verify signer chains to CA
  Note over alice,bob: 03_encrypt_decrypt
  alice->>plain: read
  alice->>out: encrypt for Bob using bob.crt to encrypted.pem
  bob->>out: decrypt with bob.key to decrypted.txt
```
