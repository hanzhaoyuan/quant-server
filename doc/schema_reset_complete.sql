-- ============================================================
-- 量化平台数据库 - 完整重置脚本 (PostgreSQL)
-- 警告：此脚本会删除所有现有表和数据！
-- 执行前请确保已备份重要数据
-- ============================================================

SET search_path TO public;

-- ============================================================
-- 第一步：删除所有旧表（按依赖关系顺序）
-- ============================================================

-- 删除依赖表
DROP TABLE IF EXISTS t_user_permission CASCADE;
DROP TABLE IF EXISTS t_publish CASCADE;
DROP TABLE IF EXISTS t_backtest_task CASCADE;
DROP TABLE IF EXISTS t_code_file CASCADE;

-- 删除新的三表（如果存在）
DROP TABLE IF EXISTS t_indicator CASCADE;
DROP TABLE IF EXISTS t_strategy CASCADE;
DROP TABLE IF EXISTS t_library CASCADE;

-- 删除权限相关表
DROP TABLE IF EXISTS t_permission CASCADE;

-- 删除用户表（最后删除，因为其他表依赖它）
DROP TABLE IF EXISTS t_user CASCADE;

-- 删除触发器函数（如果存在）
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- ============================================================
-- 第二步：创建触发器函数（用于自动更新updated_at）
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 第三步：创建用户表
-- ============================================================

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
CREATE UNIQUE INDEX idx_user_username_unique ON t_user(username) WHERE deleted = 0;
CREATE UNIQUE INDEX idx_user_email_unique ON t_user(email) WHERE deleted = 0 AND email IS NOT NULL;
CREATE INDEX idx_user_deleted ON t_user(deleted);

-- 添加注释
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

-- 创建触发器
CREATE TRIGGER update_t_user_updated_at BEFORE UPDATE ON t_user
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- 第四步：创建指标表
-- ============================================================

CREATE TABLE t_indicator (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
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
CREATE INDEX idx_indicator_user_id ON t_indicator(user_id);
CREATE INDEX idx_indicator_is_public ON t_indicator(is_public);
CREATE INDEX idx_indicator_deleted ON t_indicator(deleted);
CREATE INDEX idx_indicator_name ON t_indicator(name);

-- 添加注释
COMMENT ON TABLE t_indicator IS '指标表';
COMMENT ON COLUMN t_indicator.id IS '主键ID';
COMMENT ON COLUMN t_indicator.name IS '指标文件名 (含扩展名)';
COMMENT ON COLUMN t_indicator.content IS '指标代码内容';
COMMENT ON COLUMN t_indicator.description IS '描述信息';
COMMENT ON COLUMN t_indicator.author IS '作者';
COMMENT ON COLUMN t_indicator.version IS '版本号';
COMMENT ON COLUMN t_indicator.user_id IS '创建者ID';
COMMENT ON COLUMN t_indicator.is_public IS '是否公开: 0-私有, 1-公开';
COMMENT ON COLUMN t_indicator.created_at IS '创建时间';
COMMENT ON COLUMN t_indicator.updated_at IS '更新时间';
COMMENT ON COLUMN t_indicator.deleted IS '逻辑删除: 0-正常, 1-已删除';

-- 创建触发器
CREATE TRIGGER update_t_indicator_updated_at BEFORE UPDATE ON t_indicator
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- 第五步：创建策略表
-- ============================================================

CREATE TABLE t_strategy (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
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
CREATE INDEX idx_strategy_user_id ON t_strategy(user_id);
CREATE INDEX idx_strategy_is_public ON t_strategy(is_public);
CREATE INDEX idx_strategy_deleted ON t_strategy(deleted);
CREATE INDEX idx_strategy_name ON t_strategy(name);

-- 添加注释
COMMENT ON TABLE t_strategy IS '策略表';
COMMENT ON COLUMN t_strategy.id IS '主键ID';
COMMENT ON COLUMN t_strategy.name IS '策略文件名 (含扩展名)';
COMMENT ON COLUMN t_strategy.content IS '策略代码内容';
COMMENT ON COLUMN t_strategy.description IS '描述信息';
COMMENT ON COLUMN t_strategy.author IS '作者';
COMMENT ON COLUMN t_strategy.version IS '版本号';
COMMENT ON COLUMN t_strategy.user_id IS '创建者ID';
COMMENT ON COLUMN t_strategy.is_public IS '是否公开: 0-私有, 1-公开';
COMMENT ON COLUMN t_strategy.created_at IS '创建时间';
COMMENT ON COLUMN t_strategy.updated_at IS '更新时间';
COMMENT ON COLUMN t_strategy.deleted IS '逻辑删除: 0-正常, 1-已删除';

-- 创建触发器
CREATE TRIGGER update_t_strategy_updated_at BEFORE UPDATE ON t_strategy
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- 第六步：创建库表
-- ============================================================

CREATE TABLE t_library (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
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
CREATE INDEX idx_library_user_id ON t_library(user_id);
CREATE INDEX idx_library_is_public ON t_library(is_public);
CREATE INDEX idx_library_deleted ON t_library(deleted);
CREATE INDEX idx_library_name ON t_library(name);

-- 添加注释
COMMENT ON TABLE t_library IS '库表';
COMMENT ON COLUMN t_library.id IS '主键ID';
COMMENT ON COLUMN t_library.name IS '库文件名 (含扩展名)';
COMMENT ON COLUMN t_library.content IS '库代码内容';
COMMENT ON COLUMN t_library.description IS '描述信息';
COMMENT ON COLUMN t_library.author IS '作者';
COMMENT ON COLUMN t_library.version IS '版本号';
COMMENT ON COLUMN t_library.user_id IS '创建者ID';
COMMENT ON COLUMN t_library.is_public IS '是否公开: 0-私有, 1-公开';
COMMENT ON COLUMN t_library.created_at IS '创建时间';
COMMENT ON COLUMN t_library.updated_at IS '更新时间';
COMMENT ON COLUMN t_library.deleted IS '逻辑删除: 0-正常, 1-已删除';

-- 创建触发器
CREATE TRIGGER update_t_library_updated_at BEFORE UPDATE ON t_library
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- 第七步：创建回测任务表
-- ============================================================

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
    FOREIGN KEY (strategy_id) REFERENCES t_strategy(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE
);

-- 创建索引
CREATE UNIQUE INDEX idx_backtest_task_task_id_unique ON t_backtest_task(task_id) WHERE deleted = 0;
CREATE INDEX idx_backtest_task_strategy_id ON t_backtest_task(strategy_id);
CREATE INDEX idx_backtest_task_user_id ON t_backtest_task(user_id);
CREATE INDEX idx_backtest_task_status ON t_backtest_task(status);
CREATE INDEX idx_backtest_task_deleted ON t_backtest_task(deleted);

-- 添加注释
COMMENT ON TABLE t_backtest_task IS '回测任务表';
COMMENT ON COLUMN t_backtest_task.id IS '主键ID';
COMMENT ON COLUMN t_backtest_task.task_id IS '任务ID (由 Agent 生成)';
COMMENT ON COLUMN t_backtest_task.strategy_id IS '策略ID (关联 t_strategy)';
COMMENT ON COLUMN t_backtest_task.user_id IS '用户ID';
COMMENT ON COLUMN t_backtest_task.task_type IS '任务类型: backtest, optimize, live_trade';
COMMENT ON COLUMN t_backtest_task.params IS '任务参数 (JSON 格式)';
COMMENT ON COLUMN t_backtest_task.status IS '状态: PENDING, RUNNING, SUCCESS, FAILED';
COMMENT ON COLUMN t_backtest_task.result IS '回测结果 (JSON 格式)';
COMMENT ON COLUMN t_backtest_task.error_message IS '错误信息';
COMMENT ON COLUMN t_backtest_task.created_at IS '创建时间';
COMMENT ON COLUMN t_backtest_task.updated_at IS '更新时间';
COMMENT ON COLUMN t_backtest_task.deleted IS '逻辑删除: 0-正常, 1-已删除';

-- 创建触发器
CREATE TRIGGER update_t_backtest_task_updated_at BEFORE UPDATE ON t_backtest_task
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- 第八步：创建发布表
-- ============================================================

CREATE TABLE t_publish (
    id BIGSERIAL PRIMARY KEY,
    code_file_id BIGINT NOT NULL,
    code_file_type VARCHAR(20) NOT NULL,
    version VARCHAR(50) NOT NULL,
    user_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    review_message TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted SMALLINT NOT NULL DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_publish_code_file_id ON t_publish(code_file_id);
CREATE INDEX idx_publish_code_file_type ON t_publish(code_file_type);
CREATE INDEX idx_publish_user_id ON t_publish(user_id);
CREATE INDEX idx_publish_status ON t_publish(status);
CREATE INDEX idx_publish_deleted ON t_publish(deleted);

-- 添加注释
COMMENT ON TABLE t_publish IS '发布表';
COMMENT ON COLUMN t_publish.id IS '主键ID';
COMMENT ON COLUMN t_publish.code_file_id IS '代码文件ID';
COMMENT ON COLUMN t_publish.code_file_type IS '代码文件类型: indicator, strategy, library';
COMMENT ON COLUMN t_publish.version IS '发布版本';
COMMENT ON COLUMN t_publish.user_id IS '发布者ID';
COMMENT ON COLUMN t_publish.status IS '状态: PENDING, PUBLISHED, REJECTED';
COMMENT ON COLUMN t_publish.review_message IS '审核信息';
COMMENT ON COLUMN t_publish.created_at IS '创建时间';
COMMENT ON COLUMN t_publish.updated_at IS '更新时间';
COMMENT ON COLUMN t_publish.deleted IS '逻辑删除: 0-正常, 1-已删除';

-- 创建触发器
CREATE TRIGGER update_t_publish_updated_at BEFORE UPDATE ON t_publish
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- 第九步：创建权限表
-- ============================================================

CREATE TABLE t_permission (
    id BIGSERIAL PRIMARY KEY,
    permission_name VARCHAR(100) NOT NULL,
    permission_code VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted SMALLINT NOT NULL DEFAULT 0
);

-- 创建索引
CREATE UNIQUE INDEX idx_permission_name_unique ON t_permission(permission_name) WHERE deleted = 0;
CREATE UNIQUE INDEX idx_permission_code_unique ON t_permission(permission_code) WHERE deleted = 0;
CREATE INDEX idx_permission_deleted ON t_permission(deleted);

-- 添加注释
COMMENT ON TABLE t_permission IS '权限表';
COMMENT ON COLUMN t_permission.id IS '主键ID';
COMMENT ON COLUMN t_permission.permission_name IS '权限名称';
COMMENT ON COLUMN t_permission.permission_code IS '权限编码';
COMMENT ON COLUMN t_permission.description IS '权限描述';
COMMENT ON COLUMN t_permission.created_at IS '创建时间';
COMMENT ON COLUMN t_permission.updated_at IS '更新时间';
COMMENT ON COLUMN t_permission.deleted IS '逻辑删除: 0-正常, 1-已删除';

-- 创建触发器
CREATE TRIGGER update_t_permission_updated_at BEFORE UPDATE ON t_permission
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- 第十步：创建用户权限关联表
-- ============================================================

CREATE TABLE t_user_permission (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES t_user(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES t_permission(id) ON DELETE CASCADE,
    UNIQUE (user_id, permission_id)
);

-- 创建索引
CREATE INDEX idx_user_permission_user_id ON t_user_permission(user_id);
CREATE INDEX idx_user_permission_permission_id ON t_user_permission(permission_id);

-- 添加注释
COMMENT ON TABLE t_user_permission IS '用户权限关联表';
COMMENT ON COLUMN t_user_permission.id IS '主键ID';
COMMENT ON COLUMN t_user_permission.user_id IS '用户ID';
COMMENT ON COLUMN t_user_permission.permission_id IS '权限ID';
COMMENT ON COLUMN t_user_permission.created_at IS '创建时间';

-- ============================================================
-- 第十一步：初始化数据
-- ============================================================

-- 插入默认管理员用户 (用户名: admin, 密码: admin123)
INSERT INTO t_user (username, password, email, nickname, role, status)
VALUES ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'admin@quant.com', '管理员', 'ADMIN', 1);

-- 插入示例指标
INSERT INTO t_indicator (name, content, description, author, version, user_id, is_public) VALUES
('MATrader.py', '# MATrader.py - 移动平均线交易指标
def calculate_ma(symbol, timeframe, period, mode):
    """计算移动平均线"""
    # TODO: 实现移动平均线计算逻辑
    pass
', '移动平均线交易指标', '系统', '1.0.0', 1, 1),
('MACD.py', '# MACD Indicator
def calculate_macd(data, fast=12, slow=26, signal=9):
    """计算MACD指标"""
    # TODO: 实现MACD计算
    pass
', 'MACD指标', '系统', '1.0.0', 1, 1),
('RSI.py', '# RSI Indicator
def calculate_rsi(data, period=14):
    """计算RSI指标"""
    # TODO: 实现RSI计算
    pass
', 'RSI相对强弱指标', '系统', '1.0.0', 1, 1);

-- 插入示例策略
INSERT INTO t_strategy (name, content, description, author, version, user_id, is_public) VALUES
('MAPlus.py', '# MA Plus Strategy
class MAStrategy:
    def __init__(self):
        self.short_period = 5
        self.long_period = 20

    def on_bar(self, bar):
        """K线数据回调"""
        # TODO: 实现策略逻辑
        pass
', '移动平均线增强策略', '系统', '1.0.0', 1, 1),
('GridTrading.py', '# Grid Trading Strategy
class GridTradingStrategy:
    def __init__(self):
        self.grid_levels = []
        self.grid_size = 100

    def on_bar(self, bar):
        """K线数据回调"""
        # TODO: 实现网格交易逻辑
        pass
', '网格交易策略', '系统', '1.0.0', 1, 1),
('TrendFollowing.py', '# Trend Following Strategy
class TrendFollowingStrategy:
    def __init__(self):
        self.trend_period = 50

    def on_bar(self, bar):
        """K线数据回调"""
        # TODO: 实现趋势跟踪逻辑
        pass
', '趋势跟踪策略', '系统', '1.0.0', 1, 1);

-- 插入示例库
INSERT INTO t_library (name, content, description, author, version, user_id, is_public) VALUES
('TradeLib.py', '# Trade Library
def format_price(price, precision=2):
    """格式化价格"""
    return round(price, precision)

def calculate_profit(entry_price, exit_price, volume):
    """计算盈亏"""
    return (exit_price - entry_price) * volume

def calculate_position_size(account_balance, risk_percent, stop_loss_pips):
    """计算仓位大小"""
    risk_amount = account_balance * (risk_percent / 100)
    position_size = risk_amount / stop_loss_pips
    return position_size
', '交易工具库', '系统', '1.0.0', 1, 1),
('DataLib.py', '# Data Processing Library
import pandas as pd

def clean_data(data):
    """清洗数据"""
    # TODO: 实现数据清洗逻辑
    pass

def resample_data(data, timeframe):
    """重采样数据"""
    # TODO: 实现数据重采样逻辑
    pass
', '数据处理库', '系统', '1.0.0', 1, 1);

-- 插入默认权限
INSERT INTO t_permission (permission_name, permission_code, description) VALUES
('查看指标', 'indicator:view', '查看所有指标'),
('创建指标', 'indicator:create', '创建新指标'),
('编辑指标', 'indicator:edit', '编辑指标'),
('删除指标', 'indicator:delete', '删除指标'),
('查看策略', 'strategy:view', '查看所有策略'),
('创建策略', 'strategy:create', '创建新策略'),
('编辑策略', 'strategy:edit', '编辑策略'),
('删除策略', 'strategy:delete', '删除策略'),
('发布策略', 'strategy:publish', '发布策略'),
('查看库', 'library:view', '查看所有库'),
('创建库', 'library:create', '创建新库'),
('编辑库', 'library:edit', '编辑库'),
('删除库', 'library:delete', '删除库'),
('执行回测', 'backtest:execute', '执行回测任务'),
('查看回测结果', 'backtest:view', '查看回测结果');

-- ============================================================
-- 完成！
-- ============================================================

-- 显示创建结果统计
SELECT
  'Users' AS table_name,
  COUNT(*) AS record_count
FROM t_user WHERE deleted = 0
UNION ALL
SELECT 'Indicators', COUNT(*) FROM t_indicator WHERE deleted = 0
UNION ALL
SELECT 'Strategies', COUNT(*) FROM t_strategy WHERE deleted = 0
UNION ALL
SELECT 'Libraries', COUNT(*) FROM t_library WHERE deleted = 0
UNION ALL
SELECT 'Permissions', COUNT(*) FROM t_permission WHERE deleted = 0;

-- 显示成功消息
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE '数据库初始化完成！';
    RAISE NOTICE '========================================';
    RAISE NOTICE '默认管理员账号:';
    RAISE NOTICE '  用户名: admin';
    RAISE NOTICE '  密码: admin123';
    RAISE NOTICE '========================================';
    RAISE NOTICE '示例数据已创建:';
    RAISE NOTICE '  指标: 3个';
    RAISE NOTICE '  策略: 3个';
    RAISE NOTICE '  库: 2个';
    RAISE NOTICE '  权限: 15个';
    RAISE NOTICE '========================================';
END $$;
