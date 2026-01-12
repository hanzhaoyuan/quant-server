package com.quant.server.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 实时行情Tick实体
 */
@Data
@TableName("t_market_tick")
public class MarketTick {
    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

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
     * 报价时间
     */
    private LocalDateTime timestamp;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}
