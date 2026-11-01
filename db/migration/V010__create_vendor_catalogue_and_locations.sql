CREATE TABLE vendor.service_packages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES vendor.profiles(id) ON DELETE CASCADE,
  package_name VARCHAR(200) NOT NULL,
  description TEXT,
  price NUMERIC(14,2) CHECK (price IS NULL OR price >= 0),
  currency CHAR(3) NOT NULL DEFAULT 'KES',
  pricing_type VARCHAR(30) NOT NULL DEFAULT 'FIXED'
    CHECK (pricing_type IN ('FIXED','STARTING_FROM','PER_PERSON','CUSTOM_QUOTE')),
  inclusions JSONB NOT NULL DEFAULT '[]'::jsonb
    CHECK (jsonb_typeof(inclusions)='array'),
  active BOOLEAN NOT NULL DEFAULT TRUE,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_updated TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(vendor_id,id)
);

CREATE TABLE vendor.portfolio (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES vendor.profiles(id) ON DELETE CASCADE,
  title VARCHAR(200),
  description TEXT,
  storage_key TEXT NOT NULL,
  media_type VARCHAR(20) NOT NULL DEFAULT 'IMAGE'
    CHECK (media_type IN ('IMAGE','VIDEO')),
  display_order INTEGER NOT NULL DEFAULT 0,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE vendor.service_areas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES vendor.profiles(id) ON DELETE CASCADE,
  county_id UUID NOT NULL REFERENCES geography.counties(id),
  town VARCHAR(150) NOT NULL DEFAULT '',
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(vendor_id,county_id,town)
);

CREATE INDEX idx_vendor_category_lookup ON vendor.category_mapping(category_id,vendor_id);
CREATE INDEX idx_vendor_service_area_lookup ON vendor.service_areas(county_id,vendor_id);
CREATE INDEX idx_vendor_packages_active ON vendor.service_packages(vendor_id,active);
