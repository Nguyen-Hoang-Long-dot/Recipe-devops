# 🍲 Bếp Việt – Website Chia sẻ Công thức Nấu ăn

**Đề tài 29 – Môn: Triển khai và Quản trị Hệ thống Phần mềm**
Sinh viên: `[Họ và tên]` – MSSV: `[Mã số sinh viên]` – Lớp: `[Lớp]`

Website chia sẻ công thức nấu ăn (món ăn, nguyên liệu, danh mục) viết bằng **Node.js/Express**, dữ liệu lưu trong **MySQL**, quản lý CSDL bằng **phpMyAdmin**, đặt sau **Nginx reverse proxy (HTTPS)**.
Hệ thống được giám sát bằng **Prometheus + Grafana**.
Log được thu thập tập trung bằng **Loki + Promtail** (truy vấn bằng LogQL).
Toàn bộ dịch vụ chạy bằng **Docker Compose**.

## 1. Kiến trúc

```
                          Internet / Trình duyệt
                                    │  80 → 443 (HTTPS tự ký)
                         ┌──────────▼──────────┐
   mạng frontend ───────►│   Nginx (reverse    │  security headers, rate limit
                         │   proxy, non-root)  │
                         └──────────┬──────────┘
   mạng backend (internal)          │ :3000
                         ┌──────────▼──────────┐      ┌──────────────────┐
                         │  App Node.js        │─────►│  MySQL 8         │◄──── phpMyAdmin
                         │  (non-root, RO fs)  │ 3306 │  (user quyền tối │      127.0.0.1:8081
                         └─────────────────────┘      │   thiểu)         │
                                                      └──────────────────┘
   mạng monitoring (internal)
     Prometheus ◄── cAdvisor · nginx-exporter · mysqld-exporter · app:/metrics
         ▲
     Grafana (127.0.0.1:3000) ──► dashboard Containers / Web / Database
     Promtail ──(đọc log qua Docker API)──► Loki ◄── Grafana (LogQL, dashboard Logs)
```

## 2. Yêu cầu

- Docker Engine 24+ và Docker Compose v2 (`docker compose version`)
- Cổng **80, 443** trống trên máy (Nginx)
- Linux / macOS / Windows (WSL2 hoặc Docker Desktop)

## 3. Chạy hệ thống

```bash
git clone https://github.com/Nguyen-Hoang-Long-dot/.git
cd <repo>

# Tạo file .env với mật khẩu mạnh ngẫu nhiên (hoặc: cp .env.example .env rồi tự sửa)
./scripts/gen-env.sh

docker compose up -d --build
docker compose ps          # tất cả service phải "healthy"/"running"
```

Lần chạy đầu MySQL cần ~30–60 giây để khởi tạo (schema + dữ liệu mẫu + user quyền tối thiểu).
Chứng chỉ HTTPS tự ký được service `cert-init` tạo tự động.

Xem mật khẩu quản trị vừa sinh: `grep -E 'ADMIN|ROOT' .env`

## 4. Địa chỉ truy cập

| Thành phần | URL | Tài khoản |
|---|---|---|
| Website (HTTPS) | https://localhost (trình duyệt cảnh báo cert tự ký → chọn *Tiếp tục*) | khách: không cần |
| Trang quản trị | https://localhost/admin/login | `ADMIN_USERNAME` / `ADMIN_PASSWORD` trong `.env` |
| phpMyAdmin | http://localhost:8081 | `root` / `MYSQL_ROOT_PASSWORD` (hoặc `recipe_app`) |
| Grafana | http://localhost:3000 | `GRAFANA_ADMIN_USER` / `GRAFANA_ADMIN_PASSWORD` |
| Prometheus | http://localhost:9090 | không |

> phpMyAdmin, Grafana, Prometheus chỉ mở trên `127.0.0.1` (không ra mạng ngoài).

## 5. Kiểm tra nhanh

```bash
curl -k -I https://localhost                 # xem security headers (HSTS, CSP, X-Frame-Options...)
curl -I http://localhost                     # 301 chuyển hướng sang HTTPS
curl -k https://localhost/healthz            # {"status":"ok"}
curl -k -o /dev/null -w "%{http_code}\n" https://localhost/metrics   # 404 (bị Nginx chặn từ ngoài)
```

## 6. Giám sát (Prometheus + Grafana)

- Prometheus: **Status → Targets** phải có các job `cadvisor`, `nginx`, `mysql`, `app` ở trạng thái **UP**.
- Grafana (đăng nhập → thư mục **Recipe Platform**):
  1. *Containers (cAdvisor)* – CPU/RAM/network từng container
  2. *Web server (Nginx) & Ứng dụng* – kết nối, request/s, độ trễ p50/p95/p99, số công thức
  3. *Database (MySQL)* – kết nối, truy vấn/s, lệnh SELECT/INSERT/UPDATE/DELETE, lưu lượng
- Luật cảnh báo mẫu: `monitoring/prometheus/alerts.yml` (xem tại Prometheus → Alerts).

## 7. Log tập trung (Loki + Promtail + LogQL)

Promtail đọc log mọi container của dự án (qua Docker API) và đẩy về Loki. Nginx và app ghi log **JSON** nên có thể dùng `| json`.
Trong Grafana → **Explore** → chọn datasource **Loki**, thử các truy vấn:

```logql
# 1. Toàn bộ log của Nginx
{service="nginx"}

# 2. Request lỗi (HTTP >= 400) – parse JSON rồi lọc theo field
{service="nginx"} | json | status >= 400

# 3. Số request theo mã trạng thái trong 5 phút gần nhất
sum by (status) (count_over_time({service="nginx"} | json [5m]))

# 4. Cảnh báo đăng nhập sai (dấu hiệu dò mật khẩu) – tốc độ mỗi phút
sum(rate({service="app"} |= "login_failed" [1m]))

# 5. Lỗi / cảnh báo của MySQL (không phân biệt hoa thường)
{service="db"} |~ "(?i)error|warning|denied"
```

Dashboard sẵn có: **4. Logs tập trung (Loki)**.
Tạo dữ liệu thử: đăng nhập sai vài lần ở `/admin/login`, truy cập URL không tồn tại (`/abc`) rồi xem lại các truy vấn trên.

## 8. Hardening đã áp dụng

| Biện pháp | Cách làm |
|---|---|
| Container **non-root** | App chạy `USER node`; Nginx dùng `nginx-unprivileged` (cổng 8080/8443); Grafana/Prometheus/Loki dùng user riêng của image |
| **Network isolation** | `backend` là mạng `internal` (app ↔ DB, không ra Internet); chỉ Nginx nằm ở mạng `frontend`; DB không publish cổng |
| **Mật khẩu mạnh** | `scripts/gen-env.sh` sinh mật khẩu ngẫu nhiên ≥ 20 ký tự; `.env` không đưa lên Git; compose bắt buộc phải có biến (`:?`) |
| **Quyền DB tối thiểu** | User `recipe_app` chỉ có SELECT/INSERT/UPDATE/DELETE trên 1 database; user `exporter` chỉ có PROCESS/REPLICATION CLIENT; `--local-infile=0` |
| **Security headers Nginx** | HSTS, CSP, X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy; ẩn version (`server_tokens off`) |
| **HTTPS** | TLS 1.2/1.3, chứng chỉ tự ký, HTTP tự chuyển sang HTTPS |
| **Chống brute-force / flood** | `limit_req` (đăng nhập 5 lần/phút/IP), `limit_conn`, giới hạn kích thước & timeout request |
| Giảm bề mặt tấn công container | `cap_drop: ALL`, `no-new-privileges`, `read_only` (app, Nginx), giới hạn RAM/PID, xoay vòng log |
| Ứng dụng | bcrypt (cost 12), CSRF token, session cookie `HttpOnly`/`SameSite`/`Secure`, truy vấn tham số hoá (chống SQL injection), escape HTML (chống XSS) |
| Cổng quản trị | phpMyAdmin, Grafana, Prometheus chỉ bind `127.0.0.1` |
| `/metrics` | Chỉ truy cập được trong mạng `monitoring`; Nginx trả 404 từ ngoài |

**Ngoại lệ có chủ đích** (ghi rõ trong báo cáo): phpMyAdmin (Apache) và MySQL cần khởi động bằng root rồi hạ quyền xuống user thường.
cAdvisor cần `privileged` để đọc cgroup của host.
Promtail chạy root để đọc `docker.sock` (mount chỉ đọc).

## 9. Cấu trúc thư mục

```
.
├── docker-compose.yml          # toàn bộ stack
├── .env.example                # mẫu biến môi trường (.env thật KHÔNG commit)
├── scripts/gen-env.sh          # sinh .env với mật khẩu mạnh
├── app/                        # ứng dụng Node.js (Dockerfile, src/, views/, public/)
├── db/init/                    # 01-schema.sql, 02-seed.sql, 03-users.sh (chạy lần đầu)
├── nginx/conf.d/default.conf   # reverse proxy + HTTPS + security headers
├── monitoring/
│   ├── prometheus/             # prometheus.yml, alerts.yml
│   └── grafana/                # provisioning + dashboards (JSON)
└── logging/
    ├── loki/loki-config.yml
    └── promtail/promtail-config.yml
```

## 10. Quy ước commit

| Commit | Nội dung |
|---|---|
| 1 | Ứng dụng + MySQL + phpMyAdmin + Nginx reverse proxy (HTTPS, security headers) + hardening cơ bản |
| 2 | Prometheus + Grafana (cAdvisor, nginx-exporter, mysqld-exporter, dashboard) |
| 3 | Loki + Promtail, truy vấn LogQL, dashboard log |

## 11. Dừng / xoá hệ thống

```bash
docker compose down            # dừng, giữ dữ liệu
docker compose down -v         # dừng và XOÁ toàn bộ dữ liệu (DB, Grafana, Loki, chứng chỉ)
```

## 12. Xử lý sự cố

- **`variable is not set`** → chưa có `.env` → chạy `./scripts/gen-env.sh`.
- **Cổng 80/443 bị chiếm** → tắt IIS/Apache/Nginx đang chạy trên máy hoặc đổi cổng trong mục `ports` của service `nginx`.
- **Sửa mật khẩu DB trong `.env` nhưng không có tác dụng** → user DB chỉ được tạo lần đầu; chạy `docker compose down -v` rồi `up` lại.
- **cAdvisor không lên trên Docker Desktop (Windows/macOS)** → kiểm tra mục *Resources/WSL integration*; các dashboard khác vẫn hoạt động.
- **Grafana không có log** → `docker compose logs promtail`; đảm bảo `/var/run/docker.sock` có thể mount được.
