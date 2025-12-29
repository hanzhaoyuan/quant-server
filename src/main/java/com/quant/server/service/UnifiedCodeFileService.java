package com.quant.server.service;

import com.quant.server.vo.CodeFileVO;

import java.util.List;

/**
 * 统一的代码文件服务接口（桥接三张表：indicator/strategy/library）
 */
public interface UnifiedCodeFileService {

    /**
     * 根据类型和用户获取文件列表
     */
    List<CodeFileVO> listByTypeAndUser(String type, Long userId);

    /**
     * 根据类型获取公开文件列表
     */
    List<CodeFileVO> listPublicByType(String type);

    /**
     * 根据ID获取文件详情
     */
    CodeFileVO getById(String type, Long id);

    /**
     * 创建文件
     */
    CodeFileVO createFile(String type, CodeFileVO fileVO);

    /**
     * 更新文件
     */
    CodeFileVO updateFile(String type, CodeFileVO fileVO);

    /**
     * 删除文件
     */
    boolean deleteFile(String type, Long id);

    /**
     * 复制文件
     */
    Long copyFile(String type, Long id, Long userId);

    /**
     * 重命名文件
     */
    CodeFileVO renameFile(String type, Long id, String newName);
}
