package com.quant.server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.quant.server.entity.Library;
import org.apache.ibatis.annotations.Mapper;

/**
 * 库 Mapper 接口
 */
@Mapper
public interface LibraryMapper extends BaseMapper<Library> {
}
