# Quant Server - 量化平台后端服务

## 项目概述

量化平台后端服务,负责管理策略、指标、函数库,以及用户、权限、发布等功能,提供统一 API 给前端与本地 Agent 使用。

## 技术栈

- Java 8 (JDK 1.8)
- Spring Boot 2.7.18
- PostgreSQL
- MyBatis Plus
- Swagger (OpenAPI 3.0)
- Druid 连接池
- JWT (用于认证)
- Lombok

## 项目结构

```
quant-server/
├── doc/                          # 文档目录
│   └── schema.sql               # 数据库表结构 SQL
├── src/
│   ├── main/
│   │   ├── java/com/quant/server/
│   │   │   ├── common/          # 通用类 (Result, BusinessException, GlobalExceptionHandler)
│   │   │   ├── config/          # 配置类 (Swagger, Security, WebConfig, MyBatisPlus)
│   │   │   ├── controller/      # Controller 层 (RESTful API)
│   │   │   ├── dto/             # DTO (请求参数)
│   │   │   ├── entity/          # 实体类
│   │   │   ├── mapper/          # Mapper 接口
│   │   │   ├── service/         # Service 接口和实现
│   │   │   ├── vo/              # VO (响应结果)
│   │   │   └── QuantServerApplication.java  # 启动类
│   │   └── resources/
│   │       └── application.yml  # 配置文件
│   └── test/                    # 测试代码
└── pom.xml                      # Maven 配置
```

## 数据库设计

### 1. 用户表 (t_user)
存储用户信息,包括用户名、密码、角色等。

### 2. 代码文件表 (t_code_file)
统一存储指标 (indicator)、策略 (strategy)、库 (library)。

### 3. 回测任务表 (t_backtest_task)
记录回测任务的执行状态和结果。

### 4. 发布表 (t_publish)
管理策略、指标、库的发布审核流程。

### 5. 权限表 (t_permission) 和用户权限关联表 (t_user_permission)
权限管理系统。

详细表结构请查看 `doc/schema.sql`。

## 配置说明

### 数据库配置

在 `src/main/resources/application.yml` 中配置 PostgreSQL 连接信息:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/quant_db
    username: postgres
    password: your_password_here
```

### JWT 配置

```yaml
jwt:
  secret: quant-server-secret-key-2024-change-this-in-production
  expiration: 604800  # 7 天
```

**注意**: 生产环境请修改为复杂密钥!

## 运行步骤

### 1. 创建数据库

```sql
CREATE DATABASE quant_db;
```

### 2. 执行表结构 SQL

```bash
psql -U postgres -d quant_db -f doc/schema.sql
```

### 3. 修改数据库配置

编辑 `src/main/resources/application.yml`,填入数据库连接信息。

### 4. 编译运行

```bash
mvn clean install
mvn spring-boot:run
```

### 5. 访问接口文档

- Swagger 文档: http://localhost:8080/api/swagger-ui/
- Druid 监控: http://localhost:8080/api/druid/ (admin/admin)

## API 接口说明

### 用户管理

- `POST /api/user/register` - 用户注册
- `POST /api/user/login` - 用户登录
- `GET /api/user/info` - 获取用户信息

### 代码文件管理

- `GET /api/code-file/list` - 获取文件列表 (按类型和用户)
- `GET /api/code-file/public/list` - 获取公开文件列表
- `GET /api/code-file/{id}` - 获取文件详情
- `POST /api/code-file/create` - 创建文件
- `PUT /api/code-file/update` - 更新文件
- `DELETE /api/code-file/{id}` - 删除文件
- `POST /api/code-file/copy/{id}` - 复制文件

更多接口请访问 Swagger 文档。

## 默认账户

- 管理员账户: admin / admin123

## 开发说明

### 添加新的业务模块

1. 在 `entity` 包中创建实体类
2. 在 `mapper` 包中创建 Mapper 接口
3. 在 `service` 包中创建 Service 接口和实现类
4. 在 `controller` 包中创建 Controller
5. 根据需要创建 DTO 和 VO

### 统一响应格式

所有接口统一返回 `Result<T>` 对象:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {},
  "timestamp": 1234567890
}
```

### 异常处理

使用 `BusinessException` 抛出业务异常,会被 `GlobalExceptionHandler` 统一处理。

## 后续扩展

- [ ] 实现 JWT 认证拦截器
- [ ] 完善权限控制
- [ ] 添加回测任务管理接口
- [ ] 添加发布审核流程接口
- [ ] 集成本地 Agent 通信
- [ ] 添加单元测试
- [ ] 性能优化和缓存
- [ ] 日志审计

## License

MIT
