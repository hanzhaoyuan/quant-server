package com.quant.server.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 代码文件创建/更新请求 DTO
 */
@Data
public class CodeFileRequest {

    private Long id;

    @NotBlank(message = "文件名不能为空")
    private String name;

    @NotBlank(message = "类型不能为空")
    private String type;

    @NotBlank(message = "内容不能为空")
    private String content;

    private String description;

    private String author;

    private String version;

    private Integer isPublic;
}
