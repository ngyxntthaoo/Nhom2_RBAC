USE wide_column;

-- ==========================================
-- 1. Dọn sạch các bảng
-- ==========================================
DROP TABLE IF EXISTS organization_subjects;
DROP TABLE IF EXISTS company_objects;
DROP TABLE IF EXISTS access_policy;

-- ==========================================
-- 2. Column Family cho Subjects (Cấp 5: clearance_level)
-- ==========================================
CREATE TABLE organization_subjects (
    -- C3: Row (Partition Key)
    department text,
    division text,
    -- C3/C4: Clustering Columns / Column ID
    group_name text,
    username text,
    -- C5: Value/Leaf Attributes
    user_id text,
    role text,
    clearance_level int, -- Thuộc tính Cấp 5
    organization text,
    PRIMARY KEY ((department, division), group_name, username)
);

-- ==========================================
-- 3. Column Family cho Objects (Cấp 5: classification)
-- ==========================================
CREATE TABLE company_objects (
    -- C3: Row (Partition Key)
    company text,
    division text,
    -- C3/C4: Clustering Columns / Column ID
    branch text,
    file_name text,
    -- C5: Value/Leaf Attributes
    file_id text,
    file_type text,
    classification int, -- Thuộc tính Cấp 5
    organization text,
    PRIMARY KEY ((company, division), branch, file_name)
);

-- ==========================================
-- 4. Column Family cho Access Policy (Lưu trữ ABAC Tuple)
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
    -- Cấp 5: Thuộc tính Chủ thể (Chứa các nút lá của Tuple)
    subject_attrs map<text, text>,
    -- Cấp 5: Thuộc tính Đối tượng (Chứa các nút lá của Tuple)
    object_attrs map<text, text>,
    -- Cấp 5: Điều kiện bổ sung
    conditions map<text, text>,
    -- Các nút phân cấp
    department text,
    division text,
    group_name text,
    company text,
    branch text,
    PRIMARY KEY ((query_type, query_scope, username), organization, file_name)
);

-- Subject 1: Alice (Clearance Level 3)
INSERT INTO organization_subjects (department, division, group_name, username, user_id, role, clearance_level, organization)
VALUES ('it', 'engineering', 'dev', 'alice', 'user1', 'developer', 3, 'ABCorg');

-- Object 1: product_spec.pdf (Classification 3)
INSERT INTO company_objects (company, division, branch, file_name, file_id, file_type, classification, organization)
VALUES ('ABC', 'engineering', 'hq', 'product_spec.pdf', 'file1', 'pdf', 3, 'ABCorg');

-- Object 2: architecture.doc (Classification 5 - Rất bảo mật)
INSERT INTO company_objects (company, division, branch, file_name, file_id, file_type, classification, organization)
VALUES ('ABC', 'engineering', 'hq', 'architecture.doc', 'file2', 'doc', 5, 'ABCorg');

-- Tuple 1: Alice - Cho phép Đọc product_spec.pdf
INSERT INTO access_policy (
    query_type, query_scope, username, organization, file_name,
    allowed, permission_type, policy_id,
    subject_attrs, object_attrs, conditions,
    department, division, group_name, company, branch
) VALUES (
    'user', 'ABCorg', 'alice', 'ABCorg', 'product_spec.pdf',
    true, 'read', 'policy1',
    -- Cấp 5: Thuộc tính Chủ thể
    {'username': 'alice', 'clearance': '3'},
    -- Cấp 5: Thuộc tính Đối tượng
    {'file': 'product_spec.pdf', 'classification': '3'},
    {'clearance_check': 'passed'},
    'it', 'engineering', 'dev', 'ABC', 'hq'
);

-- Tuple 2: Alice - Từ chối Đọc architecture.doc
INSERT INTO access_policy (
    query_type, query_scope, username, organization, file_name,
    allowed, permission_type, policy_id,
    subject_attrs, object_attrs, conditions,
    department, division, group_name, company, branch
) VALUES (
    'user', 'ABCorg', 'alice', 'ABCorg', 'architecture.doc',
    false, 'deny', 'policy2',
    -- Cấp 5: Thuộc tính Chủ thể
    {'username': 'alice', 'clearance': '3'},
    -- Cấp 5: Thuộc tính Đối tượng
    {'file': 'architecture.doc', 'classification': '5'},
    {'clearance_check': 'failed', 'reason': 'insufficient_clearance'},
    'it', 'engineering', 'dev', 'ABC', 'hq'
);

-- Policy 12: Group 'dev' read product_spec.pdf
INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch, subject_attrs, object_attrs)
VALUES ('group', 'ABCorg', '', 'ABCorg', 'product_spec.pdf', true, 'read', 'policy12', 'it', 'engineering', 'dev', 'ABC', 'hq', {'group': 'dev'}, {'classification': '3'});

-- Policy 13: Group 'dev' read architecture.doc
INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch, subject_attrs, object_attrs)
VALUES ('group', 'ABCorg', '', 'ABCorg', 'architecture.doc', true, 'read', 'policy13', 'it', 'engineering', 'dev', 'ABC', 'hq', {'group': 'dev'}, {'classification': '5'});

-- Policy 14: Department 'it' read product_spec.pdf
INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch, subject_attrs, object_attrs)
VALUES ('department', 'ABCorg', '', 'ABCorg', 'product_spec.pdf', true, 'read', 'policy14', 'it', 'engineering', '', 'ABC', 'hq', {'department': 'it'}, {'classification': '3'});

-- Policy 15: Department 'it' read architecture.doc
INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch, subject_attrs, object_attrs)
VALUES ('department', 'ABCorg', '', 'ABCorg', 'architecture.doc', true, 'read', 'policy15', 'it', 'engineering', '', 'ABC', 'hq', {'department': 'it'}, {'classification': '5'});

-- Policy 16: Division 'engineering' read product_spec.pdf
INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch, subject_attrs, object_attrs)
VALUES ('division', 'ABCorg', '', 'ABCorg', 'product_spec.pdf', true, 'read', 'policy16', '', 'engineering', '', 'ABC', 'hq', {'division': 'engineering'}, {'classification': '3'});

-- Policy 17: Division 'engineering' read architecture.doc
INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch, subject_attrs, object_attrs)
VALUES ('division', 'ABCorg', '', 'ABCorg', 'architecture.doc', true, 'read', 'policy17', '', 'engineering', '', 'ABC', 'hq', {'division': 'engineering'}, {'classification': '5'});

-- Policy 18: User 'eve' read audit_log.txt (Giả định Eve có clearance 4, file classification 4)
INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch, subject_attrs, object_attrs)
VALUES ('user', 'FinanceCorp', 'eve', 'FinanceCorp', 'audit_log.txt', true, 'read', 'policy18', 'finance', 'finance_ops', 'payroll', 'Finance', 'audit', {'username': 'eve', 'clearance': '4'}, {'classification': '4'});

-- Policy 19: User 'eve' read financial_report.pdf (Giả định Eve có clearance 4, file classification 4)
INSERT INTO access_policy (query_type, query_scope, username, organization, file_name, allowed, permission_type, policy_id, department, division, group_name, company, branch, subject_attrs, object_attrs)
VALUES ('user', 'FinanceCorp', 'eve', 'FinanceCorp', 'financial_report.pdf', true, 'read', 'policy19', 'finance', 'finance_ops', 'payroll', 'Finance', 'audit', {'username': 'eve', 'clearance': '4'}, {'classification': '4'});

-- Lấy toàn bộ Tuple của Alice cho product_spec.pdf
SELECT
    username,               -- Chủ thể (C4)
    file_name,              -- Đối tượng (C4)
    permission_type,        -- Hành động
    allowed,                -- Quyền
    department, division, group_name, -- Nút Chủ thể (C3/C4)
    company, branch,                  -- Nút Đối tượng (C3/C4)
    subject_attrs,          -- Thuộc tính Nút lá Subject (C5)
    object_attrs,           -- Thuộc tính Nút lá Object (C5)
    conditions              -- Điều kiện (C5)
FROM access_policy
WHERE query_type = 'user'
    AND query_scope = 'ABCorg'
    AND username = 'alice'
    AND organization = 'ABCorg'
    AND file_name = 'product_spec.pdf';


-- Tìm tất cả các chính sách (Tuples) áp dụng cho chủ thể có clearance '3'
SELECT
    username,
    file_name,
    permission_type,
    allowed,
    subject_attrs['clearance'] AS subject_clearance,    -- Truy xuất thuộc tính Cấp 5
    object_attrs['classification'] AS file_classification -- Truy xuất thuộc tính Cấp 5
FROM access_policy
WHERE subject_attrs CONTAINS '3'
    AND subject_attrs CONTAINS KEY 'clearance'  -- ĐÃ SỬA LỖI TẠI ĐÂY
ALLOW FILTERING;

-- Query 2: Kiểm tra quyền của group dev trong ABCorg (policy 12,13)
SELECT username, group_name, organization, file_name, company, branch, allowed, permission_type, policy_id
FROM access_policy 
WHERE query_type = 'group' 
  AND query_scope = 'ABCorg'
  AND username = '';


-- Query 3: Kiểm tra quyền của department it trong ABCorg (policy 14,15)
SELECT username, group_name, department, organization, file_name, company, branch, allowed, permission_type, policy_id
FROM access_policy 
WHERE query_type = 'department' 
  AND query_scope = 'ABCorg'
  AND username = '';

-- Query 4: Kiểm tra quyền của division engineering trong ABCorg (policy 16,17)
SELECT division, organization, file_name, company, branch, allowed, permission_type, policy_id
FROM access_policy 
WHERE query_type = 'division' 
  AND query_scope = 'ABCorg'
  AND username = '';

-- Query 5: Kiểm tra tất cả quyền của user eve trong FinanceCorp (policy 18,19)
SELECT username, organization, file_name, company, branch, allowed, permission_type, policy_id
FROM access_policy 
WHERE query_type = 'user' 
  AND query_scope = 'FinanceCorp'
  AND username = 'eve';