package com.quant.server.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Map;

/**
 * 回测任务实体
 */
@Data
@TableName(value = "t_backtest_task", autoResultMap = true)
public class BacktestTask implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 任务ID (由 Agent 生成)
     */
    private String taskId;

    /**
     * 策略ID
     */
    private Long strategyId;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 任务类型: backtest, optimize, live_trade
     */
    private String taskType;

    /**
     * 任务参数 (JSON 格式)
     */
    @TableField(typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> params;

    /**
     * 状态: PENDING, RUNNING, SUCCESS, FAILED
     */
    private String status;

    /**
     * 回测结果 (JSON 格式)
     */
    @TableField(typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> result;

    /**
     * 错误信息
     */
    private String errorMessage;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    /**
     * 逻辑删除: 0-正常, 1-已删除
     */
    @TableLogic
    private Integer deleted;
}
