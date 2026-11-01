CREATE TABLE identity.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone_number VARCHAR(25),
  password_hash VARCHAR(255) NOT NULL,
  profile_image_key TEXT,
  account_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE'
    CHECK (account_status IN ('PENDING','ACTIVE','SUSPENDED','LOCKED','CLOSED')),
  email_verified BOOLEAN NOT NULL DEFAULT FALSE,
  phone_verified BOOLEAN NOT NULL DEFAULT FALSE,
  last_login TIMESTAMPTZ,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_updated TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by UUID,
  updated_by UUID,
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  deleted_by UUID,
  CONSTRAINT chk_users_email_nonempty CHECK (length(trim(email)) > 3)
);

CREATE UNIQUE INDEX uq_users_email_ci ON identity.users (lower(email));

CREATE UNIQUE INDEX uq_users_phone_active
ON identity.users(phone_number)
WHERE phone_number IS NOT NULL AND is_deleted = FALSE;

ALTER TABLE identity.users
  ADD CONSTRAINT fk_users_created_by FOREIGN KEY (created_by) REFERENCES identity.users(id),
  ADD CONSTRAINT fk_users_updated_by FOREIGN KEY (updated_by) REFERENCES identity.users(id),
  ADD CONSTRAINT fk_users_deleted_by FOREIGN KEY (deleted_by) REFERENCES identity.users(id);

CREATE TABLE identity.user_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES identity.users(id) ON DELETE CASCADE,
  refresh_token_hash VARCHAR(255) NOT NULL UNIQUE,
  device_label VARCHAR(200),
  ip_address INET,
  user_agent TEXT,
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (expires_at > date_created)
);

CREATE INDEX idx_user_sessions_user_expiry
ON identity.user_sessions(user_id, expires_at DESC);
