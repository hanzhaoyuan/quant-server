package com.quant.server.service.impl;

import com.quant.server.dto.KlineQueryRequest;
import com.quant.server.entity.MarketKline;
import com.quant.server.entity.MarketTick;
import com.quant.server.mapper.MarketKlineMapper;
import com.quant.server.mapper.MarketTickMapper;
import com.quant.server.service.MarketDataService;
import com.quant.server.vo.KlineVO;
import com.quant.server.vo.MarketTickVO;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import javax.annotation.Resource;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 行情数据服务实现
 */
@Service
public class MarketDataServiceImpl implements MarketDataService {

    @Resource
    private MarketKlineMapper marketKlineMapper;

    @Resource
    private MarketTickMapper marketTickMapper;

    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    public List<KlineVO> queryKlineData(KlineQueryRequest request) {
        // 参数验证
        if (!StringUtils.hasText(request.getSymbol())) {
            throw new IllegalArgumentException("交易品种不能为空");
        }
        if (!StringUtils.hasText(request.getTimeframe())) {
            throw new IllegalArgumentException("时间周期不能为空");
        }

        List<MarketKline> klines;

        // 根据查询条件获取数据
        if (StringUtils.hasText(request.getStartTime()) && StringUtils.hasText(request.getEndTime())) {
            // 时间范围查询
            LocalDateTime startTime = parseDateTime(request.getStartTime());
            LocalDateTime endTime = parseDateTime(request.getEndTime());
            klines = marketKlineMapper.selectBySymbolAndTimeRange(
                    request.getSymbol(),
                    request.getTimeframe(),
                    startTime,
                    endTime
            );
        } else {
            // 查询最新N条
            Integer limit = request.getLimit() != null ? request.getLimit() : 100;
            klines = marketKlineMapper.selectLatestN(
                    request.getSymbol(),
                    request.getTimeframe(),
                    limit
            );
            // 逆序，使其按时间正序排列
            klines = klines.stream()
                    .sorted((k1, k2) -> k1.getOpenTime().compareTo(k2.getOpenTime()))
                    .collect(Collectors.toList());
        }

        // 转换为VO
        return klines.stream().map(this::convertToKlineVO).collect(Collectors.toList());
    }

    @Override
    public List<MarketTickVO> getAllTicks() {
        List<MarketTick> ticks = marketTickMapper.selectAllTicks();
        return ticks.stream().map(this::convertToTickVO).collect(Collectors.toList());
    }

    @Override
    public MarketTickVO getTickBySymbol(String symbol) {
        MarketTick tick = marketTickMapper.selectBySymbol(symbol);
        if (tick == null) {
            return null;
        }
        return convertToTickVO(tick);
    }

    @Override
    public List<String> getAllSymbols() {
        return marketKlineMapper.selectAllSymbols();
    }

    /**
     * 转换为K线VO
     */
    private KlineVO convertToKlineVO(MarketKline kline) {
        KlineVO vo = new KlineVO();
        vo.setTime(kline.getOpenTime().atZone(ZoneId.systemDefault()).toInstant().toEpochMilli());
        vo.setOpen(kline.getOpenPrice());
        vo.setHigh(kline.getHighPrice());
        vo.setLow(kline.getLowPrice());
        vo.setClose(kline.getClosePrice());
        vo.setVolume(kline.getVolume());
        return vo;
    }

    /**
     * 转换为Tick VO
     */
    private MarketTickVO convertToTickVO(MarketTick tick) {
        MarketTickVO vo = new MarketTickVO();
        BeanUtils.copyProperties(tick, vo);
        vo.setTimestamp(tick.getTimestamp().atZone(ZoneId.systemDefault()).toInstant().toEpochMilli());

        // 计算涨跌幅（简单示例，实际应该与昨日收盘价对比）
        // 这里暂时使用 0，后续可以优化
        vo.setChangePercent(BigDecimal.ZERO);

        return vo;
    }

    /**
     * 解析日期时间字符串
     */
    private LocalDateTime parseDateTime(String dateTimeStr) {
        if (!StringUtils.hasText(dateTimeStr)) {
            return null;
        }

        try {
            // 尝试解析完整日期时间
            if (dateTimeStr.contains(":")) {
                return LocalDateTime.parse(dateTimeStr, DATE_TIME_FORMATTER);
            } else {
                // 只有日期，补充时间为00:00:00
                return LocalDateTime.parse(dateTimeStr + " 00:00:00", DATE_TIME_FORMATTER);
            }
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("日期时间格式错误，请使用 yyyy-MM-dd 或 yyyy-MM-dd HH:mm:ss 格式");
        }
    }
}
