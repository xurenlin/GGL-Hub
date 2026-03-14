# GGL-Hub 数据库初始化脚本

本目录包含 GGL-Hub 项目所有数据库的初始化脚本。

## 文件说明

### 1. 数据库初始化脚本

| 文件 | 说明 | 数据库 |
|------|------|--------|
| `nacos-schema.sql` | Nacos 2.x 数据库表结构 | `nacos` |
| `ggl-order-schema.sql` | 订单服务数据库表结构 | `ggl_order` |
| `init-all.sh` | Linux/macOS 统一初始化脚本 | 所有数据库 |
| `init-all.bat` | Windows 统一初始化脚本 | 所有数据库 |

### 2. 验证脚本

| 文件 | 说明 |
|------|------|
| `../verify-nacos-persistence.sh` | Linux/macOS Nacos 持久化验证 |
| `../verify-nacos-persistence.bat` | Windows Nacos 持久化验证 |

## 使用方法

### 方法1：使用 Docker Compose 自动初始化（推荐）

当启动 MySQL 容器时，会自动执行 `init-all.sh` 脚本初始化所有数据库：

```bash
# 启动所有服务（包括数据库初始化）
docker-compose up -d mysql nacos

# 或者启动所有服务
docker-compose up -d
```

### 方法2：手动初始化数据库

#### Linux/macOS
```bash
# 进入 init-scripts 目录
cd init-scripts

# 运行初始化脚本
./init-all.sh

# 或者指定自定义配置
MYSQL_HOST=localhost MYSQL_PORT=3307 MYSQL_USER=root MYSQL_PASSWORD=123456 ./init-all.sh
```

#### Windows
```bash
# 进入 init-scripts 目录
cd init-scripts

# 运行初始化脚本
init-all.bat

# 或者设置环境变量后运行
set MYSQL_HOST=localhost
set MYSQL_PORT=3307
set MYSQL_USER=root
set MYSQL_PASSWORD=123456
init-all.bat
```

### 方法3：单独初始化特定数据库

#### 初始化 Nacos 数据库
```bash
mysql -hlocalhost -P3307 -uroot -p123456 < nacos-schema.sql
```

#### 初始化订单服务数据库
```bash
mysql -hlocalhost -P3307 -uroot -p123456 < ggl-order-schema.sql
```

## 数据库结构

### 1. Nacos 数据库 (`nacos`)

包含 Nacos 2.x 版本所需的所有表：
- `config_info` - 配置信息表
- `users` - 用户表（默认用户：nacos/nacos）
- `roles` - 角色表
- `permissions` - 权限表
- 以及其他相关表

### 2. 订单服务数据库 (`ggl_order`)

包含完整的订单管理系统表：
- `user` - 用户表
- `order` - 订单表
- `order_item` - 订单项表
- `payment_record` - 支付记录表
- `shipping_record` - 物流记录表
- `refund_record` - 退款记录表
- `coupon` - 优惠券表
- `product` - 商品表
- 以及其他相关表

## 验证持久化

### 验证 Nacos 持久化到 MySQL

#### Linux/macOS
```bash
# 运行验证脚本
./verify-nacos-persistence.sh

# 或者指定自定义配置
MYSQL_HOST=localhost MYSQL_PORT=3307 MYSQL_USER=root MYSQL_PASSWORD=123456 ./verify-nacos-persistence.sh
```

#### Windows
```bash
# 运行验证脚本
verify-nacos-persistence.bat

# 或者设置环境变量后运行
set MYSQL_HOST=localhost
set MYSQL_PORT=3307
set MYSQL_USER=root
set MYSQL_PASSWORD=123456
verify-nacos-persistence.bat
```

验证脚本会：
1. 检查 MySQL 和 Nacos 服务状态
2. 创建测试配置
3. 重启 Nacos 服务
4. 验证配置是否持久化

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `MYSQL_HOST` | `localhost` | MySQL 主机地址 |
| `MYSQL_PORT` | `3307` | MySQL 端口 |
| `MYSQL_USER` | `root` | MySQL 用户名 |
| `MYSQL_PASSWORD` | `123456` | MySQL 密码 |

## 故障排除

### 1. MySQL 连接失败
```bash
# 检查 MySQL 服务状态
docker-compose ps mysql

# 查看 MySQL 日志
docker-compose logs mysql

# 手动连接测试
mysql -hlocalhost -P3307 -uroot -p123456 -e "SELECT 1;"
```

### 2. Nacos 启动失败
```bash
# 检查 Nacos 服务状态
docker-compose ps nacos

# 查看 Nacos 日志
docker-compose logs nacos

# 检查数据库表是否存在
mysql -hlocalhost -P3307 -uroot -p123456 -e "USE nacos; SHOW TABLES;"
```

### 3. 初始化脚本执行失败
```bash
# 检查脚本权限
chmod +x init-scripts/*.sh

# 手动执行 SQL 文件
mysql -hlocalhost -P3307 -uroot -p123456 < init-scripts/nacos-schema.sql
```

## 重新初始化

如果需要重新初始化数据库：

```bash
# 停止服务
docker-compose down

# 删除数据卷（注意：这会删除所有数据！）
docker-compose down -v

# 重新启动服务
docker-compose up -d
```

## 注意事项

1. **首次启动需要时间**：MySQL 容器首次启动时会执行初始化脚本，可能需要几分钟时间
2. **数据持久化**：所有数据都保存在 Docker 数据卷中，重启容器不会丢失数据
3. **默认密码**：生产环境请修改默认密码（root/123456, nacos/nacos）
4. **备份数据**：定期备份重要数据

## 生产环境建议

1. **修改默认密码**：
   ```bash
   # 修改 MySQL root 密码
   docker-compose exec mysql mysql -uroot -p123456 -e "ALTER USER 'root'@'%' IDENTIFIED BY 'new-password';"
   
   # 修改 Nacos 用户密码
   # 访问 http://localhost:8848/nacos 修改 nacos 用户密码
   ```

2. **启用 SSL/TLS**：为 MySQL 和 Nacos 启用加密连接

3. **定期备份**：
   ```bash
   # 备份数据库
   mysqldump -hlocalhost -P3307 -uroot -p123456 --all-databases > backup-$(date +%Y%m%d).sql
   ```

4. **监控告警**：设置数据库监控和告警机制