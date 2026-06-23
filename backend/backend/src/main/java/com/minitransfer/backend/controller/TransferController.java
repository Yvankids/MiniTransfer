package com.minitransfer.backend.controller;

import com.minitransfer.backend.dto.TransferRequest;
import com.minitransfer.backend.model.Transaction;
import com.minitransfer.backend.service.TransferService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/transfers")
@RequiredArgsConstructor
public class TransferController {

    private final TransferService transferService;

    @PostMapping
    public ResponseEntity<Transaction> transfer(@RequestBody TransferRequest request) {
        Transaction result = transferService.transfer(request);
        return ResponseEntity.ok(result);
    }
}