# ShopyHapy – Development Plan

Status: **Stage 0 – proposed, awaiting approval** · Last updated: 2026-11-11

Execution rules (from your specification): one stage at a time; inspect before editing; build and test; fix errors; document;
write the completion report; **stop and wait for `APPROVE STAGE n`**. A stage is only reported complete if its tests were actually
executed and passed. A failed or skipped test means the stage is reported as partially complete.

## 1. Roadmap

| Stage | Name | Branch | Main outputs |
|---|---|---|---|
| 0 | Environment inspection and architecture | `develop` | These five documents, repo skeleton, environment scripts |
| 1 | Requirements and database | `feature/database` | REQUIREMENTS, DATABASE_DESIGN, ER_DIAGRAM, API_SPECIFICATION, Flyway migrations, dev seed data |
| 2 | Backend foundation | `feature/backend-foundation` | Spring Boot project, profiles, Flyway/JPA, Swagger, global errors, response envelope, health check, base tests, CI workflow |
| 3 | Authentication | `feature/authentication` | Register/login/OTP/refresh rotation/logout/reset, roles, admin auth, security tests |
| 4 | Product and category backend | `feature/product-catalog` | Category/brand/product/variant/image CRUD, search/filter/sort/pagination, inventory |
| 5 | Customer app foundation | `feature/customer-app` | Ionic+Angular+Capacitor shell, routing, interceptors, guards, design tokens, SSR spike, Android/iOS platforms added |
| 6 | Customer UI and catalogue | `feature/customer-app` | Splash, onboarding, home, categories, listing, search, filters, product detail, gallery, variants |
| 7 | Wishlist and cart | `feature/cart-checkout` | Wishlist, cart, guest cart merge, coupons, server-side pricing, concurrency tests |
| 8 | Address and checkout | `feature/cart-checkout` | Addresses, PIN/serviceability, shipping, tax, preview, reservation, final validation |
| 9 | Razorpay integration | `feature/payment` | Order creation, mobile + web checkout, verify, webhooks, idempotency, reconciliation, refunds |
| 10 | Order and delivery management | `feature/cart-checkout` | Orders, status machine, history, cancel, return, refund workflow, invoice, tracking |
| 11 | Customer website completion | `feature/customer-app` | SEO URLs, metadata, SSR/prerender, sitemap, robots, desktop layouts, web payments |
| 12 | Admin dashboard | `feature/admin-dashboard` | All admin modules on real APIs |
| 13 | Notifications and integrations | `feature/notifications` | FCM, email, templates, admin alerts |
| 14 | Testing and QA | `feature/testing` | Full test suites, E2E, security and performance testing, four reports, fixes |
| 15 | Production deployment | `feature/deployment` | Dockerfiles, Compose, Nginx/HTTPS, backups, monitoring, Android/iOS release preparation, guides |

Branch flow: `feature/*` → `develop` → `main` through pull requests. Nothing is force-pushed.

## 2. Per-stage detail

For every stage: *Exit criteria* are what must be demonstrably true (with command output) before I ask for approval.

### Stage 1 – Requirements and database
- **Scope:** functional specification; customer and admin workflows; role/permission matrix; full schema (the 40 tables in your spec plus
  what the implementation needs: GST fields, idempotency keys, reservation expiry, cart session, order-number sequence); ER
  diagram (Mermaid); relationships and indexes; API contracts; Flyway migrations; development seed data.
- **Exit criteria:** every table in the spec is covered or has a documented reason; every foreign key and unique constraint
  listed; migrations apply cleanly **from empty** on a real MySQL server; seed data loads; indexes justified against the
  planned queries.
- **Needs from you:** answers to the open questions in `PROJECT_OVERVIEW.md` §6 and `TECHNICAL_DECISIONS.md` §2.
- **Environment:** documents anywhere; real-server validation needs MySQL. In the cloud workspace only Ubuntu's MySQL 8.0 can be
  installed (not 8.4) – I will ask before installing it.

### Stage 2 – Backend foundation
- **Exit criteria:** `mvn clean verify` passes; app starts against MySQL; `GET /actuator/health` returns `UP`; Swagger UI lists the
  base endpoints; an error produces the standard envelope; one architecture test and base unit tests run; GitHub Actions workflow
  runs green.
- **Environment:** requires Maven Central (blocked in the cloud workspace) – see `ENVIRONMENT_REPORT.md` §3.

### Stage 3 – Authentication
- **Exit criteria:** register→verify OTP→login→refresh (old token rejected)→logout flow passes; reuse of a rotated refresh token
  revokes the family; brute-force limits work; 401 vs 403 tests for customer vs admin routes; passwords and tokens never appear in logs.
- **Needs:** SMTP credentials for real email (dev uses a logging sender).

### Stage 4 – Product and category backend
- **Exit criteria:** every endpoint listed in your API spec for categories/products/brands has success, validation, auth and
  not-found tests; slug uniqueness; image upload validation; concurrent stock-adjust test shows no negative stock.
- **Needs:** object-storage provider choice (local/MinIO in dev).

### Stage 5 – Customer app foundation
- **Exit criteria:** `npm run build` passes for both targets; unit tests run; lazy routes load; interceptor refreshes an expired
  token exactly once under parallel requests; design tokens are the only source of colour; Android and iOS platform projects exist.
  The **SSR spike** result is documented.
- **Environment:** web build and tests run in the cloud workspace. Android/iOS *compilation* cannot (see environment report).

### Stages 6–8 – Catalogue UI, wishlist/cart, address/checkout
- **Exit criteria:** every screen uses real API data, has loading/empty/error states, and has no inert buttons; concurrent cart and
  stock tests pass; the backend recomputes every total and rejects tampered client prices; coupon rules (expiry, limits, minimum,
  per-customer) are tested.

### Stage 9 – Razorpay
- **Exit criteria:** success, failure, cancellation and **duplicate webhook** scenarios pass; invalid signatures are rejected;
  an order is never paid from the client callback alone; reconciliation fixes an artificially stuck payment; no card data stored.
- **Needs from you:** Razorpay **test-mode** key id/secret, webhook secret, and a public HTTPS URL for webhook delivery during testing.

### Stage 10 – Orders and delivery
- **Exit criteria:** the state machine test covers every allowed and forbidden transition; cancel/return/refund update stock,
  payment and history consistently inside transactions; invoice PDF generates with correct totals.

### Stage 11 – Website completion
- **Exit criteria:** public pages render useful HTML without JavaScript; correct titles, canonical, Open Graph tags and structured
  data; sitemap and robots; no private data in public responses; checkout works on desktop widths.

### Stage 12 – Admin dashboard
- **Exit criteria:** every module hits real endpoints with pagination, search, filters, loading states and confirmations; a user
  without a permission cannot call the endpoint even with a crafted request.

### Stage 13 – Notifications
- **Needs from you:** Firebase project (service account + app config files), SMTP credentials.

### Stage 14 – Testing and QA
- **Exit criteria:** the 16 end-to-end workflows in your spec pass; the security checklist (SQLi, XSS, CSRF where applicable, auth
  and authorisation bypass, JWT expiry, rate limiting, upload validation, webhook validation, data exposure) is exercised and
  reported honestly; performance numbers are measured, not estimated; `TEST_REPORT`, `SECURITY_REPORT`, `PERFORMANCE_REPORT`,
  `BUG_REPORT` contain real results. Critical and high issues fixed.

### Stage 15 – Deployment
- **Exit criteria:** `docker compose up` brings up the full stack locally; Flyway runs; health checks pass; backup restored
  successfully in a drill; Android AAB and iOS archive are *prepared* (signing steps documented). **Nothing is published or
  deployed to production without your explicit approval.**
- **Needs from you:** domain, hosting, store accounts, signing keys, monitoring accounts.

## 3. Where each stage can be verified

| Stage | Cloud workspace today | Your PC / Docker Desktop | GitHub Actions |
|---|---|---|---|
| 1 | Docs + SQL authoring | Real MySQL validation | Real MySQL validation |
| 2–4 | Code authoring only (Maven blocked) | Full | Full (Docker available) |
| 5–8, 11–12 | Full (npm + Chrome) | Full | Full |
| Android build | No | Yes (Android Studio) | Yes |
| iOS build | No | Mac only | Yes (macOS runner) |
| 9, 13 | Code + unit tests | Live tests with your credentials | Mocked tests only |
| 14–15 | Partial | Full | Full |

If Maven Central stays blocked and you do not want to build locally, backend stages can still be authored here, but I will report
them as **not built / not tested** rather than complete.

## 4. Risk register

| Risk | Impact | Mitigation |
|---|---|---|
| Backend cannot be built in the cloud workspace | Stages 2–4 unverifiable here | Allow Maven Central, build locally, and add GitHub Actions |
| No Docker daemon / Docker Hub blocked | Testcontainers tests cannot run here | Run them in GitHub Actions or on your machine |
| Ionic + Angular SSR immaturity | SEO goals at risk | Stage 5 spike; prerender fallback; verify in Stage 11 |
| Angular requires TypeScript `>=6.0 <6.1` | Default `npm install typescript` breaks builds | Pin `~6.0.x`; add a CI check |
| Spring Boot 4 is a major generation | Fewer community examples, some libraries lag | Prefer Boot-managed dependencies; verify each added library against Boot 4.1 |
| Overselling under concurrency | Business and trust impact | Atomic reservation, constraints, concurrency tests (Stage 7/8) |
| Duplicate/forged payment events | Money loss | Signature + server fetch, unique event ids, reconciliation (Stage 9) |
| Mobile OTP needs a registered SMS route in India | Registration blocked in production | Choose provider early; start DLT registration now |
| GST invoice correctness | Compliance exposure | Confirm requirements with your accountant; Stage 1 models the fields |
| Razorpay Capacitor plugin maturity | Native payment flow delays | Evaluate in Stage 9; fall back to web checkout |
| Store submission requirements (Apple/Google) | Release delays | Accounts, privacy policy URL, data-safety forms prepared in Stage 15 |
| Single VM deployment | Single point of failure | Documented upgrade path; managed MySQL and backups recommended |

## 4a. Commands I intend to run, by stage

| Stage | Commands (representative) |
|---|---|
| 0 | read-only inspection, `git switch -c develop`, `git commit`, `git push origin develop` |
| 1 | `mysql` client / Flyway CLI against a throw-away database; `git` |
| 2–4 | `mvn -v`, `mvn clean verify`, `mvn spring-boot:run`, `curl localhost:8080/actuator/health` |
| 5–8, 11–12 | `npm install` (pinned versions), `ng build`, `ng test`, `npx cap add android/ios`, `npx cap sync`, `npm run build` |
| 9 | backend and front-end test commands; Razorpay **test-mode** API calls only |
| 14 | `mvn verify`, `ng test`, Playwright, security scanners, load-test tool (chosen and justified then) |
| 15 | `docker build`, `docker compose up`, `gradlew bundleRelease` / `xcodebuild` (where tooling exists) |

I will not run destructive commands (`rm -rf`, `git push --force`, `git reset --hard`) without asking.

## 5. Definition of done (every stage)

Code compiles; tests for the stage were executed and pass; no skipped test is hidden; no secrets in Git; documentation updated;
changes committed on the stage branch with a meaningful message; completion report delivered; approval requested.
