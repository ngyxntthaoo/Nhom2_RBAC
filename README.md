## Dự án triển khai 4 mô hình NoSQL khác nhau để phân tích quy tắc kiểm soát truy cập phân cấp

### 🛠️ Công Nghệ Sử Dụng
- Python 3.13+
- Jupyter Notebook
- Databases:
  - SQLite (Key-Value simulation)
  - MongoDB 7.0+ (Document)
  - Cassandra 4.0+ (Wide-Column)
  - Neo4j 5.0+ (Graph)
- **Libraries**: pymongo, neo4j, pandas, cryptography (Mã hóa dữ liệu nhạy cảm), python-dotenv (Quản lý biến môi trường), google-generativeai (API Gemini AI)
    
| File                         | Công nghệ / Mô hình dữ liệu sử dụng         |
| ---------------------------- | ------------------------------------------- |
| 3.2-document-model.ipynb | Python + MongoDB (mô hình Document Store)   |
| 3.2-graph-model.cypher   | Cypher + Neo4j (mô hình Graph Database)     |
| 3.2-key-value.ipynb     | Python + SQLite (mô phỏng Key–Value Store)  |
| 3.2-wide-column.cql      | Cassandra + CQL (mô hình Wide-Column Store) |

Mỗi mô hình demo cách triển khai access control từ User Level → Group → Department → Division → Organization.
### 🏗️ Cấu Trúc Phân Cấp Từng Mô Hình
Key-Value Model
```
key_value_db
     |
     ├── subjects
     │    ├── user:1 → {"username": "alice", "group_name": "dev", "department": "it"}
     │    ├── user:2 → {"username": "bob", "group_name": "dev", "department": "it"}
     │    ├── user:3 → {"username": "charlie", "group_name": "qa", "department": "it"}
     │
     ├── objects
     │    ├── file:1 → {"company": "ABC", "branch": "engineering", "file_name": "product_spec.pdf"}
     │    ├── file:2 → {"company": "ABC", "branch": "engineering", "file_name": "architecture.doc"}
     │
     └── access_policy
          ├── ap:1 → {"username": "alice", "company": "ABC", "branch": "engineering", "file_name": "product_spec.pdf", "allowed": true}
          ├── ap:2 → {"username": "alice", "company": "ABC", "branch": "engineering", "file_name": "architecture.doc", "allowed": true}
          └── ap:3 → {"username": "bob", "group_name": "dev", "department": "it", "company": "ABC", "branch": "engineering", "file_name": "product_spec.pdf", "allowed": true}

ACCESS PATTERNS:
USER LEVEL: alice → ABC/engineering → product_spec.pdf ✅ ALLOW
USER LEVEL: alice → ABC/engineering → architecture.doc ✅ ALLOW
GROUP LEVEL: bob (dev/it) → ABC/engineering → product_spec.pdf ✅ ALLOW
BRANCH LEVEL: ABC/engineering → 3 access permissions
```
Document Model (MongoDB)
```
document_db
     |
     ├── subjects
     │    ├── subject_alice
     │    │    ├── hierarchy: ABC_Corp → ABC_Inc → technology → engineering → headquarters → dev_team
     │    │    └── attributes: user_name: alice, role: developer
     │    │
     │    └── subject_eve
     │         ├── hierarchy: FinanceCorp → Finance_Inc → operations → finance → main_office → payroll_team
     │         └── attributes: user_name: eve, role: specialist
     │
     ├── objects
     │    ├── object_spec
     │    │    ├── hierarchy: ABC_Corp → ABC_Inc → technology → engineering → headquarters → product_x
     │    │    └── attributes: file_name: product_spec.pdf, classification: confidential
     │    │
     │    ├── object_financial
     │    │    ├── hierarchy: FinanceCorp → Finance_Inc → operations → finance → main_office → annual_reports
     │    │    └── attributes: file_name: financial_report.pdf, classification: secret
     │    │
     │    └── object_technical_guide
     │         ├── hierarchy: ABC_Corp → ABC_Inc → technology → engineering → headquarters → product_x
     │         └── attributes: file_name: technical_guide.pdf, classification: internal
     │
     └── policies
          ├── user_level
          │    ├── subject: alice (dev_team)
          │    ├── object: product_spec.pdf
          │    └── permission: read ✅ ALLOW
          │
          ├── group_level
          │    ├── subject: dev_team
          │    ├── object: engineering files
          │    └── permission: write ✅ ALLOW
          │
          ├── dept_level
          │    ├── subject: engineering department
          │    ├── object: engineering files
          │    └── permission: read ✅ ALLOW
          │
          ├── branch_level
          │    ├── subject: headquarters branch
          │    ├── object: headquarters files
          │    └── permission: read ✅ ALLOW
          │
          ├── division_level
          │    ├── subject: technology division
          │    ├── object: technology files
          │    └── permission: read ✅ ALLOW
          │
          └── cross_org_deny
               ├── subject: FinanceCorp
               ├── object: ABC_Corp
               └── permission: read ❌ DENY

ACCESS CHECKS:
alice → product_spec.pdf → user_level ✅ ALLOW
eve → ABC_Corp files → cross_org_deny ❌ DENY
dev_team → engineering files → group_level ✅ ALLOW
```
Wide-Column Model (Cassandra)
```
wide_column_db
|
├── organization_subjects
│ ├── Row: (it, engineering)
│ └── Columns:
│ ├── group:dev → username:alice
│ └── clearance_level: 3
│
├── company_objects
│ ├── Row: (ABC, engineering)
│ └── Columns:
│ ├── branch:hq → file:product_spec.pdf
│ └── classification: 3
│
└── access_policy
├── Row: (user, ABCorg, alice)
└── Columns:
├── file: product_spec.pdf
├── allowed: true
├── subject_attrs: {clearance: 3}
└── object_attrs: {classification: 3}

ABAC CHECK:
alice[3] → product_spec.pdf[3] → 3 ≥ 3 ✅ ALLOW
alice[3] → architecture.doc[5] → 3 ≥ 5 ❌ DENY
```

Graph Model (Neo4j)
```
(Tech Organization)
                            │
              ┌─────────────┴─────────────┐
              │                           │
         (Tech Corp)                 (Acme Corp)
              │                           │
      ┌───────┴────────┐           ┌─────┴─────┐
      │                │           │           │
  (dev_group)   (admin_group)  (qa_group)     ...
      │                │           │
   (alice)          (bob)      (charlie)
      │
      └──[CAN_READ]──> (product_spec.pdf)
                              │
                              └──[MANAGED_BY]──> (IT_department)
                                                        │
                                                        └──[BELONGS_TO]──> (Tech Organization)
ACCESS PATHS:
USER LEVEL: alice → CAN_READ → product_spec.pdf ✅ DIRECT
GROUP LEVEL: dev_group → Tech Corp → IT_department → product_spec.pdf ✅ INHERITED
DEPARTMENT LEVEL: IT_department → product_spec.pdf + architecture.doc ✅ MANAGED
ORGANIZATION LEVEL: Tech Organization → ALL FILES ✅ HIERARCHICAL
```

### 🚀 Cài Đặt và Chạy
**Yêu Cầu Hệ Thống**
```
Python >= 3.8
Jupyter Notebook
```
Bước 1: Clone Repository
```
git clone https://github.com/ngyxntthaoo/Nhom2_RBAC.git
cd Nhom2_RBAC
```
Bước 2: Cài Đặt Dependencies
```
npm install
```
Cài đặt Python packages
```
pip install jupyter pymongo neo4j pandas tabulate
```
Bước 3: Chạy chương trình
| File                         | Lệnh chạy         |
| ---------------------------- | ------------------------------------------- |
| 3.2-document-model.ipynb | chạy trực tiếp trên file   |
| 3.2-graph-model.cypher   | ```npm run query:graph```     |
| 3.2-key-value.ipynb     | chạy trực tiếp trên file  |
| 3.2-wide-column.cql      | ```npm run query:wide-column``` |

| File | Mô tả | Cách sử dụng |
|------|-------|-------------|
| **requirements.txt** | Danh sách thư viện Python cần thiết | `pip install -r requirements.txt` |
| **docker-compose.yml** | Cấu hình databases: PostgreSQL, MongoDB, Neo4j, Cassandra | `docker-compose up -d` |
| **phanta-docker-compose.yml** | MongoDB Replica Set với Phantom Reads demo | `docker-compose -f docker-compose.yml -f phanta-docker-compose.yml up -d` |
| **restart_with_slave_delay.sh** | Script khởi động lại replica set với độ trễ | `./restart_with_slave_delay.sh` |
| **apply_delay.sh** | Áp dụng độ trễ mạng 15s cho MongoDB secondary | `./apply_delay.sh` |
| **AccessControl_demo.ipynb** | Demo RBAC/ABAC: PostgreSQL vs MongoDB | Chạy tuần tự các cell |
| **NoSQL_Security_Overview.ipynb** | Demo bảo mật: mã hóa, NoSQL injection | Chạy sau khi khởi động MongoDB |
| **AI_Access_Control_Generator.ipynb** | Generator câu lệnh phân quyền bằng Gemini AI | Cần .env với GEMINI_API_KEY |
| **rep_lag_demo.ipynb** | Demo replication lag và phantom reads | Chạy sau khi áp dụng delay |




