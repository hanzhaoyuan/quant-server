package com.quant.server.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 策略实体
 */
@Data
@TableName("t_strategy")
public class Strategy implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 策略文件名 (含扩展名)
     */
    private String name;

    /**
     * 代码内容
     */
    private String content;

    /**
     * 描述信息
     */
    private String description;

    /**
     * 作者
     */
    private String author;

    /**
     * 版本号
     */
    private String version;

    /**
     * 创建者ID
     */
    private Long userId;

    /**
     * 是否公开: 0-私有, 1-公开
     */
    private Integer isPublic;

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
