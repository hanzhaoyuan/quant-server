package com.quant.server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.quant.server.entity.MarketKline;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;

/**
 * K线数据Mapper
 */
@Mapper
public interface MarketKlineMapper extends BaseMapper<MarketKline> {

    /**
     * 查询指定品种和时间范围的K线数据
     */
    @Select("SELECT * FROM t_market_kline " +
            "WHERE symbol = #{symbol} AND timeframe = #{timeframe} " +
            "AND open_time >= #{startTime} AND open_time <= #{endTime} " +
            "ORDER BY open_time ASC")
    List<MarketKline> selectBySymbolAndTimeRange(
            @Param("symbol") String symbol,
            @Param("timeframe") String timeframe,
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime
    );

    /**
     * 查询最新N条K线数据
     */
    @Select("SELECT * FROM t_market_kline " +
            "WHERE symbol = #{symbol} AND timeframe = #{timeframe} " +
            "ORDER BY open_time DESC " +
            "LIMIT #{limit}")
    List<MarketKline> selectLatestN(
            @Param("symbol") String symbol,
            @Param("timeframe") String timeframe,
            @Param("limit") Integer limit
    );

    /**
     * 获取所有可用的交易品种
     */
    @Select("SELECT DISTINCT symbol FROM t_market_kline ORDER BY symbol")
    List<String> selectAllSymbols();
}
