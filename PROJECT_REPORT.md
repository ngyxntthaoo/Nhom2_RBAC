
## 1. Tóm tắt chung
Một tập hợp các bài demo và công cụ thực hành về **Các chủ đề về bảo mật cơ sở dữ liệu**  tập trung chính vào **MongoDB**. Các nội dung chính bao gồm:

*   **Kiểm soát truy cập:** So sánh RBAC (Role-Based) và ABAC (Attribute-Based/Row-Level Security). có so sánh với cơ sỡ postgres
*   **Bảo mật dữ liệu:** Demo mã hóa dữ liệu nhạy cảm và phòng chống NoSQL Injection.
*   **Replication:** Mô phỏng và kiểm tra độ trễ sao chép (Replication Lag) trong MongoDB Replica Set.
*   **AI Automation:** Sử dụng Gemini LLM để tự động hóa việc tạo các câu lệnh phân quyền phức tạp.

## 2. Ý chính từng file

### Notebooks Demo & Thực hành
*   **`AccessControl_demo.ipynb`**: So sánh mô hình bảo mật PostgreSQL vs MongoDB:
    *   **RBAC:** Tạo user chỉ đọc.
    *   **View:** Ẩn cột dữ liệu nhạy cảm.
    *   **ABAC/RLS:** Demo Row-Level Security (Postgres) và giả lập bằng View (Mongo).
*   **`NoSQL_Security_Overview.ipynb`**: Demo các khía cạnh bảo mật NoSQL:
    *   **Mã hóa:** Lưu trữ SSN thô vs mã hóa.
    *   **NoSQL Injection:** Demo lỗ hổng `$where` và cách phòng chống.
*   **`AI_Access_Control_Generator.ipynb`**: Demo tích hợp AI (Google Gemini). Chuyển đổi yêu cầu ngôn ngữ tự nhiên thành câu lệnh phân quyền `db.createRole` của MongoDB.
*   **`rep_lag_demo.ipynb`**: Thực hành kiểm tra Replication Lag. Ghi dữ liệu vào Primary và quan sát độ trễ (20s) khi dữ liệu xuất hiện bên Secondary.

### Cấu hình & Môi trường
*   **`requirements.txt`**: Danh sách các thư viện Python cần cài đặt để chạy các notebook, bao gồm: `pymongo`, `sqlalchemy`, `pandas`, `google-generativeai` (cho AI demo), `cryptography` (cho demo mã hóa), và các thư viện hỗ trợ Jupyter.
*   **`docker-compose.yml`**: File cấu hình Docker Compose cho môi trường chung của các bài demo bảo mật. Dựng lên:
    *   `redis-server`: Redis (port 6379).
    *   `csdltt_mongodb`: MongoDB Standalone (port 27018).
    *   `postgresql`: PostgreSQL (port 5433).
*   **`phanta-docker-compose.yml`**: File cấu hình Docker Compose riêng cho bài demo Replication Lag. Dựng lên 2 node MongoDB (`mongo-primary`, `mongo-secondary`) và container `mongo-setup` để khởi tạo Replica Set với cấu hình delay.

### Scripts Tự động hóa
*   **`restart_with_slave_delay.sh`**: Script Bash tự động hóa việc khởi động lại MongoDB Replica Set.
    *   Dừng container cũ.
    *   Xóa volume (reset dữ liệu).
    *   Khởi động lại với cấu hình `slaveDelay: 20s` cho node Secondary.
*   **`apply_delay.sh`**: Script phụ sử dụng `tc` (traffic control) để tạo độ trễ mạng giả lập. *(Lưu ý: Hiện tại dự án ưu tiên dùng tính năng `slaveDelay` native của Mongo trong script restart hơn là script này)*.

## 3. Hướng dẫn cài đặt và chạy

### Bước 1: Cài đặt môi trường
1.  Đảm bảo đã cài đặt **Docker** và **Docker Compose**.
2.  Cài đặt thư viện Python:
    ```bash
    pip install -r requirements.txt
    ```
3.  (Tùy chọn) Tạo file `.env` chứa API Key Gemini nếu chạy demo AI:
    ```
    GEMINI_API_KEY=your_api_key_here
    ```

### Bước 2: Chạy Demo Bảo mật (Access Control, Security, AI)
Sử dụng môi trường chung:
1.  Khởi động container:
    ```bash
    docker-compose up -d
    ```
2.  Chạy các notebook: `AccessControl_demo.ipynb`, `NoSQL_Security_Overview.ipynb`, `AI_Access_Control_Generator.ipynb`.

### Bước 3: Chạy Demo Replication Lag
Sử dụng môi trường riêng biệt:
1.  Chạy script khởi tạo (tự động reset và bật môi trường replica set):
    ```bash
    ./restart_with_slave_delay.sh
    ```
2.  Đợi khoảng 30 giây để Replica Set ổn định.
3.  Chạy notebook `rep_lag_demo.ipynb`.
