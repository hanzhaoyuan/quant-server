package com.quant.server.vo;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 实时行情VO
 */
@Data
public class MarketTickVO {
    /**
     * 交易品种
     */
    private String symbol;

    /**
     * 买价
     */
    private BigDecimal bid;

    /**
     * 卖价
     */
    private BigDecimal ask;

    /**
     * 最新价
     */
    private BigDecimal lastPrice;

    /**
     * 点差
     */
    private BigDecimal spread;

    /**
     * 报价时间（毫秒时间戳）
     */
    private Long timestamp;

    /**
     * 涨跌幅（百分比）
     */
    private BigDecimal changePercent;
}
