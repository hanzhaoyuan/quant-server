package com.quant.server.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;
import java.util.Map;

/**
 * 指标计算请求
 */
@Data
public class IndicatorCalculateRequest {

    /**
     * 指标ID（可选，如果提供则从数据库读取代码）
     */
    private Long indicatorId;

    /**
     * 指标代码（可选，如果不提供indicatorId则必须提供code）
     */
    private String code;

    /**
     * 品种代码
     */
    private String symbol;

    /**
     * 时间周期
     */
    private String timeframe;

    /**
     * 开始时间（可选）
     */
    private String startTime;

    /**
     * 结束时间（可选）
     */
    private String endTime;

    /**
     * 数据条数限制（可选，默认200）
     */
    private Integer limit;

    /**
     * 指标参数（可选）
     */
    private Map<String, Object> params;

    /**
     * K线数据（可选，如果提供则直接使用，否则根据symbol等参数查询）
     */
    @JsonProperty("kline_data")
    private List<KlineData> klineData;

    /**
     * K线数据内部类
     */
    @Data
    public static class KlineData {
        private Long time;
        private Double open;
        private Double high;
        private Double low;
        private Double close;
        private Double volume;
    }
}
