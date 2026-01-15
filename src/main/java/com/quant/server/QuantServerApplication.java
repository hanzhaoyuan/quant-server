package com.quant.server;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * 量化平台后端服务启动类
 *
 * @author Quant Team
 * @since 2024-01-01
 */
@SpringBootApplication
@EnableScheduling
@MapperScan("com.quant.server.mapper")
public class QuantServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(QuantServerApplication.class, args);
        System.out.println("\n========================================");
        System.out.println("   Quant Server 启动成功!");
        System.out.println("   Swagger 文档地址: http://localhost:8080/api/swagger-ui/");
        System.out.println("   Druid 监控地址: http://localhost:8080/api/druid/");
        System.out.println("========================================\n");
    }
}
