-- Ensure event-scoped roles are used for event membership, not global user-role grants.
CREATE OR REPLACE FUNCTION security.check_global_user_role_scope()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE role_scope VARCHAR(20);
BEGIN
  SELECT scope INTO role_scope FROM security.roles WHERE id=NEW.role_id;
  IF role_scope IS DISTINCT FROM 'GLOBAL' THEN
    RAISE EXCEPTION 'Only GLOBAL roles may be assigned in security.user_roles';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_user_role_global_scope
BEFORE INSERT OR UPDATE ON security.user_roles
FOR EACH ROW EXECUTE FUNCTION security.check_global_user_role_scope();

CREATE OR REPLACE FUNCTION event.check_event_role_scope()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE role_scope VARCHAR(20);
BEGIN
  SELECT scope INTO role_scope FROM security.roles WHERE id=NEW.role_id;
  IF role_scope IS DISTINCT FROM 'EVENT' THEN
    RAISE EXCEPTION 'Only EVENT roles may be assigned to event members';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_event_member_role_scope
BEFORE INSERT OR UPDATE ON event.members
FOR EACH ROW EXECUTE FUNCTION event.check_event_role_scope();

-- Quote version parent must be for the same enquiry. The FK to enquiry/vendor is already enforced.
CREATE OR REPLACE FUNCTION quotation.check_quote_revision_parent()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE parent_enquiry UUID;
BEGIN
  IF NEW.parent_quote_id IS NOT NULL THEN
    SELECT enquiry_id INTO parent_enquiry
    FROM quotation.vendor_quotes WHERE id=NEW.parent_quote_id;
    IF parent_enquiry IS DISTINCT FROM NEW.enquiry_id THEN
      RAISE EXCEPTION 'Parent quotation must belong to the same enquiry';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_quote_revision_parent
BEFORE INSERT OR UPDATE ON quotation.vendor_quotes
FOR EACH ROW EXECUTE FUNCTION quotation.check_quote_revision_parent();
