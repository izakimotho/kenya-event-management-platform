# Final Logical ERD — V2

The diagrams below represent the implemented table relationships in this migration package.
Mermaid diagrams render in GitHub, GitLab and compatible Markdown viewers.

## 1. Identity and RBAC

```mermaid
erDiagram
  identity_users ||--o{ identity_user_sessions : has
  identity_users ||--o{ security_user_roles : assigned
  security_roles ||--o{ security_user_roles : grants
  security_roles ||--o{ security_role_permissions : includes
  security_permissions ||--o{ security_role_permissions : assigned
  identity_users ||--o{ security_user_roles : assigns

  identity_users {
    uuid id PK
    varchar email UK
    varchar phone_number
    varchar password_hash
    varchar account_status
  }
  security_roles {
    uuid id PK
    varchar code UK
    varchar scope
  }
  security_permissions {
    uuid id PK
    varchar code UK
    varchar resource
    varchar action
  }
  security_user_roles {
    uuid id PK
    uuid user_id FK
    uuid role_id FK
    uuid assigned_by FK
  }
  security_role_permissions {
    uuid id PK
    uuid role_id FK
    uuid permission_id FK
  }
  identity_user_sessions {
    uuid id PK
    uuid user_id FK
    varchar refresh_token_hash
    timestamptz expires_at
  }
```

## 2. Events, collaboration and planning

```mermaid
erDiagram
  identity_users ||--o{ event_events : owns
  geography_counties ||--o{ event_events : located_in
  event_events ||--o{ event_members : has
  identity_users ||--o{ event_members : participates
  security_roles ||--o{ event_members : event_role
  event_events ||--o{ event_invitations : invites
  identity_users ||--o{ event_invitations : invited_by
  event_events ||--o{ planning_tasks : plans
  identity_users ||--o{ planning_tasks : assigned_to
  event_events ||--o{ planning_budgets : budgets
  planning_budgets ||--o{ planning_budget_items : itemizes

  event_events {
    uuid id PK
    uuid owner_id FK
    uuid county_id FK
    varchar event_type
    date event_date
    varchar event_status
  }
  event_members {
    uuid id PK
    uuid event_id FK
    uuid user_id FK
    uuid role_id FK
  }
  event_invitations {
    uuid id PK
    uuid event_id FK
    uuid invited_by FK
    uuid accepted_user_id FK
    varchar invitation_token_hash
  }
  planning_tasks {
    uuid id PK
    uuid event_id FK
    uuid assigned_to FK
  }
  planning_budgets {
    uuid id PK
    uuid event_id FK
  }
  planning_budget_items {
    uuid id PK
    uuid budget_id FK
  }
```

## 3. Vendor, verification and geography

```mermaid
erDiagram
  identity_users ||--o| vendor_profiles : owns
  vendor_profiles ||--o{ vendor_category_mapping : categorized
  vendor_categories ||--o{ vendor_category_mapping : classifies
  vendor_profiles ||--o{ vendor_service_packages : offers
  vendor_profiles ||--o{ vendor_portfolio : showcases
  vendor_profiles ||--o{ vendor_service_areas : serves
  geography_counties ||--o{ vendor_service_areas : includes
  vendor_profiles ||--o{ vendor_documents : submits
  vendor_profiles ||--o{ vendor_verification_cases : undergoes
  vendor_verification_cases ||--o{ vendor_verification_reviews : reviewed
  identity_users ||--o{ vendor_verification_reviews : reviewer
  vendor_verification_cases ||--o{ vendor_verification_case_documents : evidence
  vendor_documents ||--o{ vendor_verification_case_documents : attached

  vendor_profiles {
    uuid id PK
    uuid user_id FK
    varchar business_name
    varchar verification_status
  }
  vendor_categories {
    uuid id PK
    varchar code UK
  }
  vendor_service_packages {
    uuid id PK
    uuid vendor_id FK
    numeric price
  }
  vendor_documents {
    uuid id PK
    uuid vendor_id FK
    varchar storage_key
    varchar verification_status
  }
  vendor_verification_cases {
    uuid id PK
    uuid vendor_id FK
    uuid assigned_admin_id FK
    varchar status
  }
  vendor_verification_reviews {
    uuid id PK
    uuid case_id FK
    uuid reviewer_id FK
  }
```

## 4. Marketplace and quotations

```mermaid
erDiagram
  event_events ||--o{ marketplace_enquiries : generates
  identity_users ||--o{ marketplace_enquiries : customer
  vendor_profiles ||--o{ marketplace_enquiries : receives
  vendor_service_packages ||--o{ marketplace_enquiries : package
  marketplace_enquiries ||--o{ marketplace_enquiry_messages : contains
  identity_users ||--o{ marketplace_enquiry_messages : sends
  marketplace_enquiries ||--o{ marketplace_enquiry_status_history : tracks
  marketplace_enquiries ||--o{ quotation_vendor_quotes : quoted
  vendor_profiles ||--o{ quotation_vendor_quotes : issues
  quotation_vendor_quotes ||--o{ quotation_vendor_quote_items : contains

  marketplace_enquiries {
    uuid id PK
    uuid event_id FK
    uuid customer_id FK
    uuid vendor_id FK
    uuid package_id FK
    varchar status
  }
  marketplace_enquiry_messages {
    uuid id PK
    uuid enquiry_id FK
    uuid sender_id FK
  }
  quotation_vendor_quotes {
    uuid id PK
    uuid enquiry_id FK
    uuid vendor_id FK
    uuid parent_quote_id FK
    integer version_number
    numeric total_amount
    varchar status
  }
  quotation_vendor_quote_items {
    uuid id PK
    uuid quote_id FK
    numeric quantity
    numeric unit_price
  }
```

## 5. Audit, notifications and administration

```mermaid
erDiagram
  identity_users ||--o{ audit_audit_logs : performs
  identity_users ||--o{ notification_notifications : receives
  identity_users ||--o{ notification_preferences : configures
  identity_users ||--o{ administration_actions : actor
  administration_actions }o--|| identity_users : target_user

  audit_audit_logs {
    uuid id PK
    uuid user_id FK
    varchar entity_name
    uuid entity_id
    jsonb old_values
    jsonb new_values
  }
  notification_notifications {
    uuid id PK
    uuid user_id FK
    varchar channel
    varchar status
  }
  administration_actions {
    uuid id PK
    uuid actor_user_id FK
    uuid target_user_id FK
    varchar action
  }
```

**Relationship notes**
- All business entities use UUID primary keys.
- `event_members` is unique per `(event_id, user_id)`.
- A vendor profile is one-to-one with its owning user.
- A vendor enquiry is tied to one event, customer and vendor.
- Quotations are versioned per enquiry; each revision points to its parent quote.
- Some semantic rules (for example, the enquiry customer must own or be authorized for the event, and an enquiry's package must belong to the same vendor) are enforced in the service layer unless explicitly represented by a composite database constraint.
