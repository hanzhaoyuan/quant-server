package com.quant.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.quant.server.common.BusinessException;
import com.quant.server.entity.CodeFile;
import com.quant.server.mapper.CodeFileMapper;
import com.quant.server.service.CodeFileService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 代码文件 Service 实现类
 */
@Slf4j
@Service
public class CodeFileServiceImpl extends ServiceImpl<CodeFileMapper, CodeFile> implements CodeFileService {

    @Override
    public List<CodeFile> listByTypeAndUser(String type, Long userId) {
        LambdaQueryWrapper<CodeFile> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(CodeFile::getType, type)
                .eq(CodeFile::getUserId, userId)
                .orderByDesc(CodeFile::getUpdatedAt);
        return list(queryWrapper);
    }

    @Override
    public List<CodeFile> listPublicByType(String type) {
        LambdaQueryWrapper<CodeFile> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(CodeFile::getType, type)
                .eq(CodeFile::getIsPublic, 1)
                .orderByDesc(CodeFile::getUpdatedAt);
        return list(queryWrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean createCodeFile(CodeFile codeFile) {
        // 校验文件名是否重复
        LambdaQueryWrapper<CodeFile> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(CodeFile::getName, codeFile.getName())
                .eq(CodeFile::getUserId, codeFile.getUserId())
                .eq(CodeFile::getType, codeFile.getType());
        if (count(queryWrapper) > 0) {
            throw new BusinessException("文件名已存在");
        }

        return save(codeFile);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateCodeFile(CodeFile codeFile) {
        CodeFile existingFile = getById(codeFile.getId());
        if (existingFile == null) {
            throw new BusinessException("文件不存在");
        }

        // 如果修改了文件名,检查是否重复
        if (!existingFile.getName().equals(codeFile.getName())) {
            LambdaQueryWrapper<CodeFile> queryWrapper = new LambdaQueryWrapper<>();
            queryWrapper.eq(CodeFile::getName, codeFile.getName())
                    .eq(CodeFile::getUserId, codeFile.getUserId())
                    .eq(CodeFile::getType, codeFile.getType())
                    .ne(CodeFile::getId, codeFile.getId());
            if (count(queryWrapper) > 0) {
                throw new BusinessException("文件名已存在");
            }
        }

        return updateById(codeFile);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteCodeFile(Long id) {
        return removeById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long copyCodeFile(Long id, Long userId) {
        CodeFile sourceFile = getById(id);
        if (sourceFile == null) {
            throw new BusinessException("源文件不存在");
        }

        // 生成新文件名
        String baseName = sourceFile.getName().replaceAll("\\.py$", "");
        String newName = generateCopyName(baseName, sourceFile.getType(), userId);

        CodeFile newFile = new CodeFile();
        newFile.setName(newName);
        newFile.setType(sourceFile.getType());
        newFile.setContent(sourceFile.getContent());
        newFile.setDescription(sourceFile.getDescription());
        newFile.setAuthor(sourceFile.getAuthor());
        newFile.setVersion(sourceFile.getVersion());
        newFile.setUserId(userId);
        newFile.setIsPublic(0);

        save(newFile);
        return newFile.getId();
    }

    /**
     * 生成复制文件名
     */
    private String generateCopyName(String baseName, String type, Long userId) {
        LambdaQueryWrapper<CodeFile> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(CodeFile::getUserId, userId)
                .eq(CodeFile::getType, type)
                .like(CodeFile::getName, baseName + "_copy");

        List<CodeFile> existingFiles = list(queryWrapper);

        int copyNumber = 1;
        String newName;
        boolean nameExists;

        do {
            newName = baseName + "_copy" + copyNumber + ".py";
            final String finalNewName = newName;
            nameExists = existingFiles.stream().anyMatch(f -> f.getName().equals(finalNewName));
            if (nameExists) {
                copyNumber++;
            }
        } while (nameExists);

        return newName;
    }
}
