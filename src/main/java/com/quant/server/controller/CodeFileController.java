package com.quant.server.controller;

import cn.hutool.core.bean.BeanUtil;
import com.quant.server.common.Result;
import com.quant.server.dto.CodeFileRequest;
import com.quant.server.entity.CodeFile;
import com.quant.server.service.CodeFileService;
import com.quant.server.vo.CodeFileVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 代码文件 Controller
 */
@Slf4j
@Api(tags = "代码文件管理")
@RestController
@RequestMapping("/code-file")
public class CodeFileController {

    @Autowired
    private CodeFileService codeFileService;

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @ApiOperation("获取文件列表(按类型和用户)")
    @GetMapping("/list")
    public Result<List<CodeFileVO>> list(
            @ApiParam("类型") @RequestParam String type,
            @ApiParam("用户ID") @RequestParam Long userId
    ) {
        List<CodeFile> files = codeFileService.listByTypeAndUser(type, userId);
        List<CodeFileVO> voList = files.stream().map(this::convertToVO).collect(Collectors.toList());
        return Result.success(voList);
    }

    @ApiOperation("获取公开文件列表")
    @GetMapping("/public/list")
    public Result<List<CodeFileVO>> listPublic(@ApiParam("类型") @RequestParam String type) {
        List<CodeFile> files = codeFileService.listPublicByType(type);
        List<CodeFileVO> voList = files.stream().map(this::convertToVO).collect(Collectors.toList());
        return Result.success(voList);
    }

    @ApiOperation("获取文件详情")
    @GetMapping("/{id}")
    public Result<CodeFileVO> getById(@PathVariable Long id) {
        CodeFile file = codeFileService.getById(id);
        return Result.success(convertToVO(file));
    }

    @ApiOperation("创建文件")
    @PostMapping("/create")
    public Result<CodeFileVO> create(
            @Validated @RequestBody CodeFileRequest request,
            @ApiParam("用户ID") @RequestParam Long userId
    ) {
        CodeFile codeFile = new CodeFile();
        BeanUtil.copyProperties(request, codeFile);
        codeFile.setUserId(userId);

        codeFileService.createCodeFile(codeFile);
        return Result.success("创建成功", convertToVO(codeFile));
    }

    @ApiOperation("更新文件")
    @PutMapping("/update")
    public Result<CodeFileVO> update(@Validated @RequestBody CodeFileRequest request) {
        CodeFile codeFile = new CodeFile();
        BeanUtil.copyProperties(request, codeFile);

        codeFileService.updateCodeFile(codeFile);
        return Result.success("更新成功", convertToVO(codeFile));
    }

    @ApiOperation("删除文件")
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        codeFileService.deleteCodeFile(id);
        return Result.success("删除成功", null);
    }

    @ApiOperation("复制文件")
    @PostMapping("/copy/{id}")
    public Result<Long> copy(
            @PathVariable Long id,
            @ApiParam("用户ID") @RequestParam Long userId
    ) {
        Long newFileId = codeFileService.copyCodeFile(id, userId);
        return Result.success("复制成功", newFileId);
    }

    /**
     * 转换为 VO
     */
    private CodeFileVO convertToVO(CodeFile codeFile) {
        if (codeFile == null) {
            return null;
        }

        CodeFileVO vo = new CodeFileVO();
        BeanUtil.copyProperties(codeFile, vo);

        if (codeFile.getUpdatedAt() != null) {
            vo.setLastModified(codeFile.getUpdatedAt().format(FORMATTER));
        }

        return vo;
    }
}
