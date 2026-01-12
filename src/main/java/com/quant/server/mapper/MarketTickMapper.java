package com.quant.server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.quant.server.entity.MarketTick;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 实时行情Tick Mapper
 */
@Mapper
public interface MarketTickMapper extends BaseMapper<MarketTick> {

    /**
     * 获取所有实时报价
     */
    @Select("SELECT * FROM t_market_tick ORDER BY symbol")
    List<MarketTick> selectAllTicks();

    /**
     * 根据交易品种获取实时报价
     */
    @Select("SELECT * FROM t_market_tick WHERE symbol = #{symbol}")
    MarketTick selectBySymbol(String symbol);
}
