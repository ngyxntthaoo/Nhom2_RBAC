// ============================================================================
// FILE: query_method_access_control.js
// Sửa Đổi Phương Thức Truy Vấn - Query Method Access Control
// ============================================================================

const db = connect("mongodb://127.0.0.1:27017/company_db");

// Cleanup
db.employees.drop();

print("=== QUERY METHOD ACCESS CONTROL DEMO ===");

// 1. Tạo dữ liệu mẫu
db.employees.insertMany([
  {_id: 1, name: "Alice", salary: 50000, department: "HR", role: "employee"},
  {_id: 2, name: "Bob", salary: 80000, department: "Finance", role: "manager"},
  {_id: 3, name: "Charlie", salary: 45000, department: "IT", role: "employee"}
]);

// 2. Hàm truy vấn với kiểm soát truy cập
function secureFindEmployees(userRole, userDepartment) {
    let query = {};
    
    // THÊM ĐIỀU KIỆN TRUY CẬP DỰA TRÊN ROLE
    if (userRole === "employee") {
        query = { 
            department: userDepartment,
            salary: { $lte: 60000 } // Nhân viên chỉ xem lương <= 60k
        };
    } else if (userRole === "manager") {
        query = { 
            department: userDepartment 
            // Manager xem tất cả trong department
        };
    } else if (userRole === "admin") {
        query = {}; // Admin xem tất cả
    }
    
    return db.employees.find(query).toArray();
}

// 3. Test các role khác nhau
print("1. Employee (HR) chỉ thấy lương <= 60k:");
printjson(secureFindEmployees("employee", "HR"));

print("\n2. Manager (Finance) thấy tất cả trong department:");
printjson(secureFindEmployees("manager", "Finance"));

print("\n3. Admin thấy tất cả:");
printjson(secureFindEmployees("admin", ""));