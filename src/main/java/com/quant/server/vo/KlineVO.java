package com.quant.server.vo;

import lombok.Data;

import java.math.BigDecimal;

/**
 * K线数据VO（前端展示）
 */
@Data
public class KlineVO {
    /**
     * 时间戳（毫秒）
     */
    private Long time;

    /**
     * 开盘价
     */
    private BigDecimal open;

    /**
     * 最高价
     */
    private BigDecimal high;

    /**
     * 最低价
     */
    private BigDecimal low;

    /**
     * 收盘价
     */
    private BigDecimal close;

    /**
     * 成交量
     */
    private BigDecimal volume;
}
