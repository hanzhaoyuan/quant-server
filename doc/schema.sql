-- ============================================================
-- 量化平台数据库设计 (PostgreSQL)
-- ============================================================
SET search_path TO public;
-- 1. 用户表
CREATE TABLE t_user (
                        id BIGSERIAL PRIMARY KEY,
                        username VARCHAR(100) NOT NULL,
                        password VARCHAR(255) NOT NULL,
                        email VARCHAR(255),
                        nickname VARCHAR(100),
                        role VARCHAR(20) NOT NULL DEFAULT 'USER',
                        status SMALLINT NOT NULL DEFAULT 1,
                        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        deleted SMALLINT NOT NULL DEFAULT 0
);

-- 创建索引
-- 部分唯一索引：只对未删除的记录生效，允许删除后重建同名/同邮箱用户
CREATE UNIQUE INDEX idx_user_username_unique ON t_user(username) WHERE deleted = 0;
CREATE UNIQUE INDEX idx_user_email_unique ON t_user(email) WHERE deleted = 0 AND email IS NOT NULL;
CREATE INDEX idx_user_deleted ON t_user(deleted);

COMMENT ON TABLE t_user IS '用户表';
COMMENT ON COLUMN t_user.id IS '主键ID';
COMMENT ON COLUMN t_user.username IS '用户名';
COMMENT ON COLUMN t_user.password IS '密码(加密存储)';
COMMENT ON COLUMN t_user.email IS '邮箱';
COMMENT ON COLUMN t_user.nickname IS '昵称';
COMMENT ON COLUMN t_user.role IS '角色: ADMIN, USER';
COMMENT ON COLUMN t_user.status IS '状态: 0-禁用, 1-启用';
COMMENT ON COLUMN t_user.created_at IS '创建时间';
COMMENT ON COLUMN t_user.updated_at IS '更新时间';
COMMENT ON COLUMN t_user.deleted IS '逻辑删除: 0-正常, 1-已删除';


-- 2. 代码文件表 (统一存储 indicator/strategy/library)
CREATE TABLE t_code_file (
                             id BIGSERIAL PRIMARY KEY,
                             name VARCHAR(200) NOT NULL,
                             type VARCHAR(20) NOT NULL,
                             content TEXT NOT NULL,
                             description TEXT,
                             author VARCHAR(100),
                             version VARCHAR(50) NOT NULL DEFAULT '1.0.0',
                             user_id BIGINT NOT NULL,
                             is_public SMALLINT NOT NULL DEFAULT 0,
                             created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                             updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                             deleted SMALLINT NOT NULL DEFAULT 0,
                             FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_code_file_type ON t_code_file(type);
CREATE INDEX idx_code_file_user_id ON t_code_file(user_id);
CREATE INDEX idx_code_file_is_public ON t_code_file(is_public);
CREATE INDEX idx_code_file_deleted ON t_code_file(deleted);
CREATE INDEX idx_code_file_name ON t_code_file(name);

COMMENT ON TABLE t_code_file IS '代码文件表';
COMMENT ON COLUMN t_code_file.id IS '主键ID';
COMMENT ON COLUMN t_code_file.name IS '文件名 (含扩展名)';
COMMENT ON COLUMN t_code_file.type IS '类型: indicator, strategy, library';
COMMENT ON COLUMN t_code_file.content IS '代码内容';
COMMENT ON COLUMN t_code_file.description IS '描述信息';
COMMENT ON COLUMN t_code_file.author IS '作者';
COMMENT ON COLUMN t_code_file.version IS '版本号';
COMMENT ON COLUMN t_code_file.user_id IS '创建者ID';
COMMENT ON COLUMN t_code_file.is_public IS '是否公开: 0-私有, 1-公开';
COMMENT ON COLUMN t_code_file.created_at IS '创建时间';
COMMENT ON COLUMN t_code_file.updated_at IS '更新时间';
COMMENT ON COLUMN t_code_file.deleted IS '逻辑删除: 0-正常, 1-已删除';


-- 3. 回测任务表
CREATE TABLE t_backtest_task (
                                 id BIGSERIAL PRIMARY KEY,
                                 task_id VARCHAR(100) NOT NULL,
                                 strategy_id BIGINT NOT NULL,
                                 user_id BIGINT NOT NULL,
                                 task_type VARCHAR(50) NOT NULL,
                                 params JSONB,
                                 status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
                                 result JSONB,
                                 error_message TEXT,
                                 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                 deleted SMALLINT NOT NULL DEFAULT 0,
                                 FOREIGN KEY (strategy_id) REFERENCES t_code_file(id) ON DELETE CASCADE,
                                 FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE
);

-- 创建索引
-- 部分唯一索引：只对未删除的记录生效
CREATE UNIQUE INDEX idx_backtest_task_task_id_unique ON t_backtest_task(task_id) WHERE deleted = 0;
CREATE INDEX idx_backtest_task_strategy_id ON t_backtest_task(strategy_id);
CREATE INDEX idx_backtest_task_user_id ON t_backtest_task(user_id);
CREATE INDEX idx_backtest_task_status ON t_backtest_task(status);
CREATE INDEX idx_backtest_task_deleted ON t_backtest_task(deleted);

COMMENT ON TABLE t_backtest_task IS '回测任务表';
COMMENT ON COLUMN t_backtest_task.id IS '主键ID';
COMMENT ON COLUMN t_backtest_task.task_id IS '任务ID (由 Agent 生成)';
COMMENT ON COLUMN t_backtest_task.strategy_id IS '策略ID';
COMMENT ON COLUMN t_backtest_task.user_id IS '用户ID';
COMMENT ON COLUMN t_backtest_task.task_type IS '任务类型: backtest, optimize, live_trade';
COMMENT ON COLUMN t_backtest_task.params IS '任务参数 (JSON 格式)';
COMMENT ON COLUMN t_backtest_task.status IS '状态: PENDING, RUNNING, SUCCESS, FAILED';
COMMENT ON COLUMN t_backtest_task.result IS '回测结果 (JSON 格式)';
COMMENT ON COLUMN t_backtest_task.error_message IS '错误信息';
COMMENT ON COLUMN t_backtest_task.created_at IS '创建时间';
COMMENT ON COLUMN t_backtest_task.updated_at IS '更新时间';
COMMENT ON COLUMN t_backtest_task.deleted IS '逻辑删除: 0-正常, 1-已删除';


-- 4. 发布表
CREATE TABLE t_publish (
                           id BIGSERIAL PRIMARY KEY,
                           code_file_id BIGINT NOT NULL,
                           version VARCHAR(50) NOT NULL,
                           user_id BIGINT NOT NULL,
                           status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
                           review_message TEXT,
                           created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           deleted SMALLINT NOT NULL DEFAULT 0,
                           FOREIGN KEY (code_file_id) REFERENCES t_code_file(id) ON DELETE CASCADE,
                           FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_publish_code_file_id ON t_publish(code_file_id);
CREATE INDEX idx_publish_user_id ON t_publish(user_id);
CREATE INDEX idx_publish_status ON t_publish(status);
CREATE INDEX idx_publish_deleted ON t_publish(deleted);

COMMENT ON TABLE t_publish IS '发布表';
COMMENT ON COLUMN t_publish.id IS '主键ID';
COMMENT ON COLUMN t_publish.code_file_id IS '代码文件ID (关联 t_code_file)';
COMMENT ON COLUMN t_publish.version IS '发布版本';
COMMENT ON COLUMN t_publish.user_id IS '发布者ID';
COMMENT ON COLUMN t_publish.status IS '状态: PENDING, PUBLISHED, REJECTED';
COMMENT ON COLUMN t_publish.review_message IS '审核信息';
COMMENT ON COLUMN t_publish.created_at IS '创建时间';
COMMENT ON COLUMN t_publish.updated_at IS '更新时间';
COMMENT ON COLUMN t_publish.deleted IS '逻辑删除: 0-正常, 1-已删除';


-- 5. 权限表
CREATE TABLE t_permission (
                              id BIGSERIAL PRIMARY KEY,
                              permission_name VARCHAR(100) NOT NULL,
                              permission_code VARCHAR(100) NOT NULL,
                              description TEXT,
                              created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                              updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                              deleted SMALLINT NOT NULL DEFAULT 0
);

-- 部分唯一索引：只对未删除的记录生效
CREATE UNIQUE INDEX idx_permission_name_unique ON t_permission(permission_name) WHERE deleted = 0;
CREATE UNIQUE INDEX idx_permission_code_unique ON t_permission(permission_code) WHERE deleted = 0;
CREATE INDEX idx_permission_deleted ON t_permission(deleted);

COMMENT ON TABLE t_permission IS '权限表';
COMMENT ON COLUMN t_permission.id IS '主键ID';
COMMENT ON COLUMN t_permission.permission_name IS '权限名称';
COMMENT ON COLUMN t_permission.permission_code IS '权限编码';
COMMENT ON COLUMN t_permission.description IS '权限描述';
COMMENT ON COLUMN t_permission.created_at IS '创建时间';
COMMENT ON COLUMN t_permission.updated_at IS '更新时间';
COMMENT ON COLUMN t_permission.deleted IS '逻辑删除: 0-正常, 1-已删除';


-- 6. 用户权限关联表
CREATE TABLE t_user_permission (
                                   id BIGSERIAL PRIMARY KEY,
                                   user_id BIGINT NOT NULL,
                                   permission_id BIGINT NOT NULL,
                                   created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                   FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE,
                                   FOREIGN KEY (permission_id) REFERENCES t_permission(id) ON DELETE CASCADE,
                                   UNIQUE (user_id, permission_id)
);

CREATE INDEX idx_user_permission_user_id ON t_user_permission(user_id);
CREATE INDEX idx_user_permission_permission_id ON t_user_permission(permission_id);

COMMENT ON TABLE t_user_permission IS '用户权限关联表';
COMMENT ON COLUMN t_user_permission.id IS '主键ID';
COMMENT ON COLUMN t_user_permission.user_id IS '用户ID';
COMMENT ON COLUMN t_user_permission.permission_id IS '权限ID';
COMMENT ON COLUMN t_user_permission.created_at IS '创建时间';


-- ============================================================
-- 自动更新 updated_at 的触发器
-- ============================================================

-- 创建触发器函数：自动更新 updated_at 字段
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为所有需要自动更新 updated_at 的表创建触发器
CREATE TRIGGER update_t_user_updated_at BEFORE UPDATE ON t_user
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_t_code_file_updated_at BEFORE UPDATE ON t_code_file
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_t_backtest_task_updated_at BEFORE UPDATE ON t_backtest_task
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_t_publish_updated_at BEFORE UPDATE ON t_publish
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_t_permission_updated_at BEFORE UPDATE ON t_permission
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ============================================================
-- 初始化数据
-- ============================================================

-- 插入默认管理员用户 (密码: admin123, 需要前端加密后再存储)
INSERT INTO t_user (username, password, email, nickname, role, status)
VALUES ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'admin@quant.com', '管理员', 'ADMIN', 1);

-- 插入默认权限
INSERT INTO t_permission (permission_name, permission_code, description) VALUES
                                                                             ('查看策略', 'strategy:view', '查看所有策略'),
                                                                             ('创建策略', 'strategy:create', '创建新策略'),
                                                                             ('编辑策略', 'strategy:edit', '编辑策略'),
                                                                             ('删除策略', 'strategy:delete', '删除策略'),
                                                                             ('发布策略', 'strategy:publish', '发布策略'),
                                                                             ('查看指标', 'indicator:view', '查看所有指标'),
                                                                             ('创建指标', 'indicator:create', '创建新指标'),
                                                                             ('编辑指标', 'indicator:edit', '编辑指标'),
                                                                             ('删除指标', 'indicator:delete', '删除指标'),
                                                                             ('查看库', 'library:view', '查看所有库'),
                                                                             ('创建库', 'library:create', '创建新库'),
                                                                             ('编辑库', 'library:edit', '编辑库'),
                                                                             ('删除库', 'library:delete', '删除库'),
                                                                             ('执行回测', 'backtest:execute', '执行回测任务'),
                                                                             ('查看回测结果', 'backtest:view', '查看回测结果');
