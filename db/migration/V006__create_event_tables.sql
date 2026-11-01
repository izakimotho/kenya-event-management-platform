CREATE TABLE event.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES identity.users(id),
  event_name VARCHAR(200) NOT NULL,
  event_type VARCHAR(40) NOT NULL CHECK (event_type IN ('WEDDING','TRADITIONAL')),
  description TEXT,
  event_date DATE,
  start_time TIME,
  end_time TIME,
  expected_guests INTEGER CHECK (expected_guests IS NULL OR expected_guests >= 0),
  county_id UUID REFERENCES geography.counties(id),
  town VARCHAR(150),
  venue_name VARCHAR(200),
  venue_address TEXT,
  estimated_budget NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (estimated_budget >= 0),
  currency CHAR(3) NOT NULL DEFAULT 'KES',
  event_status VARCHAR(30) NOT NULL DEFAULT 'PLANNING'
    CHECK (event_status IN ('DRAFT','PLANNING','IN_PROGRESS','COMPLETED','CANCELLED','ARCHIVED')),
  is_public BOOLEAN NOT NULL DEFAULT FALSE,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_updated TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by UUID REFERENCES identity.users(id),
  updated_by UUID REFERENCES identity.users(id),
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  deleted_by UUID REFERENCES identity.users(id),
  CHECK (start_time IS NULL OR end_time IS NULL OR end_time > start_time)
);

CREATE INDEX idx_events_owner_status ON event.events(owner_id,event_status)
WHERE is_deleted=FALSE;
CREATE INDEX idx_events_date ON event.events(event_date) WHERE is_deleted=FALSE;
