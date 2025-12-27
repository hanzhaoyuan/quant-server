package com.quant.server.controller;

import com.quant.server.common.Result;
import com.quant.server.dto.LoginRequest;
import com.quant.server.dto.RegisterRequest;
import com.quant.server.entity.User;
import com.quant.server.service.UserService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 用户 Controller
 */
@Slf4j
@Api(tags = "用户管理")
@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService userService;

    @ApiOperation("用户注册")
    @PostMapping("/register")
    public Result<Map<String, Object>> register(@Validated @RequestBody RegisterRequest request) {
        User user = userService.register(request.getUsername(), request.getPassword(), request.getEmail());

        Map<String, Object> data = new HashMap<>();
        data.put("userId", user.getId());
        data.put("username", user.getUsername());

        return Result.success("注册成功", data);
    }

    @ApiOperation("用户登录")
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@Validated @RequestBody LoginRequest request) {
        String token = userService.login(request.getUsername(), request.getPassword());

        User user = userService.getByUsername(request.getUsername());

        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("userId", user.getId());
        data.put("username", user.getUsername());
        data.put("role", user.getRole());

        return Result.success("登录成功", data);
    }

    @ApiOperation("获取当前用户信息")
    @GetMapping("/info")
    public Result<User> info(@RequestParam Long userId) {
        User user = userService.getById(userId);
        if (user != null) {
            // 不返回密码
            user.setPassword(null);
        }
        return Result.success(user);
    }
}
