# Design decisions and validation boundaries

## Enforced by PostgreSQL in this package
- UUID primary keys and foreign keys for all modeled relationships.
- Uniqueness of normalized business identifiers where defined.
- Role scope checks: GLOBAL roles in `security.user_roles`; EVENT roles in `event.members`.
- Event membership uniqueness.
- Vendor/package consistency for enquiry package references.
- Vendor consistency between enquiry and quotation.
- Quote version uniqueness per enquiry.
- Quote parent revision must belong to the same enquiry.
- Monetary non-negativity and positive quote item quantity.
- Sent/final quotation immutability and quote-item immutability.
- Valid status values for core workflows.

## Enforced by application/service layer
- The event owner or authorized member must be allowed to create an enquiry for the event.
- The customer on an enquiry must be an event owner/member with relevant permission.
- The package must be active and publicly available when selected.
- Only the vendor's authorized users can view/respond to that vendor's enquiry.
- Only a sufficiently privileged event member can accept a quote.
- Quote total must equal subtotal - discount + tax and quote item totals must equal quantity * unit price.
  These calculations should be performed with decimal arithmetic and validated in a transaction.
- Vendor verification requirements vary by category and may change over time.
- Only authorized reviewers can approve/reject verification cases.
- Prevent privilege escalation and enforce tenant/event isolation in every query.
- File upload malware scanning, MIME validation, size limits and private object authorization.

## ERD validation
The Mermaid ERD is the logical relationship view. PostgreSQL catalogs are the physical source of truth.
After migration, export a physical ERD from the target database using a PostgreSQL ERD tool and compare it
with `docs/ERD.md`.

## Migration execution status
The SQL package is generated but has not been executed against a live PostgreSQL server in this environment.
Do not treat static inspection as proof of successful execution. Run it in a disposable PostgreSQL instance,
then run `validation/validate.sql` and workflow integration tests.
