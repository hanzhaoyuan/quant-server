package com.quant.server.dto;

import lombok.Data;

/**
 * K线查询请求
 */
@Data
public class KlineQueryRequest {
    /**
     * 交易品种（必填）
     */
    private String symbol;

    /**
     * 时间周期（必填）: 1m, 5m, 15m, 1h, 4h, 1d
     */
    private String timeframe;

    /**
     * 开始时间（可选，格式: 2024-01-01 或 2024-01-01 10:00:00）
     */
    private String startTime;

    /**
     * 结束时间（可选）
     */
    private String endTime;

    /**
     * 限制返回条数（可选，默认100）
     */
    private Integer limit;
}
