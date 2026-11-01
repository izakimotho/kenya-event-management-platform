-- Run after Flyway migrations.
-- Any returned row indicates a missing expected object or constraint.

WITH expected_tables(schema_name, table_name) AS (
  VALUES
  ('identity','users'), ('identity','user_sessions'),
  ('security','roles'), ('security','permissions'),
  ('security','role_permissions'), ('security','user_roles'),
  ('security','user_role_history'),
  ('geography','counties'),
  ('event','events'), ('event','members'), ('event','invitations'),
  ('planning','tasks'), ('planning','budgets'), ('planning','budget_items'),
  ('vendor','profiles'), ('vendor','categories'), ('vendor','category_mapping'),
  ('vendor','service_packages'), ('vendor','portfolio'), ('vendor','service_areas'),
  ('vendor','documents'), ('vendor','verification_cases'),
  ('vendor','verification_reviews'), ('vendor','verification_case_documents'),
  ('vendor','status_history'),
  ('marketplace','enquiries'), ('marketplace','enquiry_messages'),
  ('marketplace','enquiry_status_history'), ('marketplace','enquiry_attachments'),
  ('quotation','vendor_quotes'), ('quotation','vendor_quote_items'),
  ('audit','audit_logs'),
  ('notification','notifications'), ('notification','preferences'),
  ('administration','actions')
)
SELECT 'MISSING_TABLE' AS issue, e.schema_name || '.' || e.table_name AS object_name
FROM expected_tables e
LEFT JOIN information_schema.tables t
  ON t.table_schema=e.schema_name AND t.table_name=e.table_name
WHERE t.table_name IS NULL;

-- Foreign keys should exist across the business schemas.
SELECT 'FK_COUNT' AS check_name, count(*) AS actual_foreign_keys
FROM information_schema.table_constraints
WHERE constraint_type='FOREIGN KEY'
  AND constraint_schema IN
    ('identity','security','geography','event','planning','vendor',
     'marketplace','quotation','audit','notification','administration');

-- Check seeded Kenyan county and baseline roles.
SELECT 'COUNTY_SEED_COUNT' AS check_name, count(*) AS actual_count
FROM geography.counties;

SELECT 'GLOBAL_ROLE_SEED_COUNT' AS check_name, count(*) AS actual_count
FROM security.roles WHERE scope='GLOBAL';

SELECT 'EVENT_ROLE_SEED_COUNT' AS check_name, count(*) AS actual_count
FROM security.roles WHERE scope='EVENT';

-- Check core required uniqueness constraints.
SELECT 'DUPLICATE_USER_EMAILS' AS issue, lower(email) AS value, count(*)
FROM identity.users GROUP BY lower(email) HAVING count(*) > 1;

SELECT 'DUPLICATE_EVENT_MEMBERSHIPS' AS issue, event_id::text || ':' || user_id::text AS value, count(*)
FROM event.members GROUP BY event_id, user_id HAVING count(*) > 1;
