package com.quant.server.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * K线数据实体
 */
@Data
@TableName("t_market_kline")
public class MarketKline {
    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 交易品种: EURUSD, GBPUSD, XAUUSD, USDX
     */
    private String symbol;

    /**
     * 时间周期: 1m, 5m, 15m, 1h, 4h, 1d
     */
    private String timeframe;

    /**
     * K线开始时间
     */
    private LocalDateTime openTime;

    /**
     * K线结束时间
     */
    private LocalDateTime closeTime;

    /**
     * 开盘价
     */
    private BigDecimal openPrice;

    /**
     * 最高价
     */
    private BigDecimal highPrice;

    /**
     * 最低价
     */
    private BigDecimal lowPrice;

    /**
     * 收盘价
     */
    private BigDecimal closePrice;

    /**
     * 成交量
     */
    private BigDecimal volume;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}
