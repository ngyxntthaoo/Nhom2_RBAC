```bash
docker-compose -f docker-compose.yml -f phanta-docker-compose.yml up -d

docker-compose -f docker-compose.yml -f phanta-docker-compose.yml down -v
```
# Khởi tạo replica set với 1 node primary
docker exec -it mongo-primary mongo --eval "rs.initiate({_id: 'rs0', members: [{_id: 0, host: 'mongo-primary:27017'}]})"

# Thêm node secondary
docker exec -it mongo-primary mongo --eval "rs.add({host: 'mongo-secondary:27017', priority: 1})"


# Kiểm tra trạng thái replica set
docker exec -it mongo-primary mongo --eval "rs.status()"

# Xem cấu hình replica set hiện tại
docker exec -it mongo-primary mongo --eval "rs.conf()"

# Kiểm tra node hiện tại có phải primary không
docker exec -it mongo-primary mongo --eval "db.isMaster().ismaster"

# dùng Traffic Control (tc)  , nhằm mô phỏng độ trễ mạng 15 giây
docker exec mongo-secondary tc qdisc add dev eth0 root netem delay 15000ms
docker exec mongo-secondary tc qdisc dev eth0 root netem delay 15000ms
docker exec -it mongo-secondary tc qdisc replace dev eth0 root netem delay 15000ms

# truy cập nhánh chính và tạo user.
docker exec -it mongo-primary bash mongosh admin 
--quiet --eval 'db.createUser({user: "tagUser", pwd: "123", roles: [ { role: "readWrite", db: "admin" } ]})'

docker exec mongo-primary mongo admin -u tagUser -p 123 --authenticationDatabase admin --quiet --eval "db.runCommand({connectionStatus:1})"

# truy cập nhánh phụ để check
docker exec mongo-secondary mongo admin -u tagUser -p 123 --authenticationDatabase admin --quiet --eval "db.runCommand({connectionStatus:1})"

=> báo lỗi là đúng