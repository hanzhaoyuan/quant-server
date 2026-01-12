-- ============================================================
-- 行情数据库设计 (近2年历史数据)
-- 支持品种: EURUSD, GBPUSD, XAUUSD, USDX
-- ============================================================
SET search_path TO public;

-- ============================================================
-- 1. 历史K线数据表
-- ============================================================
CREATE TABLE t_market_kline (
    id BIGSERIAL PRIMARY KEY,
    symbol VARCHAR(20) NOT NULL,              -- 交易品种: EURUSD, GBPUSD, XAUUSD, USDX
    timeframe VARCHAR(10) NOT NULL,           -- 时间周期: 1m, 5m, 15m, 1h, 4h, 1d
    open_time TIMESTAMP NOT NULL,             -- K线开始时间
    close_time TIMESTAMP NOT NULL,            -- K线结束时间
    open_price NUMERIC(18, 6) NOT NULL,       -- 开盘价
    high_price NUMERIC(18, 6) NOT NULL,       -- 最高价
    low_price NUMERIC(18, 6) NOT NULL,        -- 最低价
    close_price NUMERIC(18, 6) NOT NULL,      -- 收盘价
    volume NUMERIC(18, 2) DEFAULT 0,          -- 成交量 (外汇可能为0)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 复合唯一索引：防止重复数据
CREATE UNIQUE INDEX idx_kline_unique ON t_market_kline(symbol, timeframe, open_time);

-- 查询优化索引
CREATE INDEX idx_kline_symbol_timeframe ON t_market_kline(symbol, timeframe);
CREATE INDEX idx_kline_open_time ON t_market_kline(open_time DESC);
CREATE INDEX idx_kline_symbol_time_range ON t_market_kline(symbol, open_time DESC);

COMMENT ON TABLE t_market_kline IS '行情K线数据表 (近2年)';
COMMENT ON COLUMN t_market_kline.symbol IS '交易品种';
COMMENT ON COLUMN t_market_kline.timeframe IS '时间周期';
COMMENT ON COLUMN t_market_kline.open_time IS 'K线开始时间';
COMMENT ON COLUMN t_market_kline.close_time IS 'K线结束时间';
COMMENT ON COLUMN t_market_kline.open_price IS '开盘价';
COMMENT ON COLUMN t_market_kline.high_price IS '最高价';
COMMENT ON COLUMN t_market_kline.low_price IS '最低价';
COMMENT ON COLUMN t_market_kline.close_price IS '收盘价';
COMMENT ON COLUMN t_market_kline.volume IS '成交量';


-- ============================================================
-- 2. 实时行情Tick表 (用于快速查询最新价格)
-- ============================================================
CREATE TABLE t_market_tick (
    id BIGSERIAL PRIMARY KEY,
    symbol VARCHAR(20) NOT NULL UNIQUE,       -- 交易品种
    bid NUMERIC(18, 6) NOT NULL,              -- 买价
    ask NUMERIC(18, 6) NOT NULL,              -- 卖价
    last_price NUMERIC(18, 6) NOT NULL,       -- 最新价 (中间价)
    spread NUMERIC(18, 6),                    -- 点差
    timestamp TIMESTAMP NOT NULL,             -- 报价时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tick_symbol ON t_market_tick(symbol);
CREATE INDEX idx_tick_timestamp ON t_market_tick(timestamp DESC);

COMMENT ON TABLE t_market_tick IS '实时行情Tick表';
COMMENT ON COLUMN t_market_tick.symbol IS '交易品种';
COMMENT ON COLUMN t_market_tick.bid IS '买价';
COMMENT ON COLUMN t_market_tick.ask IS '卖价';
COMMENT ON COLUMN t_market_tick.last_price IS '最新价 (bid+ask)/2';
COMMENT ON COLUMN t_market_tick.spread IS '点差 ask-bid';
COMMENT ON COLUMN t_market_tick.timestamp IS '报价时间';


-- ============================================================
-- 3. 数据源配置表
-- ============================================================
CREATE TABLE t_data_source (
    id BIGSERIAL PRIMARY KEY,
    symbol VARCHAR(20) NOT NULL,
    api_name VARCHAR(50) NOT NULL,            -- API名称: AlphaVantage, FRED, MetalsAPI等
    api_key VARCHAR(255),                     -- API密钥 (加密存储)
    api_url VARCHAR(500),                     -- API请求地址
    update_interval INTEGER DEFAULT 60,       -- 更新间隔(秒)
    last_update TIMESTAMP,                    -- 最后更新时间
    update_status VARCHAR(20),                -- 更新状态: SUCCESS, FAILED, PENDING
    error_message TEXT,                       -- 错误信息
    is_active SMALLINT DEFAULT 1,             -- 是否启用: 0-禁用, 1-启用
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_data_source_unique ON t_data_source(symbol, api_name);
CREATE INDEX idx_data_source_symbol ON t_data_source(symbol);
CREATE INDEX idx_data_source_is_active ON t_data_source(is_active);

COMMENT ON TABLE t_data_source IS '数据源配置表';
COMMENT ON COLUMN t_data_source.symbol IS '交易品种';
COMMENT ON COLUMN t_data_source.api_name IS 'API提供商名称';
COMMENT ON COLUMN t_data_source.api_key IS 'API密钥';
COMMENT ON COLUMN t_data_source.api_url IS 'API请求地址';
COMMENT ON COLUMN t_data_source.update_interval IS '更新间隔(秒)';
COMMENT ON COLUMN t_data_source.last_update IS '最后更新时间';
COMMENT ON COLUMN t_data_source.update_status IS '更新状态';
COMMENT ON COLUMN t_data_source.is_active IS '是否启用';


-- ============================================================
-- 4. 数据更新日志表
-- ============================================================
CREATE TABLE t_data_update_log (
    id BIGSERIAL PRIMARY KEY,
    symbol VARCHAR(20) NOT NULL,
    api_name VARCHAR(50) NOT NULL,
    update_type VARCHAR(20) NOT NULL,         -- 更新类型: HISTORY, REALTIME, MANUAL
    records_count INTEGER DEFAULT 0,          -- 更新记录数
    start_time TIMESTAMP NOT NULL,            -- 更新开始时间
    end_time TIMESTAMP,                       -- 更新结束时间
    duration_ms INTEGER,                      -- 耗时(毫秒)
    status VARCHAR(20) NOT NULL,              -- 状态: SUCCESS, FAILED
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_update_log_symbol ON t_data_update_log(symbol);
CREATE INDEX idx_update_log_created_at ON t_data_update_log(created_at DESC);
CREATE INDEX idx_update_log_status ON t_data_update_log(status);

COMMENT ON TABLE t_data_update_log IS '数据更新日志表';


-- ============================================================
-- 自动更新 updated_at 的触发器
-- ============================================================
CREATE TRIGGER update_t_market_kline_updated_at BEFORE UPDATE ON t_market_kline
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_t_market_tick_updated_at BEFORE UPDATE ON t_market_tick
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_t_data_source_updated_at BEFORE UPDATE ON t_data_source
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ============================================================
-- 初始化数据源配置 (示例)
-- ============================================================
INSERT INTO t_data_source (symbol, api_name, api_url, update_interval, is_active) VALUES
('EURUSD', 'AlphaVantage', 'https://www.alphavantage.co/query', 300, 1),
('GBPUSD', 'AlphaVantage', 'https://www.alphavantage.co/query', 300, 1),
('XAUUSD', 'MetalsAPI', 'https://metals-api.com/api/latest', 300, 1),
('USDX', 'FRED', 'https://api.stlouisfed.org/fred/series/observations', 86400, 1);

COMMENT ON TABLE t_data_source IS '数据源配置: AlphaVantage(外汇), MetalsAPI(黄金), FRED(美元指数)';


-- ============================================================
-- 初始化实时Tick数据 (占位数据)
-- ============================================================
INSERT INTO t_market_tick (symbol, bid, ask, last_price, spread, timestamp) VALUES
('EURUSD', 1.08500, 1.08502, 1.08501, 0.00002, CURRENT_TIMESTAMP),
('GBPUSD', 1.26500, 1.26503, 1.265015, 0.00003, CURRENT_TIMESTAMP),
('XAUUSD', 2650.00, 2650.50, 2650.25, 0.50, CURRENT_TIMESTAMP),
('USDX', 106.500, 106.500, 106.500, 0, CURRENT_TIMESTAMP);


-- ============================================================
-- 常用查询视图
-- ============================================================

-- 最新价格视图
CREATE VIEW v_latest_prices AS
SELECT
    symbol,
    last_price,
    bid,
    ask,
    spread,
    timestamp AS quote_time,
    updated_at
FROM t_market_tick
ORDER BY symbol;

COMMENT ON VIEW v_latest_prices IS '最新价格视图';


-- 日K线统计视图
CREATE VIEW v_daily_kline AS
SELECT
    symbol,
    DATE(open_time) AS trade_date,
    MIN(open_time) AS first_time,
    MAX(close_time) AS last_time,
    (ARRAY_AGG(open_price ORDER BY open_time))[1] AS open_price,
    MAX(high_price) AS high_price,
    MIN(low_price) AS low_price,
    (ARRAY_AGG(close_price ORDER BY close_time DESC))[1] AS close_price,
    SUM(volume) AS total_volume,
    COUNT(*) AS bar_count
FROM t_market_kline
WHERE timeframe = '1m'
GROUP BY symbol, DATE(open_time)
ORDER BY symbol, trade_date DESC;

COMMENT ON VIEW v_daily_kline IS '日K线聚合视图 (从1分钟K线聚合)';


-- ============================================================
-- 数据清理存储过程 (保留近2年数据)
-- ============================================================
CREATE OR REPLACE FUNCTION clean_old_kline_data()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- 删除2年前的数据
    DELETE FROM t_market_kline
    WHERE open_time < (CURRENT_TIMESTAMP - INTERVAL '2 years');

    GET DIAGNOSTICS deleted_count = ROW_COUNT;

    -- 记录清理日志
    INSERT INTO t_data_update_log (symbol, api_name, update_type, records_count, start_time, end_time, status)
    VALUES ('ALL', 'SYSTEM', 'CLEANUP', deleted_count, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'SUCCESS');

    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION clean_old_kline_data() IS '清理2年前的K线数据';


-- ============================================================
-- 性能优化建议
-- ============================================================
-- 1. 定期执行 VACUUM ANALYZE t_market_kline;
-- 2. 如果数据量超过1000万，考虑按月分区
-- 3. 使用 pg_cron 扩展定时清理旧数据:
--    SELECT cron.schedule('0 2 * * 0', 'SELECT clean_old_kline_data()');
