package com.quant.server.service;

import com.quant.server.dto.KlineQueryRequest;
import com.quant.server.vo.KlineVO;
import com.quant.server.vo.MarketTickVO;

import java.util.List;

/**
 * 行情数据服务接口
 */
public interface MarketDataService {

    /**
     * 查询K线数据
     *
     * @param request 查询请求
     * @return K线数据列表
     */
    List<KlineVO> queryKlineData(KlineQueryRequest request);

    /**
     * 获取所有实时报价
     *
     * @return 实时报价列表
     */
    List<MarketTickVO> getAllTicks();

    /**
     * 获取指定品种的实时报价
     *
     * @param symbol 交易品种
     * @return 实时报价
     */
    MarketTickVO getTickBySymbol(String symbol);

    /**
     * 获取所有可用的交易品种
     *
     * @return 品种列表
     */
    List<String> getAllSymbols();
}
