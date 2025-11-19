// ============================================================================
// FILE: hierarchical_integration_simple.js
// Tích Hợp Ở Cấp Độ Phân Cấp - Phiên Bản Đơn Giản
// ============================================================================

const db = connect("mongodb://127.0.0.1:27017/company_db");

// Cleanup
db.departments.drop();

print("=== TÍCH HỢP ACCESS CONTROL TRONG CẤU TRÚC PHÂN CẤP ===");

// 1. Tạo cấu trúc PHÂN CẤP với access control TÍCH HỢP SẴN
db.departments.insertMany([
  {
    _id: "dept_hr",
    name: "HR Department",
    level: "department",
    // 🔐 ACCESS CONTROL ĐƯỢC TÍCH HỢP TRONG CẤU TRÚC
    access_rules: {
      "employee": { 
        query: { salary: { $lte: 60000 } },
        allowed_actions: ["read"]
      },
      "manager": { 
        query: {},
        allowed_actions: ["read", "write"] 
      }
    },
    // 👥 EMPLOYEES LÀ MỘT PHẦN CỦA DEPARTMENT
    employees: [
      {_id: 1, name: "Alice", salary: 50000, role: "employee"},
      {_id: 2, name: "Bob", salary: 80000, role: "manager"}
    ]
  },
  {
    _id: "dept_it", 
    name: "IT Department",
    level: "department",
    access_rules: {
      "employee": { 
        query: { salary: { $lte: 55000 } },
        allowed_actions: ["read"]
      },
      "manager": { 
        query: {},
        allowed_actions: ["read", "write", "delete"]
      }
    },
    employees: [
      {_id: 3, name: "Charlie", salary: 45000, role: "employee"},
      {_id: 4, name: "Diana", salary: 90000, role: "manager"}
    ]
  }
]);

// 2. Hàm truy vấn sử dụng ACCESS CONTROL TÍCH HỢP
function hierarchicalFindEmployees(userRole, userDepartment) {
    // LẤY ACCESS RULES TỪ CẤU TRÚC PHÂN CẤP
    let dept = db.departments.findOne({_id: userDepartment});
    
    if (!dept || !dept.access_rules[userRole]) {
        return [];
    }
    
    let accessRule = dept.access_rules[userRole];
    
    // TRUY VẤN TRỰC TIẾP TRONG CẤU TRÚC PHÂN CẤP
    return db.departments.aggregate([
        { $match: { _id: userDepartment } },
        { $unwind: "$employees" },
        { $match: accessRule.query }, // SỬ DỤNG QUERY TỪ ACCESS RULES
        { $project: { 
            "name": "$employees.name",
            "salary": "$employees.salary", 
            "role": "$employees.role",
            "allowed_actions": accessRule.allowed_actions
        }}
    ]).toArray();
}

// 3. Test
print("1. Employee trong HR department thấy:");
printjson(hierarchicalFindEmployees("employee", "dept_hr"));

print("\n2. Manager trong HR department thấy:");
printjson(hierarchicalFindEmployees("manager", "dept_hr"));

print("\n3. Employee trong IT department thấy:");
printjson(hierarchicalFindEmployees("employee", "dept_it"));