package com.quant.server.controller;

import com.quant.server.common.Result;
import com.quant.server.service.UnifiedCodeFileService;
import com.quant.server.vo.CodeFileVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 代码文件 Controller（统一处理三张表）
 */
@Slf4j
@Api(tags = "代码文件管理（三表版）")
@RestController
@RequestMapping("/code-file")
public class UnifiedCodeFileController {

    @Autowired
    private UnifiedCodeFileService unifiedCodeFileService;

    @ApiOperation("获取文件列表(按类型和用户)")
    @GetMapping("/list")
    public Result<List<CodeFileVO>> list(
            @ApiParam("类型: indicator/strategy/library") @RequestParam String type,
            @ApiParam("用户ID") @RequestParam Long userId
    ) {
        List<CodeFileVO> files = unifiedCodeFileService.listByTypeAndUser(type, userId);
        return Result.success(files);
    }

    @ApiOperation("获取公开文件列表")
    @GetMapping("/public/list")
    public Result<List<CodeFileVO>> listPublic(
            @ApiParam("类型: indicator/strategy/library") @RequestParam String type
    ) {
        List<CodeFileVO> files = unifiedCodeFileService.listPublicByType(type);
        return Result.success(files);
    }

    @ApiOperation("获取文件详情")
    @GetMapping("/{id}")
    public Result<CodeFileVO> getById(
            @ApiParam("类型: indicator/strategy/library") @RequestParam String type,
            @PathVariable Long id
    ) {
        CodeFileVO file = unifiedCodeFileService.getById(type, id);
        return Result.success(file);
    }

    @ApiOperation("创建文件")
    @PostMapping("/create")
    public Result<CodeFileVO> create(
            @ApiParam("类型: indicator/strategy/library") @RequestParam String type,
            @Validated @RequestBody CodeFileVO request,
            @ApiParam("用户ID") @RequestParam Long userId
    ) {
        request.setUserId(userId);
        CodeFileVO created = unifiedCodeFileService.createFile(type, request);
        return Result.success("创建成功", created);
    }

    @ApiOperation("更新文件")
    @PutMapping("/update")
    public Result<CodeFileVO> update(
            @ApiParam("类型: indicator/strategy/library") @RequestParam String type,
            @Validated @RequestBody CodeFileVO request
    ) {
        CodeFileVO updated = unifiedCodeFileService.updateFile(type, request);
        return Result.success("更新成功", updated);
    }

    @ApiOperation("删除文件")
    @DeleteMapping("/{id}")
    public Result<Void> delete(
            @ApiParam("类型: indicator/strategy/library") @RequestParam String type,
            @PathVariable Long id
    ) {
        unifiedCodeFileService.deleteFile(type, id);
        return Result.success("删除成功", null);
    }

    @ApiOperation("复制文件")
    @PostMapping("/copy/{id}")
    public Result<Long> copy(
            @ApiParam("类型: indicator/strategy/library") @RequestParam String type,
            @PathVariable Long id,
            @ApiParam("用户ID") @RequestParam Long userId
    ) {
        Long newFileId = unifiedCodeFileService.copyFile(type, id, userId);
        return Result.success("复制成功", newFileId);
    }

    @ApiOperation("重命名文件")
    @PutMapping("/rename/{id}")
    public Result<CodeFileVO> rename(
            @ApiParam("类型: indicator/strategy/library") @RequestParam String type,
            @PathVariable Long id,
            @ApiParam("新文件名") @RequestParam String newName
    ) {
        CodeFileVO renamed = unifiedCodeFileService.renameFile(type, id, newName);
        return Result.success("重命名成功", renamed);
    }
}
