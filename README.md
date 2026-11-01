# Kenya Event Management SaaS — PostgreSQL/Flyway V2

This package is the executable baseline for the logical V2 design: identity, global/event-scoped RBAC,
events and collaborators, planning/budgets, vendor marketplace and verification, enquiries,
versioned quotations, audit, notifications and administrative actions.

## Requirements
- PostgreSQL 14+ (recommended PostgreSQL 16+)
- Flyway Community/Teams compatible with the project's Flyway version
- A database and a migration user with permission to create schemas, tables, indexes, functions and triggers
- `pgcrypto` extension permission (used for UUID generation)

## Apply migrations
The migrations are deliberately **flat** in `db/migration` because Flyway's default filesystem/classpath
locations scan this directory reliably. Version numbers are globally ordered across domains.

Configure Spring Boot:

```yaml
spring:
  datasource:
    url: ${DB_URL}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
  flyway:
    enabled: true
    locations: classpath:db/migration
  jpa:
    hibernate:
      ddl-auto: validate
```

Copy `db/migration/*.sql` into `src/main/resources/db/migration/`.
Run `./mvnw flyway:migrate` if using the Flyway Maven plugin, or start the Spring Boot application
with Flyway enabled. Do not run Hibernate schema generation alongside Flyway.

## Important implementation boundaries
- SQL constraints validate relational integrity and basic value rules. Ownership, event membership,
  permission evaluation, document access, quote state transitions and vendor/package consistency
  also require service-layer authorization and transactional checks.
- `security.roles.scope` distinguishes GLOBAL and EVENT roles. The application must reject assigning
  EVENT roles through global `security.user_roles`, and must check event membership on every event-scoped
  operation.
- Sent quotations are protected from UPDATE/DELETE by a database trigger. Create a new quote version
  for revisions. Quote items are immutable after the parent quote is sent.
- Vendor documents store an object-storage key, not the document bytes or a public URL. Keep the bucket
  private and authorize downloads through the application.
- Audit logs are append-only for the application role. Database owners can still alter data; use a
  separately controlled migration/DBA role in production.
- Soft deletion is not applied to immutable history tables, sessions, messages, and audit records.
- This baseline uses `TIMESTAMPTZ` and UTC application/database conventions.

## Validation
Run `validation/validate.sql` after migration. It checks expected schemas, tables, constraints and
foreign-key presence. It does not replace running migrations against a real PostgreSQL server.
For stronger validation, run the package in a disposable PostgreSQL instance and execute the
workflow integration tests before production.

## Migration inventory
- V001: extensions, schemas and shared timestamp trigger
- V002–V004: identity, sessions, global RBAC and seed permissions
- V005: Kenyan counties
- V006–V008: events, invitations, collaborators, planning and budgets
- V009–V012: vendors, categories, packages, service areas, documents and verification
- V013–V015: enquiries, messages, lifecycle history and attachments
- V016–V017: quotations, items and immutable sent-quote protection
- V018–V020: audit, notifications and administration
- V021: performance indexes and supporting constraints

## Before production
Review legal retention periods, privacy notices and lawful bases with Kenyan data-protection counsel.
Configure encrypted backups, point-in-time recovery, secrets management, object-storage lifecycle rules,
monitoring, least-privilege DB roles and a tested restore process.
