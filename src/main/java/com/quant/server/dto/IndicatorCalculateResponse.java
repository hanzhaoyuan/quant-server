package com.quant.server.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 指标计算响应
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class IndicatorCalculateResponse {

    /**
     * 指标线数据列表
     */
    private List<IndicatorLine> lines;

    /**
     * 指标线数据
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class IndicatorLine {
        /**
         * 线的名称（如 MA5, MACD, RSI 等）
         */
        private String name;

        /**
         * 数据点列表
         */
        private List<DataPoint> values;
    }

    /**
     * 数据点
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DataPoint {
        /**
         * 时间戳（毫秒）
         */
        private Long time;

        /**
         * 指标值
         */
        private Double value;
    }
}
