CREATE TABLE administration.actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_user_id UUID NOT NULL REFERENCES identity.users(id),
  target_user_id UUID REFERENCES identity.users(id),
  action VARCHAR(100) NOT NULL,
  target_type VARCHAR(100),
  target_id UUID,
  reason TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  correlation_id UUID,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_admin_actions_actor_date
ON administration.actions(actor_user_id,date_created DESC);
CREATE INDEX idx_admin_actions_target
ON administration.actions(target_type,target_id,date_created DESC);
