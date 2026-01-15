package com.quant.server.websocket;

import com.alibaba.fastjson2.JSON;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 行情数据 WebSocket 处理器
 * 管理客户端连接和数据推送
 */
@Slf4j
@Component
public class MarketWebSocketHandler extends TextWebSocketHandler {

    /**
     * 存储所有连接的客户端
     * key: session id
     * value: WebSocketSession
     */
    private final Map<String, WebSocketSession> sessions = new ConcurrentHashMap<>();

    /**
     * 存储每个客户端订阅的交易品种
     * key: session id
     * value: 订阅的品种（如 EURUSD, GBPUSD 等）
     */
    private final Map<String, String> subscriptions = new ConcurrentHashMap<>();

    /**
     * 客户端连接建立时调用
     */
    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        sessions.put(session.getId(), session);
        log.info("WebSocket连接建立: sessionId={}, 当前连接数={}", session.getId(), sessions.size());

        // 发送欢迎消息
        Map<String, Object> welcomeMsg = new HashMap<>();
        welcomeMsg.put("type", "connected");
        welcomeMsg.put("message", "WebSocket连接成功");
        welcomeMsg.put("sessionId", session.getId());
        sendMessage(session, welcomeMsg);
    }

    /**
     * 接收客户端消息
     */
    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        String payload = message.getPayload();
        log.info("收到客户端消息: sessionId={}, message={}", session.getId(), payload);

        try {
            Map<String, Object> msg = JSON.parseObject(payload, Map.class);
            String action = (String) msg.get("action");

            if ("subscribe".equals(action)) {
                // 订阅交易品种
                String symbol = (String) msg.get("symbol");
                subscriptions.put(session.getId(), symbol);
                log.info("客户端订阅: sessionId={}, symbol={}", session.getId(), symbol);

                // 发送订阅确认
                Map<String, Object> subscribeMsg = new HashMap<>();
                subscribeMsg.put("type", "subscribed");
                subscribeMsg.put("symbol", symbol);
                subscribeMsg.put("message", "订阅成功");
                sendMessage(session, subscribeMsg);
            } else if ("unsubscribe".equals(action)) {
                // 取消订阅
                subscriptions.remove(session.getId());
                log.info("客户端取消订阅: sessionId={}", session.getId());

                Map<String, Object> unsubscribeMsg = new HashMap<>();
                unsubscribeMsg.put("type", "unsubscribed");
                unsubscribeMsg.put("message", "取消订阅成功");
                sendMessage(session, unsubscribeMsg);
            } else if ("ping".equals(action)) {
                // 心跳检测
                Map<String, Object> pongMsg = new HashMap<>();
                pongMsg.put("type", "pong");
                sendMessage(session, pongMsg);
            }
        } catch (Exception e) {
            log.error("处理客户端消息失败: sessionId={}, error={}", session.getId(), e.getMessage());
            Map<String, Object> errorMsg = new HashMap<>();
            errorMsg.put("type", "error");
            errorMsg.put("message", "消息处理失败: " + e.getMessage());
            sendMessage(session, errorMsg);
        }
    }

    /**
     * 连接关闭时调用
     */
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        sessions.remove(session.getId());
        subscriptions.remove(session.getId());
        log.info("WebSocket连接关闭: sessionId={}, status={}, 当前连接数={}",
                session.getId(), status, sessions.size());
    }

    /**
     * 发生错误时调用
     */
    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        log.error("WebSocket传输错误: sessionId={}, error={}", session.getId(), exception.getMessage());
        if (session.isOpen()) {
            session.close();
        }
    }

    /**
     * 向指定会话发送消息
     */
    private void sendMessage(WebSocketSession session, Object data) {
        try {
            if (session.isOpen()) {
                String jsonMessage = JSON.toJSONString(data);
                session.sendMessage(new TextMessage(jsonMessage));
            }
        } catch (IOException e) {
            log.error("发送消息失败: sessionId={}, error={}", session.getId(), e.getMessage());
        }
    }

    /**
     * 向所有订阅了指定品种的客户端推送数据
     */
    public void pushMarketData(String symbol, Object data) {
        subscriptions.forEach((sessionId, subscribedSymbol) -> {
            if (subscribedSymbol.equals(symbol)) {
                WebSocketSession session = sessions.get(sessionId);
                if (session != null && session.isOpen()) {
                    sendMessage(session, data);
                }
            }
        });
    }

    /**
     * 广播消息给所有客户端
     */
    public void broadcast(Object data) {
        sessions.values().forEach(session -> {
            if (session.isOpen()) {
                sendMessage(session, data);
            }
        });
    }

    /**
     * 获取当前连接数
     */
    public int getConnectionCount() {
        return sessions.size();
    }
}
