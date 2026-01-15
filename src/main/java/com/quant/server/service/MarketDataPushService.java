package com.quant.server.service;

import com.quant.server.dto.KlineQueryRequest;
import com.quant.server.vo.KlineVO;
import com.quant.server.vo.MarketTickVO;
import com.quant.server.websocket.MarketWebSocketHandler;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 行情数据推送服务
 * 定时推送最新行情数据给WebSocket客户端
 */
@Slf4j
@Service
public class MarketDataPushService {

    @Resource
    private MarketDataService marketDataService;

    @Resource
    private MarketWebSocketHandler marketWebSocketHandler;

    /**
     * 定时推送实时报价数据
     * 每3秒推送一次
     */
    @Scheduled(fixedDelay = 3000)
    public void pushRealtimeTicks() {
        try {
            if (marketWebSocketHandler.getConnectionCount() == 0) {
                // 没有客户端连接，跳过推送
                return;
            }

            // 获取所有品种的实时报价
            List<MarketTickVO> ticks = marketDataService.getAllTicks();

            if (ticks != null && !ticks.isEmpty()) {
                // 推送给所有客户端
                Map<String, Object> message = new HashMap<>();
                message.put("type", "tick");
                message.put("data", ticks);
                message.put("timestamp", System.currentTimeMillis());

                marketWebSocketHandler.broadcast(message);

                log.debug("推送实时报价: {} 个品种, {} 个客户端",
                        ticks.size(), marketWebSocketHandler.getConnectionCount());
            }
        } catch (Exception e) {
            log.error("推送实时报价失败: {}", e.getMessage());
        }
    }

    /**
     * 定时推送K线数据（模拟新K线生成）
     * 每10秒推送一次
     */
    @Scheduled(fixedDelay = 10000)
    public void pushLatestKline() {
        try {
            if (marketWebSocketHandler.getConnectionCount() == 0) {
                return;
            }

            // 获取所有支持的品种
            List<String> symbols = marketDataService.getAllSymbols();

            for (String symbol : symbols) {
                try {
                    // 获取最新的K线数据（1分钟K线）
                    KlineQueryRequest request = new KlineQueryRequest();
                    request.setSymbol(symbol);
                    request.setTimeframe("1m");
                    request.setLimit(1);

                    List<KlineVO> klines = marketDataService.queryKlineData(request);

                    if (klines != null && !klines.isEmpty()) {
                        KlineVO latestKline = klines.get(0);

                        // 构造推送消息
                        Map<String, Object> message = new HashMap<>();
                        message.put("type", "kline");
                        message.put("symbol", symbol);
                        message.put("timeframe", "1m");
                        message.put("data", latestKline);
                        message.put("timestamp", System.currentTimeMillis());

                        // 推送给订阅了该品种的客户端
                        marketWebSocketHandler.pushMarketData(symbol, message);

                        log.debug("推送K线数据: symbol={}, time={}", symbol, latestKline.getTime());
                    }
                } catch (Exception e) {
                    log.error("推送K线数据失败: symbol={}, error={}", symbol, e.getMessage());
                }
            }
        } catch (Exception e) {
            log.error("推送K线数据失败: {}", e.getMessage());
        }
    }
}
