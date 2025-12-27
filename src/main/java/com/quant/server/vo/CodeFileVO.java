package com.quant.server.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 代码文件响应 VO
 */
@Data
public class CodeFileVO {

    private Long id;

    private String name;

    private String type;

    private String content;

    private String description;

    private String author;

    private String version;

    private Long userId;

    private Integer isPublic;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    /**
     * 格式化的最后编辑时间
     */
    private String lastModified;
}
