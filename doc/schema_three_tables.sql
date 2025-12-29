-- ============================================================
-- 量化平台数据库设计 - 三表分离版本 (PostgreSQL)
-- 将原 t_code_file 拆分为 t_indicator, t_strategy, t_library
-- ============================================================
SET search_path TO public;

-- ============================================================
-- 1. 指标表
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

-- ============================================================
-- 2. 策略表
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

-- ============================================================
-- 3. 库表
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

-- ============================================================
-- 自动更新 updated_at 的触发器
-- ============================================================

-- 为三张表创建触发器
CREATE TRIGGER update_t_indicator_updated_at BEFORE UPDATE ON t_indicator
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_t_strategy_updated_at BEFORE UPDATE ON t_strategy
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_t_library_updated_at BEFORE UPDATE ON t_library
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- 初始化示例数据（可选）
-- ============================================================

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
', 'MACD指标', '系统', '1.0.0', 1, 1);

-- 插入示例策略
INSERT INTO t_strategy (name, content, description, author, version, user_id, is_public) VALUES
('MAPlus.py', '# MA Plus Strategy
class MAStrategy:
    def __init__(self):
        pass

    def on_bar(self, bar):
        # TODO: 实现策略逻辑
        pass
', '移动平均线增强策略', '系统', '1.0.0', 1, 1),
('GridTrading.py', '# Grid Trading Strategy
class GridTradingStrategy:
    def __init__(self):
        self.grid_levels = []

    def on_bar(self, bar):
        # TODO: 实现网格交易逻辑
        pass
', '网格交易策略', '系统', '1.0.0', 1, 1);

-- 插入示例库
INSERT INTO t_library (name, content, description, author, version, user_id, is_public) VALUES
('TradeLib.py', '# Trade Library
def format_price(price, precision=2):
    """格式化价格"""
    return round(price, precision)

def calculate_profit(entry_price, exit_price, volume):
    """计算盈亏"""
    return (exit_price - entry_price) * volume
', '交易工具库', '系统', '1.0.0', 1, 1);
