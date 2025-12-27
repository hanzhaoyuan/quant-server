package com.quant.server.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 发布实体
 */
@Data
@TableName("t_publish")
public class Publish implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 资源类型: indicator, strategy, library
     */
    private String resourceType;

    /**
     * 资源ID
     */
    private Long resourceId;

    /**
     * 发布版本
     */
    private String version;

    /**
     * 发布者ID
     */
    private Long userId;

    /**
     * 状态: PENDING, PUBLISHED, REJECTED
     */
    private String status;

    /**
     * 审核信息
     */
    private String reviewMessage;

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
