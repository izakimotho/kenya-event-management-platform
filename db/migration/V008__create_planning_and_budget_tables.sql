CREATE TABLE planning.tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES event.events(id) ON DELETE CASCADE,
  task_name VARCHAR(200) NOT NULL,
  description TEXT,
  category VARCHAR(100),
  assigned_to UUID REFERENCES identity.users(id),
  due_date DATE,
  priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM'
    CHECK (priority IN ('LOW','MEDIUM','HIGH','URGENT')),
  task_status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
    CHECK (task_status IN ('PENDING','IN_PROGRESS','BLOCKED','COMPLETED','CANCELLED')),
  completed_at TIMESTAMPTZ,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_updated TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by UUID REFERENCES identity.users(id),
  updated_by UUID REFERENCES identity.users(id),
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE planning.budgets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES event.events(id) ON DELETE CASCADE,
  budget_name VARCHAR(150) NOT NULL,
  total_budget NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (total_budget >= 0),
  currency CHAR(3) NOT NULL DEFAULT 'KES',
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_updated TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(event_id,budget_name)
);

CREATE TABLE planning.budget_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  budget_id UUID NOT NULL REFERENCES planning.budgets(id) ON DELETE CASCADE,
  item_name VARCHAR(200) NOT NULL,
  category VARCHAR(100),
  estimated_cost NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (estimated_cost >= 0),
  actual_cost NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (actual_cost >= 0),
  notes TEXT,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_updated TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_tasks_event_status_due ON planning.tasks(event_id,task_status,due_date)
WHERE is_deleted=FALSE;
