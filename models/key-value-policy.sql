-- =========================================
-- FILE: wide_column_rbac_pg.sql
-- Mô phỏng Key-Value RBAC với dữ liệu JSON cho PostgreSQL
-- =========================================

-- 1. Tạo bảng (chạy trong database đã tạo, ví dụ: wide_column)
CREATE TABLE IF NOT EXISTS subjects (
    row_key VARCHAR(50) PRIMARY KEY,
    value JSONB
);

CREATE TABLE IF NOT EXISTS objects (
    row_key VARCHAR(50) PRIMARY KEY,
    value JSONB
);

CREATE TABLE IF NOT EXISTS access_policy (
    row_key VARCHAR(50) PRIMARY KEY,
    value JSONB
);

-- 2. Insert dữ liệu JSON
-- Subjects
INSERT INTO subjects (row_key, value) VALUES
('user:1', '{"username":"alice","group_name":"dev","department":"it"}'),
('user:2', '{"username":"bob","group_name":"dev","department":"it"}'),
('user:3', '{"username":"charlie","group_name":"qa","department":"it"}'),
('user:4', '{"username":"david","group_name":"recruiting","department":"hr"}'),
('user:5', '{"username":"eve","group_name":"payroll","department":"hr"}'),
('user:6', '{"username":"frank","group_name":"north","department":"sales"}'),
('user:7', '{"username":"grace","group_name":"south","department":"sales"}');

-- Objects
INSERT INTO objects (row_key, value) VALUES
('file:1', '{"company":"ABC","branch":"engineering","file_name":"product_spec.pdf"}'),
('file:2', '{"company":"ABC","branch":"engineering","file_name":"architecture.doc"}'),
('file:3', '{"company":"ABC","branch":"research","file_name":"research_paper.pdf"}'),
('file:4', '{"company":"financecorp","branch":"main","file_name":"financial_report.xlsx"}'),
('file:5', '{"company":"financecorp","branch":"audit","file_name":"audit_log.txt"}');

-- Access Policy
INSERT INTO access_policy (row_key, value) VALUES
('ap:1', '{"username":"alice","company":"ABC","branch":"engineering","file_name":"product_spec.pdf","allowed":true}'),
('ap:2', '{"username":"alice","company":"ABC","branch":"engineering","file_name":"architecture.doc","allowed":true}'),
('ap:3', '{"username":"bob","group_name":"dev","department":"it","company":"ABC","branch":"engineering","file_name":"product_spec.pdf","allowed":true}');

-- =========================================
-- 3. Query kiểm tra phân quyền theo 4 level
-- =========================================

-- 3.1 User Level
SELECT value->>'file_name' AS file
FROM access_policy
WHERE value->>'username'='alice'
  AND value->>'company'='ABC'
  AND value->>'branch'='engineering';

-- 3.2 Group Level
SELECT value->>'username' AS user,
       value->>'file_name' AS file
FROM access_policy
WHERE value->>'group_name'='dev'
  AND value->>'department'='it'
  AND value->>'company'='ABC'
  AND value->>'branch'='engineering';

-- 3.3 Department Level
SELECT value->>'username' AS user,
       value->>'file_name' AS file
FROM access_policy
WHERE value->>'department'='hr'
  AND value->>'company'='ABC'
  AND value->>'branch'='research';

-- 3.4 Branch Level
SELECT value->>'username' AS user,
       value->>'file_name' AS file
FROM access_policy
WHERE value->>'company'='ABC'
  AND value->>'branch'='engineering';
