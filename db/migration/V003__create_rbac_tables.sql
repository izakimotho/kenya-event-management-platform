CREATE TABLE security.roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(60) NOT NULL UNIQUE,
  role_name VARCHAR(120) NOT NULL,
  scope VARCHAR(20) NOT NULL CHECK (scope IN ('GLOBAL','EVENT')),
  description TEXT,
  is_system BOOLEAN NOT NULL DEFAULT TRUE,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_updated TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE security.permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(120) NOT NULL UNIQUE,
  resource VARCHAR(80) NOT NULL,
  action VARCHAR(60) NOT NULL,
  description TEXT,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(resource, action)
);

CREATE TABLE security.role_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_id UUID NOT NULL REFERENCES security.roles(id) ON DELETE CASCADE,
  permission_id UUID NOT NULL REFERENCES security.permissions(id) ON DELETE CASCADE,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(role_id, permission_id)
);

CREATE TABLE security.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES identity.users(id) ON DELETE CASCADE,
  role_id UUID NOT NULL REFERENCES security.roles(id),
  assigned_by UUID REFERENCES identity.users(id),
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ,
  CHECK (expires_at IS NULL OR expires_at > assigned_at),
  UNIQUE(user_id, role_id)
);

CREATE TABLE security.user_role_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES identity.users(id),
  role_id UUID NOT NULL REFERENCES security.roles(id),
  action VARCHAR(20) NOT NULL CHECK (action IN ('ASSIGNED','REVOKED','EXPIRED')),
  changed_by UUID REFERENCES identity.users(id),
  reason TEXT,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_user_roles_user ON security.user_roles(user_id);
CREATE INDEX idx_role_permissions_role ON security.role_permissions(role_id);
