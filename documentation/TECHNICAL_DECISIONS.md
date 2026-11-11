# ShopyHapy – Technical Decisions

Status: **Stage 0 – all entries are PROPOSED until you approve Stage 0** · Last updated: 2026-11-11

Versions below were checked on 2026-11-11 against the npm registry (queried live) and the web pages listed in §4. Backend library
versions that live on Maven Central **could not be verified from the cloud workspace** (blocked); they will be pinned at Stage 2
from the Spring Boot BOM and the official release pages.

## 1. Decision log

| ID | Decision | Why (evidence) | Alternatives considered |
|---|---|---|---|
| TD-01 | **Spring Boot 4.1.x** (not 3.x) | Every 3.x line is out of open-source support; 3.5 ended June 2026. 4.0 ends 31 Dec 2026 (too soon). 4.1 was the newest line confirmed (4.1.2 on 20 Oct 2026), supported to 31 Jul 2027. Your spec allows "3.x *or compatible current stable release*". Boot 4 moves to a Jakarta EE 11 / Servlet 6.1 baseline and requires Java 17+ | Boot 3.5.x – cheaper to write from memory but already unsupported and would need migration immediately |
| TD-02 | **Java 21 LTS** baseline | Matches the spec, is installed in the workspace (21.0.12), is supported by Boot 4.1 (needs 17+; 25 has first-class support). Revisit Java 25 at Stage 2 if your machine/CI already uses it | Java 25 LTS – newer, but no benefit for this project yet and not installed |
| TD-03 | **MySQL 8.4 LTS** | The spec says "MySQL 8.x"; MySQL 8.0 reached end of life in April 2026, 8.4 is the supported LTS 8.x line. Newer lines exist; Flyway/Boot/Testcontainers support for them is unverified, so they are not used | MySQL 8.0 (EOL), 9.x/newer (out of spec scope) |
| TD-04 | **Angular 22.2.x**, strict mode, standalone components | 22.2.5 is the current stable (released 3 Jun 2026; active support to 30 Jun 2027, security support to 30 Jun 2028) | Angular 21 (security-only already) |
| TD-05 | **Pin TypeScript to 6.0.x** | `@angular/compiler-cli@22.2.5` declares `typescript >=6.0 <6.1`, while npm's default `typescript` is now 7.0.2. Installing the default would break the build | Waiting for Angular support of TS 7 |
| TD-06 | **Ionic 9.0.10, Capacitor 8.6.0, PrimeNG 22.1.4, Chart.js 4.6.1, RxJS 7.8.2** | Peer ranges checked: Ionic accepts Angular ≥18; PrimeNG needs Angular/CDK `^22.1.0`; Capacitor needs Node ≥22; Chart.js 4.6.1 is latest | – |
| TD-07 | **Node.js `^22.22.3` or `^24.15.0`** for all developers and CI | Angular 22.2.5 `engines`. Workspace has 22.23.4 | – |
| TD-08 | **BIGINT auto-increment primary keys** + mandatory ownership checks on every customer resource; order numbers are separate, non-sequential-looking public values **(decision needed)** | Compact, fast InnoDB indexes and joins. Enumeration risk is handled by authorization (and tested for IDOR), not by hiding ids | UUID keys: harder to enumerate but larger indexes and slower inserts |
| TD-09 | **Generate front-end API types from the backend's OpenAPI document**; two separate Angular projects (no shared package at first) **(decision needed)** | One source of truth, no drifting DTOs, keeps the spec's `customer-app/` + `admin-app/` layout. Needs one small build-time dependency, to be justified in Stage 5 | A shared npm workspace package; hand-written types (drift-prone) |
| TD-10 | **Modular monolith, package-by-feature, boundaries enforced by architecture tests** | Spec requirement; tests keep boundaries from eroding. Tool choice (ArchUnit-style tests vs Spring Modulith) decided at Stage 2 and justified then | Microservices (not justified), layer-first packages |
| TD-11 | **Money = `DECIMAL(12,2)` / `BigDecimal`, currency INR, `HALF_UP` rounding, computed only on the server** | Spec rule; one central pricing service so cart, preview and order use identical maths | – |
| TD-12 | **Tax-inclusive prices by default (setting `prices_include_tax`), GST modelled explicitly**: HSN code on tax category/product, seller GSTIN and state in settings, CGST+SGST vs IGST by delivery state **(decision needed)** | Indian retail shows MRP including tax and invoices need GST detail. The spec's `tax_categories` is the base; extra columns/settings are added in Stage 1 | Tax-exclusive pricing; flat tax rate |
| TD-13 | **Auth:** BCrypt(12); JWT access ~15 min; rotating hashed refresh tokens with reuse detection; HS256 signing key from env; admin sessions shorter; web refresh token in HttpOnly cookie, native in secure storage **(decision needed)** | Meets the spec's refresh/logout/revocation requirements with no extra crypto dependency | RS256/ES256 keys (useful only if a second service verifies tokens) |
| TD-14 | **OTP behind an `OtpSender` interface**; email via SMTP now; SMS gateway chosen later | The spec lists SMTP but no SMS provider; Indian SMS needs DLT registration. Dev profile may log OTPs; production profile must not (startup check) | Hard-wiring one SMS vendor now |
| TD-15 | **Inventory:** atomic conditional `UPDATE` for reservation, deterministic lock order, DB `CHECK` against negatives, TTL-based release job, full movement ledger | Prevents overselling without long-held locks | Pessimistic `SELECT … FOR UPDATE` on all rows (slower, deadlock-prone); optimistic locking alone (retry storms on hot items) |
| TD-16 | **Add `PENDING_PAYMENT` order state** for unpaid online orders **(decision needed)** | Keeps `PLACED` meaning "payment confirmed or COD". See ARCHITECTURE §6.3 | Use `PLACED` + `payment_status=PENDING` and auto-cancel |
| TD-17 | **Payments:** Razorpay Orders + Standard Checkout; server-side signature check **and** server-side fetch; webhook is the authority; unique `gateway_event_id`; reconciliation job. Integration style (official Java SDK vs direct REST via Spring's HTTP client) decided in Stage 9 after verifying the SDK version | Spec rules: verify signatures, idempotent webhooks, never trust the client callback | – |
| TD-18 | **Razorpay in the mobile app:** evaluate the community plugin `capacitor-razorpay` 1.3.0 (peer `@capacitor/core >=7`, updated Jul 2026) against Razorpay's own Capacitor guide; fall back to web checkout inside the app if the plugin proves unsuitable | Razorpay documents a Capacitor integration, but I could not read that page and found no Razorpay-published npm package. Not decided until Stage 9 | Third-party wrappers pinned to old Capacitor (`^4`, `^6`) – rejected |
| TD-19 | **Images:** S3-compatible API behind a `FileStorage` interface; local/MinIO in dev; provider chosen with you; thumbnails/WebP generated on upload; served via CDN | Avoids storing binaries on the app server and keeps provider choice open | Local disk storage in production |
| TD-20 | **Search:** MySQL `FULLTEXT` + prefix queries initially; Redis optional for caching | Enough for a single-vendor catalogue; avoids operating a search cluster | Elasticsearch/OpenSearch later if measured load requires |
| TD-21 | **Customer web + mobile = one codebase, two build targets** (SSR for web, static for Capacitor) | Spec asks to share logic and UI. Risk and mitigation in ARCHITECTURE §4 | Separate web app (duplicated work) |
| TD-22 | **State management:** signals + RxJS only | Spec rule; no second state library | NgRx |
| TD-23 | **Testing:** JUnit 5, Mockito, Spring Security Test, Testcontainers (MySQL 8.4) on the backend; Angular's built-in test setup + Playwright (1.65.0 current) for front-end/E2E | Spec. Testcontainers needs a Docker daemon → runs on your machine or GitHub Actions, not in the cloud workspace | In-memory H2 (rejected: behaves differently from MySQL) |
| TD-24 | **CI: GitHub Actions** (backend `mvn verify` with Docker, front-end build/test, later macOS runner for iOS) – added in Stage 2 | Repo is already on GitHub; runners provide Docker; fixes the workspace's tooling gaps | Local-only verification |
| TD-25 | **Git:** `main` (stable), `develop` (integration), `feature/*` per stage; Conventional-Commit style messages; no force-push. Recommend enabling branch protection on `main` in GitHub settings | Spec §36 | – |
| TD-26 | **API conventions:** `/api/v1`, spec envelope, `Idempotency-Key` on write-critical endpoints, server-side sort allow-lists, size caps | Spec §22 plus safe defaults | – |

## 2. Decisions that need your answer

Reply with the numbers you accept, or tell me what to change. Unanswered items proceed with my recommended default at the
relevant stage and will be flagged again in that stage's report.

| # | Question | Recommended default |
|---|---|---|
| 1 | Move from Spring Boot 3.x to **4.1.x** (TD-01)? | Yes |
| 2 | Add the **`PENDING_PAYMENT`** order state (TD-16)? | Yes |
| 3 | **Tax-inclusive** prices and GST fields/invoice detail (TD-12)? Do you have GSTIN/HSN codes? | Yes – please share GST details before Stage 1 |
| 4 | **BIGINT** primary keys (TD-08)? | Yes |
| 5 | Web refresh token in **HttpOnly cookie** (TD-13)? | Yes |
| 6 | Generate API types from **OpenAPI** (TD-09)? | Yes |
| 7 | SMS provider for mobile OTP, hosting provider/region, object-storage provider | Tell me, or I choose neutral S3-compatible + decide hosting at Stage 15 |
| 8 | How to unblock builds: allow Maven Central, build locally, or GitHub Actions (ENVIRONMENT_REPORT §3) | All three; Actions regardless |

## 3. Rules I will follow when adding any dependency

Explain why it is needed, check version compatibility against the table above, prefer what the Spring Boot BOM or Angular already
provides, and record it here. Nothing outside the stack in your spec is installed without that note.

## 4. Evidence and sources (checked 2026-11-11)

- Spring Boot support lines – [Spring Boot End of Life: Every 3.x Branch Is Now Unsupported](https://www.danvega.dev/blog/spring-boot-end-of-life) (published 14 Jul 2026) and [Spring Boot EOL Dates](https://www.osseva.io/eol/spring-boot) (state as of 20 Oct 2026: 4.1 latest 4.1.2, 4.0 latest 4.0.9).
- Angular release/support dates – [endoflife.date/angular](https://endoflife.date/angular).
- MySQL 8.0 end of life – [endoflife.ai/mysql/8.0](https://endoflife.ai/mysql/8.0). That page also lists newer MySQL lines (9.7 LTS, 26.10); they are intentionally not adopted (TD-03).
- npm registry (live queries): `@angular/core` 22.2.5, `@angular/cli` 22.2.6, `@ionic/angular` 9.0.10, `@capacitor/core` 8.6.0, `primeng` 22.1.4, `chart.js` 4.6.1, `typescript` 7.0.2 (latest) vs Angular's required `>=6.0 <6.1`, `zone.js` 0.16.3, `rxjs` 7.8.2, `@capacitor-firebase/messaging` 8.6.0, `capacitor-razorpay` 1.3.0, `razorpay` (Node SDK, not used by the Java backend) 2.9.8, `@playwright/test` 1.65.0.

## 5. Not verified (and why)

- Exact Spring Framework / Hibernate / Flyway / MySQL Connector/J versions managed by Boot 4.1 – Maven Central blocked.
- Third-party backend libraries (OpenAPI UI, JWT library, Razorpay Java SDK) – to be chosen and verified at Stages 2, 3 and 9.
- Whether a Spring Boot 4.2 line has since been released (an article title hints at it; no primary source found) – re-check at Stage 2.
- Ionic 9 behaviour without `zone.js` – verify in the Stage 5 spike.
- Razorpay's official Capacitor guide – page could not be fetched.
