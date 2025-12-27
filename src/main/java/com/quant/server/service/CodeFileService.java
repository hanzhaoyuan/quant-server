package com.quant.server.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.quant.server.entity.CodeFile;

import java.util.List;

/**
 * 代码文件 Service 接口
 */
public interface CodeFileService extends IService<CodeFile> {

    /**
     * 根据类型和用户ID查询文件列表
     *
     * @param type   类型 (indicator/strategy/library)
     * @param userId 用户ID
     * @return 文件列表
     */
    List<CodeFile> listByTypeAndUser(String type, Long userId);

    /**
     * 根据类型查询公开文件列表
     *
     * @param type 类型
     * @return 文件列表
     */
    List<CodeFile> listPublicByType(String type);

    /**
     * 创建代码文件
     *
     * @param codeFile 代码文件对象
     * @return 是否成功
     */
    boolean createCodeFile(CodeFile codeFile);

    /**
     * 更新代码文件
     *
     * @param codeFile 代码文件对象
     * @return 是否成功
     */
    boolean updateCodeFile(CodeFile codeFile);

    /**
     * 删除代码文件 (逻辑删除)
     *
     * @param id 文件ID
     * @return 是否成功
     */
    boolean deleteCodeFile(Long id);

    /**
     * 复制代码文件
     *
     * @param id     源文件ID
     * @param userId 用户ID
     * @return 新文件ID
     */
    Long copyCodeFile(Long id, Long userId);
}
