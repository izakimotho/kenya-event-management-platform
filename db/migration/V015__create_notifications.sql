CREATE TABLE notification.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES identity.users(id),
  notification_type VARCHAR(80) NOT NULL,
  channel VARCHAR(20) NOT NULL CHECK (channel IN ('IN_APP','EMAIL','SMS','PUSH')),
  subject VARCHAR(200),
  body TEXT NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
    CHECK (status IN ('PENDING','QUEUED','SENT','DELIVERED','FAILED','READ')),
  scheduled_at TIMESTAMPTZ,
  sent_at TIMESTAMPTZ,
  read_at TIMESTAMPTZ,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE notification.preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES identity.users(id) ON DELETE CASCADE,
  notification_type VARCHAR(80) NOT NULL,
  channel VARCHAR(20) NOT NULL CHECK (channel IN ('IN_APP','EMAIL','SMS','PUSH')),
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  last_updated TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id,notification_type,channel)
);

CREATE INDEX idx_notifications_user_status_date
ON notification.notifications(user_id,status,date_created DESC);
