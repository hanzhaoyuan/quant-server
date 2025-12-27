package com.quant.server.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.quant.server.entity.User;

/**
 * 用户 Service 接口
 */
public interface UserService extends IService<User> {

    /**
     * 根据用户名查询用户
     *
     * @param username 用户名
     * @return 用户对象
     */
    User getByUsername(String username);

    /**
     * 用户注册
     *
     * @param username 用户名
     * @param password 密码
     * @param email    邮箱
     * @return 用户对象
     */
    User register(String username, String password, String email);

    /**
     * 用户登录
     *
     * @param username 用户名
     * @param password 密码
     * @return Token
     */
    String login(String username, String password);

    /**
     * 修改密码
     *
     * @param userId      用户ID
     * @param oldPassword 旧密码
     * @param newPassword 新密码
     * @return 是否成功
     */
    boolean changePassword(Long userId, String oldPassword, String newPassword);
}
