// ============================================================================
// GRAPH RBAC SETUP - Chuyển đổi từ Node.js script
// ============================================================================

// 1️⃣ Xoá tất cả dữ liệu cũ
MATCH (n) DETACH DELETE n;

// 2️⃣ Tạo Organization
CREATE (techOrg:Organization {name: "Tech Organization"});

// 3️⃣ Tạo Companies
CREATE 
  (techCorp:Company {name: "Tech Corp"}),
  (acmeCorp:Company {name: "Acme Corp"});

// 4️⃣ Companies -> Organization
MATCH (c:Company {name:"Tech Corp"}), (o:Organization {name:"Tech Organization"})
CREATE (c)-[:PART_OF]->(o);

MATCH (c:Company {name:"Acme Corp"}), (o:Organization {name:"Tech Organization"})
CREATE (c)-[:PART_OF]->(o);

// 5️⃣ Departments
CREATE 
  (itDept:Department {name:"IT_department"}),
  (secDept:Department {name:"Security_department"});

// 6️⃣ Departments -> Organization
MATCH (d:Department {name:"IT_department"}), (o:Organization {name:"Tech Organization"})
CREATE (d)-[:BELONGS_TO]->(o);

MATCH (d:Department {name:"Security_department"}), (o:Organization {name:"Tech Organization"})
CREATE (d)-[:BELONGS_TO]->(o);

// 7️⃣ Files
CREATE
  (f1:File {file_name: "product_spec.pdf"}),
  (f2:File {file_name: "architecture.doc"}),
  (f3:File {file_name: "research_paper.pdf"});

// 8️⃣ Files -> Departments
MATCH (f:File {file_name:"product_spec.pdf"}), (d:Department {name:"IT_department"})
CREATE (f)-[:MANAGED_BY]->(d);

MATCH (f:File {file_name:"architecture.doc"}), (d:Department {name:"IT_department"})
CREATE (f)-[:MANAGED_BY]->(d);

MATCH (f:File {file_name:"research_paper.pdf"}), (d:Department {name:"Security_department"})
CREATE (f)-[:MANAGED_BY]->(d);

// 9️⃣ Groups
CREATE 
  (devGroup:Group {name:"dev_group"}),
  (qaGroup:Group {name:"qa_group"}),
  (adminGroup:Group {name:"admin_group"});

// 10️⃣ Users -> Groups
CREATE
  (alice:User {name:"alice"}),
  (bob:User {name:"bob"}),
  (charlie:User {name:"charlie"});

MATCH (u:User {name:"alice"}), (g:Group {name:"dev_group"})
CREATE (u)-[:IN]->(g);

MATCH (u:User {name:"bob"}), (g:Group {name:"admin_group"})
CREATE (u)-[:IN]->(g);

MATCH (u:User {name:"charlie"}), (g:Group {name:"qa_group"})
CREATE (u)-[:IN]->(g);

// 11️⃣ Groups -> Companies
MATCH (g:Group {name:"dev_group"}), (c:Company {name:"Tech Corp"})
CREATE (g)-[:WORKS_FOR]->(c);

MATCH (g:Group {name:"admin_group"}), (c:Company {name:"Tech Corp"})
CREATE (g)-[:WORKS_FOR]->(c);

MATCH (g:Group {name:"qa_group"}), (c:Company {name:"Acme Corp"})
CREATE (g)-[:WORKS_FOR]->(c);

// Direct permission for Alice
MATCH (u:User {name: "alice"}), (f:File {file_name: "product_spec.pdf"})
CREATE (u)-[:CAN_READ]->(f);

// Hiển thị kết quả setup
RETURN "✅ Graph RBAC setup completed!" as status;



// ==============================================================================================

// ktra user level
// xem user nào thuộc group nào, làm việc cho company nào, và có quyền truy cập vào file nào thuộc organization
// --> Alice được kế thừa quyền đọc file thông qua: User -> Group -> Company -> Department -> File, ko cần tạp edge
// MATCH path = (u:User)-[:IN]->(g:Group)-[:WORKS_FOR]->(c:Company)-[:PART_OF]->(o:Organization),
//              (f:File)-[:MANAGED_BY]->(d:Department)-[:BELONGS_TO]->(o)
// RETURN 
//     u.name AS user,
//     g.name AS group,
//     c.name AS company,
//     f.file_name AS file,
//     d.name AS department,
//     o.name AS organization,
//     path;


//kiểm tra User trong một Group có quyền gì
// MATCH (g:Group {name: 'dev_group'})<-[:IN]-(u:User),
//       (g)-[:WORKS_FOR]->(c:Company)-[:PART_OF]->(o:Organization),
//       (f:File)-[:MANAGED_BY]->(d:Department)-[:BELONGS_TO]->(o)
// RETURN 
//     u.name AS user,
//     g.name AS group,
//     f.file_name AS file,
//     d.name AS managing_department,
//     c.name AS company,
//     o.name AS organization;


// Kiểm tra quyền quản lý của Department
// MATCH (d:Department {name: 'IT_department'})<-[:MANAGED_BY]-(f:File),
//       (d)-[:BELONGS_TO]->(o:Organization)
// RETURN 
//     d.name AS department,
//     f.file_name AS file,
//     o.name AS organization;


// Alice có quyền READ product_spec.pdf --> tạo relationship trực tiếp
// MATCH (u:User {name: "alice"})-[p:CAN_READ]->(f:File {file_name: "product_spec.pdf"})
// RETURN 
//     u.name AS user, 
//     p AS permission, 
//     f.file_name AS file;
