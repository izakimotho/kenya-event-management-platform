INSERT INTO security.roles(code, role_name, scope, description) VALUES
('SUPER_ADMIN','Super Administrator','GLOBAL','Full platform control'),
('ADMIN','Administrator','GLOBAL','Platform administration'),
('CUSTOMER','Customer','GLOBAL','Customer account'),
('VENDOR','Vendor','GLOBAL','Vendor account'),
('EVENT_PLANNER','Event Planner','GLOBAL','Professional event planner'),
('SUPPORT_AGENT','Support Agent','GLOBAL','Customer support'),
('FINANCE_ADMIN','Finance Administrator','GLOBAL','Finance operations'),
('VERIFICATION_OFFICER','Verification Officer','GLOBAL','Vendor verification'),
('EVENT_OWNER','Event Owner','EVENT','Full event control'),
('EVENT_CO_OWNER','Event Co-owner','EVENT','Shared event control'),
('EVENT_PLANNER_MEMBER','Event Planner','EVENT','Event planning access'),
('FAMILY_MEMBER','Family Member','EVENT','Limited family collaboration'),
('EVENT_VIEWER','Event Viewer','EVENT','Read-only event access');

INSERT INTO security.permissions(code,resource,action,description) VALUES
('USER_VIEW','USER','VIEW','View user'),
('USER_MANAGE','USER','MANAGE','Manage user accounts'),
('ROLE_MANAGE','ROLE','MANAGE','Manage roles'),
('PERMISSION_MANAGE','PERMISSION','MANAGE','Manage permissions'),
('EVENT_CREATE','EVENT','CREATE','Create event'),
('EVENT_VIEW','EVENT','VIEW','View event'),
('EVENT_UPDATE','EVENT','UPDATE','Update event'),
('EVENT_DELETE','EVENT','DELETE','Delete event'),
('EVENT_INVITE','EVENT','INVITE','Invite event collaborators'),
('EVENT_MEMBER_MANAGE','EVENT_MEMBER','MANAGE','Manage event members'),
('BUDGET_VIEW','BUDGET','VIEW','View event budget'),
('BUDGET_UPDATE','BUDGET','UPDATE','Update event budget'),
('TASK_CREATE','TASK','CREATE','Create planning task'),
('TASK_VIEW','TASK','VIEW','View planning task'),
('TASK_UPDATE','TASK','UPDATE','Update planning task'),
('VENDOR_VIEW','VENDOR','VIEW','View vendor profiles'),
('VENDOR_CREATE','VENDOR','CREATE','Register vendor'),
('VENDOR_UPDATE','VENDOR','UPDATE','Update vendor profile'),
('VENDOR_VERIFY','VENDOR','VERIFY','Approve vendor verification'),
('VENDOR_SUSPEND','VENDOR','SUSPEND','Suspend vendor'),
('ENQUIRY_CREATE','ENQUIRY','CREATE','Create vendor enquiry'),
('ENQUIRY_VIEW','ENQUIRY','VIEW','View authorized enquiry'),
('ENQUIRY_RESPOND','ENQUIRY','RESPOND','Respond to enquiry'),
('QUOTE_CREATE','QUOTE','CREATE','Create quotation'),
('QUOTE_UPDATE_DRAFT','QUOTE','UPDATE_DRAFT','Update draft quotation'),
('QUOTE_SEND','QUOTE','SEND','Send quotation'),
('QUOTE_ACCEPT','QUOTE','ACCEPT','Accept quotation'),
('REPORT_VIEW','REPORT','VIEW','View reports'),
('AUDIT_VIEW','AUDIT','VIEW','View audit records');

-- Global role grants. Event-scoped permissions are checked against event membership in application code.
INSERT INTO security.role_permissions(role_id,permission_id)
SELECT r.id,p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code='SUPER_ADMIN';

INSERT INTO security.role_permissions(role_id,permission_id)
SELECT r.id,p.id
FROM security.roles r
JOIN security.permissions p ON
  (r.code='ADMIN' AND p.code IN
    ('USER_VIEW','USER_MANAGE','EVENT_VIEW','VENDOR_VIEW','VENDOR_VERIFY',
     'VENDOR_SUSPEND','REPORT_VIEW','AUDIT_VIEW'))
  OR (r.code='CUSTOMER' AND p.code IN
    ('EVENT_CREATE','EVENT_VIEW','EVENT_UPDATE','EVENT_DELETE','EVENT_INVITE',
     'BUDGET_VIEW','BUDGET_UPDATE','TASK_CREATE','TASK_VIEW','TASK_UPDATE',
     'VENDOR_VIEW','ENQUIRY_CREATE','ENQUIRY_VIEW','QUOTE_ACCEPT'))
  OR (r.code='VENDOR' AND p.code IN
    ('VENDOR_VIEW','VENDOR_CREATE','VENDOR_UPDATE','ENQUIRY_VIEW',
     'ENQUIRY_RESPOND','QUOTE_CREATE','QUOTE_UPDATE_DRAFT','QUOTE_SEND'))
  OR (r.code='VERIFICATION_OFFICER' AND p.code IN
    ('VENDOR_VIEW','VENDOR_VERIFY'))
  OR (r.code='SUPPORT_AGENT' AND p.code IN
    ('USER_VIEW','EVENT_VIEW','VENDOR_VIEW','ENQUIRY_VIEW'))
  OR (r.code='FINANCE_ADMIN' AND p.code IN
    ('REPORT_VIEW','AUDIT_VIEW'));

-- Event roles are intentionally assigned no global grants.


-- Event-scoped role grants.
INSERT INTO security.role_permissions(role_id,permission_id)
SELECT r.id,p.id
FROM security.roles r
JOIN security.permissions p ON
  (r.code='EVENT_OWNER' AND p.code IN
    ('EVENT_VIEW','EVENT_UPDATE','EVENT_DELETE','EVENT_INVITE','EVENT_MEMBER_MANAGE',
     'BUDGET_VIEW','BUDGET_UPDATE','TASK_CREATE','TASK_VIEW','TASK_UPDATE',
     'VENDOR_VIEW','ENQUIRY_CREATE','ENQUIRY_VIEW','QUOTE_ACCEPT'))
  OR (r.code='EVENT_CO_OWNER' AND p.code IN
    ('EVENT_VIEW','EVENT_UPDATE','EVENT_INVITE','BUDGET_VIEW','BUDGET_UPDATE',
     'TASK_CREATE','TASK_VIEW','TASK_UPDATE','VENDOR_VIEW','ENQUIRY_CREATE',
     'ENQUIRY_VIEW','QUOTE_ACCEPT'))
  OR (r.code='EVENT_PLANNER_MEMBER' AND p.code IN
    ('EVENT_VIEW','TASK_CREATE','TASK_VIEW','TASK_UPDATE','BUDGET_VIEW',
     'VENDOR_VIEW','ENQUIRY_CREATE','ENQUIRY_VIEW'))
  OR (r.code='FAMILY_MEMBER' AND p.code IN
    ('EVENT_VIEW','TASK_VIEW','VENDOR_VIEW','ENQUIRY_VIEW'))
  OR (r.code='EVENT_VIEWER' AND p.code IN
    ('EVENT_VIEW','TASK_VIEW','BUDGET_VIEW','VENDOR_VIEW'));
