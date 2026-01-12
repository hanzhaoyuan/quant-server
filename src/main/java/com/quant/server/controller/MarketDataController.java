package com.quant.server.controller;

import com.quant.server.common.Result;
import com.quant.server.dto.KlineQueryRequest;
import com.quant.server.service.MarketDataService;
import com.quant.server.vo.KlineVO;
import com.quant.server.vo.MarketTickVO;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

/**
 * 行情数据接口
 */
@RestController
@RequestMapping("/market")
@Api(tags = "行情数据")
public class MarketDataController {

    @Resource
    private MarketDataService marketDataService;

    /**
     * 查询K线数据
     */
    @PostMapping("/kline")
    @ApiOperation("查询K线数据")
    public Result<List<KlineVO>> queryKline(@RequestBody KlineQueryRequest request) {
        List<KlineVO> klines = marketDataService.queryKlineData(request);
        return Result.success(klines);
    }

    /**
     * 获取所有实时报价
     */
    @GetMapping("/tick/all")
    @ApiOperation("获取所有实时报价")
    public Result<List<MarketTickVO>> getAllTicks() {
        List<MarketTickVO> ticks = marketDataService.getAllTicks();
        return Result.success(ticks);
    }

    /**
     * 获取指定品种的实时报价
     */
    @GetMapping("/tick/{symbol}")
    @ApiOperation("获取指定品种的实时报价")
    public Result<MarketTickVO> getTickBySymbol(@PathVariable String symbol) {
        MarketTickVO tick = marketDataService.getTickBySymbol(symbol);
        if (tick == null) {
            return Result.error("未找到该品种的报价");
        }
        return Result.success(tick);
    }

    /**
     * 获取所有可用的交易品种
     */
    @GetMapping("/symbols")
    @ApiOperation("获取所有交易品种")
    public Result<List<String>> getAllSymbols() {
        List<String> symbols = marketDataService.getAllSymbols();
        return Result.success(symbols);
    }
}
