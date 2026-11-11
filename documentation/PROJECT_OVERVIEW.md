# ShopyHapy – Project Overview

Status: **Stage 0 – proposed, awaiting approval** · Last updated: 2026-11-11

## 1. What we are building

ShopyHapy is a **premium single-vendor e-commerce platform for the Indian market**. One business owner sells a broad
catalogue (electronics, accessories, appliances, clothing, beauty, home & kitchen, toys, sports, grocery, general
merchandise). Customers register, browse, and buy multiple products per order. The admin controls products, pricing,
discounts and stock. There is no marketplace, no seller onboarding, no commission logic.

New product categories must be addable from the admin dashboard **without code or schema changes** – categories are data,
not architecture.

## 2. Deliverables

| ID | Deliverable | Technology | Audience |
|---|---|---|---|
| A | Customer mobile app (Android + iOS) | Ionic + Angular + Capacitor | Customers |
| B | Customer website (responsive, SEO-friendly, public product/category URLs) | Same Angular/Ionic codebase as A, with a server-rendered web build | Customers, search engines |
| C | Admin dashboard | Separate Angular app, PrimeNG, Chart.js | Store staff (desktop/tablet) |
| D | Backend | Java + Spring Boot REST API (modular monolith), MySQL | Used by A, B, C |

All three front-ends talk to the same API under `/api/v1`.

## 3. Actors and roles

| Actor | Description | Access |
|---|---|---|
| Guest | Not logged in | Browse, search, view product pages, keep a guest cart. **Cannot place an order.** |
| Customer | Registered, verified user | Everything a guest can, plus wishlist, addresses, checkout, orders, returns, reviews, profile |
| Admin roles (proposed) | `SUPER_ADMIN`, `STORE_MANAGER`, `INVENTORY_MANAGER`, `ORDER_MANAGER`, `MARKETING_MANAGER`, `SUPPORT_AGENT` | Permission-based access to admin modules; enforced on the backend. Final role/permission matrix is a Stage 1 deliverable |

## 3a. Scope

**In scope:** everything in the specification you provided – authentication with OTP, catalogue with variants, search/filter/sort,
wishlist, cart, addresses, checkout, Razorpay payments (UPI, cards, net banking) plus configurable COD, orders with a validated
status workflow, returns/refunds, invoices, push + email notifications, admin dashboard (analytics, catalogue, inventory,
orders, customers, marketing, reports, system settings, audit logs), tests, Docker/Nginx deployment, Android/iOS release prep.

**Out of scope (unless you ask later):** multi-vendor features, marketplace commissions, microservices, loyalty points, gift
cards, subscriptions, multi-currency, multi-language content (the UI will be built i18n-ready but ships in English),
courier API integrations (shipment tracking is entered manually in v1), social login.

## 4. Quality bar

Real-world, not a demo: secure APIs, server-authoritative pricing and stock, transactional checkout, idempotent payments,
reusable components, loading/empty/error states, no dead buttons, automated tests that are actually executed, and deployment
documentation. Stages are executed one at a time; nothing proceeds without your explicit `APPROVE STAGE n`.

## 5. Delivery approach

16 stages (0–15), each ending with a completion report and a hard stop. See `DEVELOPMENT_PLAN.md`. The architecture is in
`ARCHITECTURE.md`; every significant choice and its evidence is in `TECHNICAL_DECISIONS.md`; the tooling situation is in
`ENVIRONMENT_REPORT.md`.

## 6. Assumptions and open questions (your input shapes Stage 1)

I made the assumption shown in *italics*; tell me if any is wrong.

1. **GST / tax.** *Prices shown to customers are tax-inclusive (MRP style), GST rates come from a tax category per product, and
   invoices are GST-compliant tax invoices.* Do you have a GSTIN, HSN codes, and a registered state? This affects the schema
   (HSN code, CGST+SGST vs IGST split by delivery state) and the invoice.
2. **Mobile OTP delivery.** The spec lists SMTP but no SMS provider. *Email OTP via SMTP; mobile OTP via an SMS gateway behind an
   interface.* Indian SMS requires DLT-registered templates. Which provider (MSG91, Twilio, etc.) do you want?
3. **Hosting and storage.** *Single VPS/VM with Docker Compose, S3-compatible object storage for images, MySQL on the same host
   initially.* Which cloud/region and which storage provider?
4. **Shipping.** *Admin enters courier name/tracking number manually; shipping charge comes from configurable rules (PIN-prefix
   based, free-shipping threshold).*
5. **COD.** *Enabled via a setting, with an optional maximum order value and optional per-PIN restrictions.* Any COD fee or limit?
6. **Cancellation and return policy.** *Customer may cancel until the order is packed; returns allowed within a configurable
   window (default 7 days after delivery).* What are your real rules?
7. **App identifiers and accounts.** *Application ID/bundle ID `com.shopyhapy.app`.* Do you already have a Google Play and an Apple
   Developer account, a logo, and brand colours (the spec suggests navy + orange)?
8. **Existing code.** Is there code in your local `C:\Users\ADMIN\Desktop\claude\shopyhapy\...` folder that must be preserved?

## 7. Glossary

- **Modular monolith** – one deployable backend, internally divided into feature modules with enforced boundaries.
- **Reservation** – stock temporarily held for a pending checkout so two customers cannot buy the last unit.
- **Idempotency** – repeating the same request (retry, double-click, duplicate webhook) has the same effect as sending it once.
- **Snapshot** – an immutable copy of product/address data stored on the order so later edits never change history.
