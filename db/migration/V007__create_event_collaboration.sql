CREATE TABLE event.members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES event.events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES identity.users(id),
  role_id UUID NOT NULL REFERENCES security.roles(id),
  relationship VARCHAR(40) CHECK (relationship IS NULL OR relationship IN
    ('BRIDE','GROOM','FATHER','MOTHER','BROTHER','SISTER','GUARDIAN','RELATIVE','PLANNER','OTHER')),
  membership_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
    CHECK (membership_status IN ('INVITED','ACTIVE','SUSPENDED','REMOVED')),
  invited_by UUID REFERENCES identity.users(id),
  joined_at TIMESTAMPTZ,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_updated TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(event_id,user_id)
);

CREATE TABLE event.invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES event.events(id) ON DELETE CASCADE,
  invited_by UUID NOT NULL REFERENCES identity.users(id),
  email VARCHAR(255),
  phone_number VARCHAR(25),
  role_id UUID NOT NULL REFERENCES security.roles(id),
  invitation_token_hash VARCHAR(255) NOT NULL UNIQUE,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
    CHECK (status IN ('PENDING','ACCEPTED','DECLINED','REVOKED','EXPIRED')),
  expires_at TIMESTAMPTZ NOT NULL,
  accepted_user_id UUID REFERENCES identity.users(id),
  accepted_at TIMESTAMPTZ,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (email IS NOT NULL OR phone_number IS NOT NULL)
);

CREATE INDEX idx_event_members_user ON event.members(user_id,membership_status);
CREATE INDEX idx_event_invitations_pending ON event.invitations(event_id,status);
