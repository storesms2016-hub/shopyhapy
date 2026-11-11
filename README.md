# shopyhapy

**ShopyHapy** – a premium single-vendor e-commerce platform for India: customer mobile app (Android/iOS), customer website,
admin dashboard, and one shared Spring Boot backend.

> **Status:** Stage 0 (architecture and planning) delivered – awaiting approval. No application code has been written yet.

## Planned stack

| Part | Technology |
|---|---|
| Customer app + website | Angular 22 (standalone, strict), Ionic 9, Capacitor 8, RxJS, signals, SCSS |
| Admin dashboard | Angular 22, PrimeNG 22, Chart.js |
| Backend | Java 21, Spring Boot 4.1.x, Spring Security (JWT), Spring Data JPA, Flyway, OpenAPI |
| Database | MySQL 8.4 LTS |
| Integrations | Razorpay, Firebase Cloud Messaging, SMTP, S3-compatible storage, optional Redis |
| Delivery | Docker, Nginx, GitHub Actions |

Versions and the reasons behind them: [`documentation/TECHNICAL_DECISIONS.md`](documentation/TECHNICAL_DECISIONS.md).

## Repository layout

```
customer-app/      Ionic + Angular app (mobile + website)   – Stage 5 onward
admin-app/         Angular + PrimeNG admin dashboard        – Stage 12
backend/           Spring Boot API                          – Stage 2 onward
infrastructure/    Docker, Nginx, deployment files          – Stage 15
documentation/     Architecture, decisions, plans, reports
scripts/           Helper scripts (environment check, ...)
```

## Documentation

| Document | Purpose |
|---|---|
| [PROJECT_OVERVIEW](documentation/PROJECT_OVERVIEW.md) | Goals, scope, roles, open questions |
| [ARCHITECTURE](documentation/ARCHITECTURE.md) | System design, flows, security, deployment |
| [DEVELOPMENT_PLAN](documentation/DEVELOPMENT_PLAN.md) | Stages 0–15, exit criteria, risks |
| [TECHNICAL_DECISIONS](documentation/TECHNICAL_DECISIONS.md) | Decision log with evidence, questions for the owner |
| [ENVIRONMENT_REPORT](documentation/ENVIRONMENT_REPORT.md) | Tooling inventory, limits, compatibility findings |

## Check your machine

```
# Windows
powershell -ExecutionPolicy Bypass -File .\scripts\check-environment.ps1
# macOS / Linux
bash scripts/check-environment.sh
```

## Git workflow

`main` (stable) ← `develop` (integration) ← `feature/*` (one per area of work). Conventional-style commit messages. No force-pushes.

## Security

No credentials are stored in this repository. All secrets are supplied through environment variables; see `.gitignore`.