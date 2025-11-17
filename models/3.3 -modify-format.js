// ============================================================================
// FILE: embedded_access_control.js
// Sửa Đổi Định Dạng Cấu Trúc NoSQL - Embedded Access Control
// ============================================================================

const db = connect("mongodb://127.0.0.1:27017/company_db");

// Cleanup
db.employees.drop();

print("=== EMBEDDED ACCESS CONTROL DEMO ===");

// 1. Thêm document với access control embedded
db.employees.insertOne({
  _id: 1,
  name: "Alice",
  salary: 50000,
  department: "HR",
  // Metadata kiểm soát truy cập
  access_control: {
    readable_by: ["HR_Managers", "Finance"],
    writable_by: ["HR_Managers"],
    conditions: {
      max_salary_visible: 60000,
      departments_visible: ["HR", "Finance"]
    }
  }
});

// 2. Truy vấn với điều kiện kiểm soát truy cập
let result = db.employees.find({
  $and: [
    { department: { $in: ["HR", "Finance"] } },
    { "access_control.readable_by": "HR_Managers" }
  ]
}).toArray();

print("Kết quả truy vấn:");
printjson(result);