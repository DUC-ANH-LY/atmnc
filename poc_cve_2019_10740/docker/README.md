# Docker: Roundcube 1.3.9 + GreenMail

Vulnerable **[Roundcube 1.3.9](https://github.com/roundcube/roundcubemail/releases/tag/1.3.9)** (before the [1.3.10](https://github.com/roundcube/roundcubemail/releases/tag/1.3.10) fix) plus **[GreenMail](https://greenmail-mail-test.github.io/greenmail/)** for IMAP/SMTP.

- **Roundcube:** http://127.0.0.1:8080/
- **GreenMail SMTP:** 127.0.0.1:3025  
- **GreenMail IMAP:** 127.0.0.1:3143  

Test users (see `docker-compose.yml`):

| Mailbox            | Password    |
|--------------------|------------|
| `victim@localhost` | `victimpass` |
| `attacker@localhost` | `attackpass` |

From the repository root, the full scripted demo (build, start, generate trap, inject mail, print steps) is:

```bash
./poc_cve_2019_10740/scripts/run_full_stack_demo.sh
```

Stop:

```bash
docker compose -f poc_cve_2019_10740/docker/docker-compose.yml --project-directory poc_cve_2019_10740/docker down
```

The Roundcube image bakes in a SQLite DB created from `SQL/sqlite.initial.sql` (see `Dockerfile`). This is lab-only; do not expose on a public network.
