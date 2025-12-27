package com.quant.server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.quant.server.entity.BacktestTask;
import org.apache.ibatis.annotations.Mapper;

/**
 * 回测任务 Mapper 接口
 */
@Mapper
public interface BacktestTaskMapper extends BaseMapper<BacktestTask> {
}
