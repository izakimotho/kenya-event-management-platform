DO $$
DECLARE t RECORD;
BEGIN
  FOR t IN
    SELECT * FROM (VALUES
      ('identity','users'),('security','roles'),
      ('event','events'),('event','members'),
      ('planning','tasks'),('planning','budgets'),('planning','budget_items'),
      ('vendor','profiles'),('vendor','service_packages'),
      ('vendor','documents'),('vendor','verification_cases'),
      ('marketplace','enquiries'),('quotation','vendor_quotes'),
      ('notification','preferences')
    ) AS x(schema_name,table_name)
  LOOP
    EXECUTE format(
      'CREATE TRIGGER %I BEFORE UPDATE ON %I.%I FOR EACH ROW EXECUTE FUNCTION audit.set_last_updated()',
      'trg_' || t.table_name || '_last_updated', t.schema_name, t.table_name
    );
  END LOOP;
END $$;
