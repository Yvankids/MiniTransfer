package com.minitransfer.backend.controller;


import com.minitransfer.backend.dto.TransactionResponse;
import com.minitransfer.backend.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/transactions")
@RequiredArgsConstructor
public class TransactionController {

    private final TransactionRepository transactionRepository;

    @GetMapping("/{userId}")
    public ResponseEntity<List<TransactionResponse>> getHistory(@PathVariable String userId) {

        List<TransactionResponse> history = transactionRepository
                .findBySenderIdOrReceiverIdOrderByCreatedAtDesc(userId, userId)
                .stream()
                .map(TransactionResponse::from)
                .collect(Collectors.toList());

        return ResponseEntity.ok(history);
    }
}