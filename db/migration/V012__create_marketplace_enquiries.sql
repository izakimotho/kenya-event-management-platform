CREATE TABLE marketplace.enquiries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES event.events(id),
  customer_id UUID NOT NULL REFERENCES identity.users(id),
  vendor_id UUID NOT NULL REFERENCES vendor.profiles(id),
  package_id UUID,
  enquiry_reference VARCHAR(50) NOT NULL UNIQUE,
  subject VARCHAR(200),
  message TEXT NOT NULL,
  proposed_event_date DATE,
  expected_guests INTEGER CHECK (expected_guests IS NULL OR expected_guests >= 0),
  budget_estimate NUMERIC(14,2) CHECK (budget_estimate IS NULL OR budget_estimate >= 0),
  status VARCHAR(30) NOT NULL DEFAULT 'NEW'
    CHECK (status IN ('NEW','VIEWED','RESPONDED','QUOTATION_SENT','REVISION_REQUESTED','ACCEPTED','DECLINED','CLOSED','EXPIRED')),
  response_due_at TIMESTAMPTZ,
  first_viewed_at TIMESTAMPTZ,
  vendor_response TEXT,
  responded_at TIMESTAMPTZ,
  closed_at TIMESTAMPTZ,
  closure_reason VARCHAR(200),
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_updated TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(id,vendor_id),
  CONSTRAINT fk_enquiry_vendor_package
    FOREIGN KEY(vendor_id,package_id)
    REFERENCES vendor.service_packages(vendor_id,id)
);

CREATE TABLE marketplace.enquiry_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  enquiry_id UUID NOT NULL REFERENCES marketplace.enquiries(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES identity.users(id),
  message TEXT NOT NULL,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE marketplace.enquiry_status_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  enquiry_id UUID NOT NULL REFERENCES marketplace.enquiries(id),
  previous_status VARCHAR(30),
  new_status VARCHAR(30) NOT NULL,
  changed_by UUID NOT NULL REFERENCES identity.users(id),
  remarks TEXT,
  date_created TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE marketplace.enquiry_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  enquiry_id UUID NOT NULL REFERENCES marketplace.enquiries(id) ON DELETE CASCADE,
  uploaded_by UUID NOT NULL REFERENCES identity.users(id),
  storage_key TEXT NOT NULL,
  file_name VARCHAR(255),
  mime_type VARCHAR(100),
  file_size BIGINT CHECK (file_size IS NULL OR file_size >= 0),
  date_created TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_enquiry_vendor_status_date
ON marketplace.enquiries(vendor_id,status,date_created DESC);
CREATE INDEX idx_enquiry_customer_date
ON marketplace.enquiries(customer_id,date_created DESC);
CREATE INDEX idx_enquiry_messages_date
ON marketplace.enquiry_messages(enquiry_id,date_created);
