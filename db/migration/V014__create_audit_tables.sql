CREATE TABLE audit.audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES identity.users(id),
  action VARCHAR(100) NOT NULL,
  entity_name VARCHAR(150) NOT NULL,
  entity_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address INET,
  user_agent TEXT,
  correlation_id UUID,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_audit_entity ON audit.audit_logs(entity_name,entity_id,date_created DESC);
CREATE INDEX idx_audit_user_date ON audit.audit_logs(user_id,date_created DESC);

-- Application DB role should receive INSERT/SELECT only on audit.audit_logs.
-- Do not grant UPDATE or DELETE to the application role.
