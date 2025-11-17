USE wide_column;

-- ==========================================
-- 1. Dọn sạch các bảng
-- ==========================================
DROP TABLE IF EXISTS organization_subjects;
DROP TABLE IF EXISTS company_objects;
DROP TABLE IF EXISTS access_policy;

-- ==========================================
-- 2. Column Family cho Subjects theo phân cấp Tổ chức
-- ==========================================
CREATE TABLE organization_subjects (
    department text,
    division text,
    group_name text,
    username text,
    user_id text,
    full_name text,
    role text,
    organization text,
    PRIMARY KEY ((department, division), group_name, username)
);

-- ==========================================
-- 3. Column Family cho Objects theo phân cấp Công ty
-- ==========================================
CREATE TABLE company_objects (
    company text,
    division text,
    branch text,
    file_name text,
    file_id text,
    file_type text,
    file_size bigint,
    created_date timestamp,
    organization text,
    PRIMARY KEY ((company, division), branch, file_name)
);

-- ==========================================
-- 4. Column Family cho Access Policy (SỬA LẠI PRIMARY KEY - ĐƠN GIẢN HÓA)
-- ==========================================
CREATE TABLE access_policy (
    query_type text,
    query_scope text,
    username text,
    organization text,
    file_name text,
    allowed boolean,
    permission_type text,
    policy_id text,
    department text,
    division text,
    group_name text,
    company text,
    branch text,
    PRIMARY KEY ((query_type, query_scope, username), organization, file_name)
);

-- ==========================================
-- 5. Thêm dữ liệu Subjects (5 users)
-- ==========================================
INSERT INTO organization_subjects (department, division, group_name, username, user_id, full_name, role, organization) 
VALUES ('it', 'engineering', 'dev', 'alice', 'user1', 'Alice Johnson', 'developer', 'ABCorg');

INSERT INTO organization_subjects (department, division, group_name, username, user_id, full_name, role, organization) 
VALUES ('finance', 'finance_ops', 'payroll', 'eve', 'user5', 'Eve Davis', 'payroll_specialist', 'FinanceCorp');

-- ==========================================
-- 6. Thêm dữ liệu Objects
-- ==========================================
INSERT INTO company_objects (company, division, branch, file_name, file_id, file_type, file_size, created_date, organization) 
VALUES ('ABC', 'engineering', 'hq', 'product_spec.pdf', 'file1', 'pdf', 1048576, '2024-01-15', 'ABCorg');

INSERT INTO company_objects (company, division, branch, file_name, file_id, file_type, file_size, created_date, organization) 
VALUES ('ABC', 'engineering', 'hq', 'architecture.doc', 'file2', 'doc', 2097152, '2024-01-20', 'ABCorg');

INSERT INTO company_objects (company, division, branch, file_name, file_id, file_type, file_size, created_date, organization) 
VALUES ('Finance', 'finance_ops', 'audit', 'audit_log.txt', 'file4', 'txt', 131072, '2024-01-10', 'FinanceCorp');

INSERT INTO company_objects (company, division, branch, file_name, file_id, file_type, file_size, created_date, organization) 
VALUES ('Finance', 'finance_ops', 'audit', 'financial_report.pdf', 'file5', 'pdf', 2097152, '2024-01-25', 'FinanceCorp');

-- ==========================================
-- 7. Thêm Access Policies (SỬA LẠI CHO PHÙ HỢP VỚI PRIMARY KEY MỚI)
-- ==========================================
INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch) 
VALUES ('user', 'ABCorg', 'alice', 'ABCorg', 'product_spec.pdf', true, 'read', 'policy1', 'it', 'engineering', 'dev', 'ABC', 'hq');

INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch) 
VALUES ('user', 'ABCorg', 'alice', 'ABCorg', 'architecture.doc', true, 'read', 'policy2', 'it', 'engineering', 'dev', 'ABC', 'hq');

-- Rule 2: Group-level - Nhóm dev có quyền read (dùng user rỗng cho group level)
INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch) 
VALUES ('group', 'ABCorg', '', 'ABCorg', 'product_spec.pdf', true, 'read', 'policy3', 'it', 'engineering', 'dev', 'ABC', 'hq');

INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch) 
VALUES ('group', 'ABCorg', '', 'ABCorg', 'architecture.doc', true, 'read', 'policy4', 'it', 'engineering', 'dev', 'ABC', 'hq');

-- Rule 3: Department-level - Department it có quyền
INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch) 
VALUES ('department', 'ABCorg', '', 'ABCorg', 'product_spec.pdf', true, 'read', 'policy5', 'it', '', '', 'ABC', 'hq');

INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch) 
VALUES ('department', 'ABCorg', '', 'ABCorg', 'architecture.doc', true, 'read', 'policy6', 'it', '', '', 'ABC', 'hq');

-- Rule 4: Division-level - Division engineering có quyền
INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch) 
VALUES ('division', 'ABCorg', '', 'ABCorg', 'product_spec.pdf', true, 'read', 'policy7', '', 'engineering', '', 'ABC', 'hq');

INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch) 
VALUES ('division', 'ABCorg', '', 'ABCorg', 'architecture.doc', true, 'read', 'policy8', '', 'engineering', '', 'ABC', 'hq');

-- Rule 5: User Eve - DENY product_spec.pdf trong ABCorg
INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch) 
VALUES ('user', 'FinanceCorp', 'eve', 'ABCorg', 'product_spec.pdf', false, 'deny', 'policy9', 'finance', 'finance_ops', 'payroll', 'ABC', 'hq');

-- Rule 6: User Eve - ALLOW financial_report.pdf trong FinanceCorp
INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch) 
VALUES ('user', 'FinanceCorp', 'eve', 'FinanceCorp', 'financial_report.pdf', true, 'read', 'policy10', 'finance', 'finance_ops', 'payroll', 'Finance', 'audit');

-- Rule 7: User Eve - ALLOW audit_log.txt trong FinanceCorp
INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch) 
VALUES ('user', 'FinanceCorp', 'eve', 'FinanceCorp', 'audit_log.txt', true, 'read', 'policy11', 'finance', 'finance_ops', 'payroll', 'Finance', 'audit');

-- ==========================================
-- 8. TRUY VẤN KIỂM TRA (SỬA LẠI - ĐƠN GIẢN HÓA)
-- ==========================================

-- Query 1: Kiểm tra tất cả quyền của user alice trong ABCorg organization đọc được file nào quản lý bởi branch ở ABC organization
SELECT username, organization, file_name, company, branch, allowed, permission_type, policy_id
FROM access_policy 
WHERE query_type = 'user' 
  AND query_scope = 'ABCorg' 
  AND organization = 'ABCorg' 
  AND username = 'alice';

-- Query 2: Kiểm tra quyền của group dev trong ABCorg
SELECT username, group_name, organization, file_name, company, branch, allowed, permission_type, policy_id
FROM access_policy 
WHERE query_type = 'group' 
  AND query_scope = 'ABCorg'
  AND username = '';

-- Query 3: Kiểm tra quyền của department it trong ABCorg
SELECT username, group_name, department, organization, file_name, company, branch, allowed, permission_type, policy_id
FROM access_policy 
WHERE query_type = 'department' 
  AND query_scope = 'ABCorg'
  AND username = '';

-- Query 4: Kiểm tra quyền của division engineering trong ABCorg
SELECT division, organization, file_name, company, branch, allowed, permission_type, policy_id
FROM access_policy 
WHERE query_type = 'division' 
  AND query_scope = 'ABCorg'
  AND username = '';

-- Query 5: Kiểm tra tất cả quyền của user eve trong FinanceCorp
SELECT username, organization, file_name, company, branch, allowed, permission_type, policy_id
FROM access_policy 
WHERE query_type = 'user' 
  AND query_scope = 'FinanceCorp'
  AND username = 'eve';

-- ==========================================
-- 9. TRUY VẤN PHÂN TÍCH TỔNG QUAN
-- ==========================================

-- Hiển thị tất cả policies để kiểm tra
SELECT username, group_name, department, organization, file_name, branch,company, allowed, permission_type, policy_id
FROM access_policy;