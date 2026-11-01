CREATE TABLE vendor.documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES vendor.profiles(id) ON DELETE CASCADE,
  document_type VARCHAR(50) NOT NULL
    CHECK (document_type IN ('BUSINESS_REGISTRATION','NATIONAL_ID','KRA_PIN','BUSINESS_PERMIT','BUSINESS_LICENSE','PORTFOLIO_EVIDENCE','OTHER')),
  document_name VARCHAR(200),
  storage_key TEXT NOT NULL,
  mime_type VARCHAR(100),
  file_size BIGINT CHECK (file_size IS NULL OR file_size >= 0),
  verification_status VARCHAR(30) NOT NULL DEFAULT 'PENDING'
    CHECK (verification_status IN ('PENDING','APPROVED','REJECTED','EXPIRED')),
  expiry_date DATE,
  uploaded_by UUID REFERENCES identity.users(id),
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_updated TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE vendor.verification_cases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES vendor.profiles(id),
  case_reference VARCHAR(50) NOT NULL UNIQUE,
  status VARCHAR(30) NOT NULL DEFAULT 'SUBMITTED'
    CHECK (status IN ('SUBMITTED','UNDER_REVIEW','MORE_INFORMATION_REQUIRED','APPROVED','REJECTED','CANCELLED')),
  assigned_admin_id UUID REFERENCES identity.users(id),
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ,
  remarks TEXT,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_updated TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE vendor.verification_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  case_id UUID NOT NULL REFERENCES vendor.verification_cases(id),
  reviewer_id UUID NOT NULL REFERENCES identity.users(id),
  decision VARCHAR(30) NOT NULL
    CHECK (decision IN ('APPROVED','REJECTED','MORE_INFORMATION_REQUIRED','COMMENTED')),
  remarks TEXT,
  reviewed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE vendor.verification_case_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  case_id UUID NOT NULL REFERENCES vendor.verification_cases(id) ON DELETE CASCADE,
  document_id UUID NOT NULL REFERENCES vendor.documents(id),
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(case_id,document_id)
);

CREATE TABLE vendor.status_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES vendor.profiles(id),
  previous_status VARCHAR(30),
  new_status VARCHAR(30) NOT NULL,
  changed_by UUID REFERENCES identity.users(id),
  reason TEXT,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_vendor_docs_vendor_status ON vendor.documents(vendor_id,verification_status);
CREATE INDEX idx_verification_queue ON vendor.verification_cases(status,submitted_at);
