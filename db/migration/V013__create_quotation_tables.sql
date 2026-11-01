CREATE TABLE quotation.vendor_quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  enquiry_id UUID NOT NULL,
  vendor_id UUID NOT NULL,
  quote_reference VARCHAR(50) NOT NULL UNIQUE,
  version_number INTEGER NOT NULL DEFAULT 1 CHECK (version_number > 0),
  parent_quote_id UUID REFERENCES quotation.vendor_quotes(id),
  subtotal NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
  discount_amount NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
  tax_amount NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
  total_amount NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
  currency CHAR(3) NOT NULL DEFAULT 'KES',
  terms_and_conditions TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'DRAFT'
    CHECK (status IN ('DRAFT','SENT','ACCEPTED','DECLINED','EXPIRED','SUPERSEDED','WITHDRAWN')),
  valid_until TIMESTAMPTZ,
  sent_at TIMESTAMPTZ,
  responded_at TIMESTAMPTZ,
  created_by UUID NOT NULL REFERENCES identity.users(id),
  date_created TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_updated TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT fk_quote_enquiry_vendor
    FOREIGN KEY(enquiry_id,vendor_id)
    REFERENCES marketplace.enquiries(id,vendor_id),
  UNIQUE(enquiry_id,version_number),
  UNIQUE(id,enquiry_id)
);

CREATE TABLE quotation.vendor_quote_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quote_id UUID NOT NULL REFERENCES quotation.vendor_quotes(id),
  item_name VARCHAR(200) NOT NULL,
  description TEXT,
  quantity NUMERIC(12,2) NOT NULL DEFAULT 1 CHECK (quantity > 0),
  unit_price NUMERIC(14,2) NOT NULL CHECK (unit_price >= 0),
  total_price NUMERIC(14,2) NOT NULL CHECK (total_price >= 0),
  date_created TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_quotes_enquiry_version
ON quotation.vendor_quotes(enquiry_id,version_number DESC);
CREATE INDEX idx_quotes_vendor_status
ON quotation.vendor_quotes(vendor_id,status,date_created DESC);

CREATE TRIGGER trg_sent_quote_immutable
BEFORE UPDATE OR DELETE ON quotation.vendor_quotes
FOR EACH ROW EXECUTE FUNCTION audit.prevent_mutation_of_sent_quote();

CREATE OR REPLACE FUNCTION quotation.prevent_sent_quote_item_mutation()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE quote_status VARCHAR(20);
BEGIN
  IF TG_OP = 'DELETE' THEN
    SELECT status INTO quote_status FROM quotation.vendor_quotes WHERE id = OLD.quote_id;
  ELSE
    SELECT status INTO quote_status FROM quotation.vendor_quotes WHERE id = NEW.quote_id;
  END IF;
  IF quote_status IN ('SENT','ACCEPTED','DECLINED','EXPIRED','SUPERSEDED') THEN
    RAISE EXCEPTION 'Items of sent/final quotations are immutable';
  END IF;
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_quote_items_immutable
BEFORE INSERT OR UPDATE OR DELETE ON quotation.vendor_quote_items
FOR EACH ROW EXECUTE FUNCTION quotation.prevent_sent_quote_item_mutation();
