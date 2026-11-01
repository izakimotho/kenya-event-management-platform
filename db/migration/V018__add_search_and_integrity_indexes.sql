CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX idx_vendor_business_name_trgm
ON vendor.profiles USING gin (business_name gin_trgm_ops);

CREATE INDEX idx_vendor_description_trgm
ON vendor.profiles USING gin (business_description gin_trgm_ops);

CREATE INDEX idx_event_public_discovery
ON event.events(event_date,county_id)
WHERE is_public=TRUE AND is_deleted=FALSE;

CREATE INDEX idx_verification_vendor_date
ON vendor.verification_cases(vendor_id,submitted_at DESC);

CREATE INDEX idx_quote_items_quote
ON quotation.vendor_quote_items(quote_id);

CREATE INDEX idx_enquiry_status_history
ON marketplace.enquiry_status_history(enquiry_id,date_created DESC);
