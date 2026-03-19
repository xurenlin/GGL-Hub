package com.ggl.ai.controller;

import com.ggl.ai.service.SimpleRouterService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/ai")
@RefreshScope
public class ConfigCheckController {

    @Autowired
    private SimpleRouterService routerService;

    @GetMapping("/routeAndExecute")
    public String routeAndExecute(@RequestParam("str") String str) {
        return routerService.routeAndExecute(str);
    }
}
