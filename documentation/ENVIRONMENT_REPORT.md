# ShopyHapy – Environment Report (Stage 0)

Inspection date: 2026-11-11

> **Scope of this report.** It describes the **Claude Code cloud workspace** where the work is currently being done
> (Ubuntu 24.04 Linux VM). It does **not** describe your Windows PC
> (`C:\Users\ADMIN\Desktop\claude\shopyhapy\...`). To inspect your own machine, run
> `scripts/check-environment.ps1` (Windows) or `scripts/check-environment.sh` (macOS/Linux) and compare the output
> with the "Required" column below.

## 1. Repository state

| Item | Finding |
|---|---|
| Remote | `https://github.com/storesms2016-hub/shopyhapy` (public) |
| Branches at start | `main` only |
| History at start | One commit: `41e1fc6 Initial commit` |
| Existing files at start | `README.md` (contains only the line `# shopyhapy`) |
| Existing application code | **None** – this is a greenfield repository |
| Conflicts / files overwritten | None. `README.md` is extended, not replaced |

The Windows folder you mentioned is not reachable from the cloud workspace and no code from it is in the GitHub repo.
If it contains code you want kept, push it to a branch and tell me; nothing here assumes it exists.

## 2. Tool inventory (cloud workspace)

| Tool | Found | Required for ShopyHapy | Status |
|---|---|---|---|
| OS | Ubuntu 24.04.5 LTS, 2 vCPU, 7.8 GB RAM, ~31 GB free disk | – | OK for development; tight for parallel Android/Gradle + MySQL |
| Java (JDK) | OpenJDK 21.0.12 (`JAVA_HOME` set) | 21 LTS | OK |
| Maven | 3.9.11 | 3.9+ | OK (but cannot download dependencies – see §3) |
| Gradle | 8.14.3 | not used | Ignore |
| Node.js | 22.23.4 | `^22.22.3 \|\| ^24.15.0 \|\| >=26` (Angular 22.2.5 `engines`) | OK |
| npm | 10.9.9 | 10+ | OK |
| Angular CLI (`ng`) | **Not installed** | 22.2.x | Install at Stage 5 (project-local, via `npx`) |
| Ionic CLI (`ionic`) | **Not installed** | 7.2.1 (optional) | Install at Stage 5 only if needed |
| Capacitor CLI | **Not installed** | 8.6.0 | Project-local dev dependency at Stage 5 |
| MySQL server/client | **Not installed** | 8.4 LTS | Not available – see §3 |
| Docker CLI / Compose | 29.9.3 / v5.7.0 | recent | CLI present, but **no Docker daemon** (`/var/run/docker.sock` missing) |
| Redis | 7.0.15 | optional cache | Present |
| Nginx | **Not installed** | reverse proxy | Production only (container image) |
| Git | 2.43.0 | any recent | OK |
| GitHub CLI (`gh`) | 2.89.0 | optional | Present (scoped to attached repo only) |
| Python | 3.13.18 | helper scripts only | OK |
| Google Chrome | `/usr/bin/google-chrome` | UI tests / E2E | Present |
| Android SDK | **Not installed** (`ANDROID_HOME` unset) | Android builds | Missing |
| Xcode / macOS | **Not possible** on Linux | iOS builds | Missing (needs a Mac) |

No packages were installed during Stage 0.

## 3. Network policy (important)

Outbound HTTPS from the workspace goes through a policy proxy. Tests run on 2026-11-11:

| Host | Result | Impact |
|---|---|---|
| `registry.npmjs.org` | Reachable | Angular/Ionic/Capacitor/PrimeNG installs work |
| `pypi.org`, `archive.ubuntu.com` | Reachable | apt/pip work |
| `github.com`, `api.github.com` (attached repo only) | Reachable | Clone/push work |
| `repo.maven.apache.org`, `repo1.maven.org` | **Blocked (HTTP 403 on CONNECT)** | **`mvn` cannot download Spring Boot or any other dependency here** |
| `start.spring.io` | **Blocked** | Cannot use Spring Initializr here |
| `registry-1.docker.io` / Docker Hub, `ghcr.io`, `quay.io` | **Blocked** | Cannot pull MySQL/Redis/Nginx images |
| `dl.google.com` | **Blocked** | Cannot download the Android SDK |
| `dev.mysql.com`, `repo.mysql.com` | **Blocked** | Cannot fetch MySQL 8.4 from Oracle |

These are policy denials, not outages. They were not worked around.

### What this means per stage

| Stage | Can it be fully built and tested in the cloud workspace? |
|---|---|
| 1 – Database | Documents and Flyway SQL: yes. Running the SQL against a real server: only with MySQL **8.0** from Ubuntu's apt (EOL, not the 8.4 LTS target) – needs your approval first |
| 2–4 – Backend | **No** until Maven Central is allowed (or the work moves to your machine/CI) |
| 3, 4, 14 – Testcontainers integration tests | **No** – there is no Docker daemon and Docker Hub is blocked. Must run on your machine or in GitHub Actions |
| 5–8, 11, 12 – Angular/Ionic web apps | **Yes** (npm works; Chrome is present) |
| 5, 15 – Android build | **No** (SDK host blocked). Run on your machine or CI |
| 5, 15 – iOS build | **No** (needs macOS). Run on a Mac or a GitHub `macos` runner |
| 9 – Razorpay | Code and unit tests: yes (once backend builds). Live test-mode payments need your Razorpay test keys and a public webhook URL |
| 13 – FCM/email | Needs your Firebase project and SMTP credentials |

### Ways to unblock (your choice)

1. **Allow Maven Central for this session.** The proxy reports that on the Free plan, package-manager domains can be allowed
   in claude.ai → Settings → Capabilities. Adding `repo.maven.apache.org` (and `repo1.maven.org`) would let `mvn` work here.
   I have not verified that this setting takes effect for this session.
2. **Build the backend on your own machine** (JDK 21 + Maven + MySQL 8.4 or Docker Desktop) and have me write the code and tests.
3. **GitHub Actions CI** (recommended regardless): runners provide Docker, so Testcontainers, `mvn verify`, Angular builds and
   (with macOS runners) iOS builds can run there automatically on every push. I would add the workflow in Stage 2.

## 4. Compatibility findings

| Finding | Detail |
|---|---|
| TypeScript trap | `npm` currently resolves `typescript@latest` to **7.0.2**, but `@angular/compiler-cli@22.2.5` requires `typescript >=6.0 <6.1`. TypeScript **must be pinned to 6.0.x** in both Angular apps. |
| Node | Angular 22.2.5 requires Node `^22.22.3 \|\| ^24.15.0 \|\| >=26`. The workspace's 22.23.4 qualifies. Your PC must meet the same range. |
| Angular ↔ PrimeNG | PrimeNG 22.1.4 requires `@angular/core`/`cdk`/`forms`/`router` `^22.1.0` – compatible with Angular 22.2.x. |
| Angular ↔ Ionic | `@ionic/angular` 9.0.10 accepts `@angular/core >=18` – compatible. It also lists `zone.js >=0.13` as a peer, so zoneless mode must be verified in the Stage 5 spike. |
| Capacitor | 8.6.0 requires Node `>=22`; Firebase plugin `@capacitor-firebase/messaging` 8.6.0 needs `firebase ^12.6.0`. |
| Spring Boot 3.x | **All 3.x lines are out of open-source support** (3.5 ended June 2026). Plan uses Spring Boot 4.1.x. See `TECHNICAL_DECISIONS.md` TD-01. |
| MySQL 8.0 | End of life since April 2026. Plan uses MySQL **8.4 LTS**. |
| Razorpay Capacitor plugin | No Razorpay-published npm plugin was confirmed. Community package `capacitor-razorpay` 1.3.0 accepts Capacitor `>=7`. Must be validated at Stage 9. |

## 5. Commands executed in Stage 0 (all read-only)

```
git status / branch / remote / log
uname, /etc/os-release, nproc, free, df
java -version, javac -version, mvn -version, gradle -v
node -v, npm -v, ng version, ionic --version, npx --no-install cap --version
docker --version, docker compose version, docker info, mysql --version, redis-server --version, nginx -v
curl -I against npm, Maven Central, Docker Hub, GitHub, Google, MySQL, Ubuntu, PyPI hosts
npm view <package> version | peerDependencies | engines     (registry metadata only, nothing installed)
curl http://127.0.0.1:<proxy>/__agentproxy/status
```

## 6. Open environment actions for you

- Decide which unblock option in §3 you want before Stage 2.
- Run the environment script on your PC and share the output if you want builds to happen locally.
- Provide, when the relevant stage arrives: Razorpay **test** key id/secret and webhook secret, Firebase project/service account, SMTP
  credentials, SMS gateway credentials, object-storage credentials. Nothing is hardcoded; all will be read from environment variables.
