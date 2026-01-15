package com.quant.server.config;

import com.quant.server.websocket.MarketWebSocketHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

/**
 * WebSocket 配置类
 * 用于实时行情数据推送
 */
@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    private final MarketWebSocketHandler marketWebSocketHandler;

    public WebSocketConfig(MarketWebSocketHandler marketWebSocketHandler) {
        this.marketWebSocketHandler = marketWebSocketHandler;
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        // 注册WebSocket处理器
        registry.addHandler(marketWebSocketHandler, "/ws/market")
                .setAllowedOrigins("*"); // 允许所有来源（生产环境应该配置具体域名）
    }
}
