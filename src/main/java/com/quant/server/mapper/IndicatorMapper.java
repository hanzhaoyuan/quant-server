package com.quant.server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.quant.server.entity.Indicator;
import org.apache.ibatis.annotations.Mapper;

/**
 * 指标 Mapper 接口
 */
@Mapper
public interface IndicatorMapper extends BaseMapper<Indicator> {
}
