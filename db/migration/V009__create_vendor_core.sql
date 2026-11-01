CREATE TABLE vendor.profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES identity.users(id),
  business_name VARCHAR(200) NOT NULL,
  business_description TEXT,
  business_email VARCHAR(255),
  business_phone VARCHAR(25),
  website VARCHAR(500),
  logo_storage_key TEXT,
  cover_storage_key TEXT,
  business_type VARCHAR(100),
  verification_status VARCHAR(30) NOT NULL DEFAULT 'PENDING'
    CHECK (verification_status IN ('PENDING','UNDER_REVIEW','MORE_INFORMATION_REQUIRED','VERIFIED','REJECTED','SUSPENDED')),
  average_rating NUMERIC(3,2) NOT NULL DEFAULT 0 CHECK (average_rating BETWEEN 0 AND 5),
  total_reviews INTEGER NOT NULL DEFAULT 0 CHECK (total_reviews >= 0),
  active BOOLEAN NOT NULL DEFAULT TRUE,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_updated TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by UUID REFERENCES identity.users(id),
  updated_by UUID REFERENCES identity.users(id),
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_vendor_name ON vendor.profiles USING btree(business_name);
CREATE INDEX idx_vendor_verified_active ON vendor.profiles(verification_status,active)
WHERE is_deleted=FALSE;

CREATE TABLE vendor.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) NOT NULL UNIQUE,
  category_name VARCHAR(150) NOT NULL UNIQUE,
  description TEXT,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE vendor.category_mapping (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES vendor.profiles(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES vendor.categories(id),
  UNIQUE(vendor_id,category_id)
);

INSERT INTO vendor.categories(code,category_name) VALUES
('VENUE','Wedding Venues'),('CATERING','Catering Services'),
('PHOTOGRAPHY','Photography'),('VIDEOGRAPHY','Videography'),
('DECORATION','Event Decoration'),('MUSIC','DJs and Entertainment'),
('MC','Masters of Ceremony'),('BRIDAL','Bridal Services'),
('GROOM','Groom Services'),('CAKES','Wedding Cakes'),
('TRANSPORT','Wedding Transport'),('MAKEUP','Makeup and Beauty'),
('FASHION','Wedding Fashion'),('FLORIST','Florists'),
('PLANNING','Wedding Planners'),('TENT','Tents and Equipment'),
('CULTURAL','Traditional Ceremony Services');
