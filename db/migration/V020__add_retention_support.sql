-- Retention metadata supports scheduled cleanup/anonymization jobs.
-- Actual retention windows must be configured by policy and applicable law.
CREATE TABLE audit.retention_policies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  schema_name VARCHAR(100) NOT NULL,
  table_name VARCHAR(100) NOT NULL,
  retention_days INTEGER NOT NULL CHECK (retention_days > 0),
  action VARCHAR(30) NOT NULL CHECK (action IN ('DELETE','ANONYMIZE','ARCHIVE')),
  enabled BOOLEAN NOT NULL DEFAULT FALSE,
  legal_basis TEXT,
  last_updated TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(schema_name,table_name)
);

INSERT INTO audit.retention_policies(schema_name,table_name,retention_days,action,enabled,legal_basis) VALUES
('identity','user_sessions',90,'DELETE',TRUE,'Expired/revoked authentication sessions'),
('notification','notifications',180,'DELETE',FALSE,'Operational default; confirm retention policy'),
('marketplace','enquiry_messages',730,'ARCHIVE',FALSE,'Proposed operational default; legal review required'),
('audit','audit_logs',2555,'ARCHIVE',FALSE,'Proposed seven-year default; classify records and confirm legal basis');
