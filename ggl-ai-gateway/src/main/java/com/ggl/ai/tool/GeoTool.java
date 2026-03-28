package com.ggl.ai.tool;

import com.ggl.ai.feign.GeoServiceClient;

import org.springframework.stereotype.Component;

import dev.langchain4j.agent.tool.P;
import dev.langchain4j.agent.tool.Tool;

@Component
public class GeoTool {

    private final GeoServiceClient geoServiceClient;

    public GeoTool(GeoServiceClient geoServiceClient) {
        this.geoServiceClient = geoServiceClient;
    }

    @Tool("根据位置查询坐标")
    public String addressToCoordinate(@P("详细的中文地址") String address) {
        System.out.println("--- [AI Agent 正在执行 GEO 转换] 地址: " + address + " ---");

        try {
            return geoServiceClient.addressToCoordinate(address);
        } catch (Exception e) {
            // TODO: handle exception
            return "抱歉，由于远程位置服务暂时不可用，无法获 " + address + " 经纬度信息。";
        }
    }
}
