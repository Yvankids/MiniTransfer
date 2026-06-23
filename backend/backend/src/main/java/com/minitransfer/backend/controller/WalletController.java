package com.minitransfer.backend.controller;

import com.minitransfer.backend.dto.BalanceResponse;
import com.minitransfer.backend.service.WalletService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/wallet")
@RequiredArgsConstructor
public class WalletController {

    private final WalletService walletService;

    @GetMapping("/balance")
    public BalanceResponse getBalance(
            @RequestParam String email
    ) {
        return walletService.getBalance(email);
    }
}
