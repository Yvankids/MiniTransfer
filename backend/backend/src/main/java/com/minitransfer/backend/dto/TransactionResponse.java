package com.minitransfer.backend.dto;


import com.minitransfer.backend.model.Transaction;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class TransactionResponse {

    private String id;
    private String senderId;
    private String receiverId;
    private Long amount;
    private String status;
    private LocalDateTime createdAt;

    public static TransactionResponse from(Transaction t) {
        return TransactionResponse.builder()
                .id(t.getId())
                .senderId(t.getSenderId())
                .receiverId(t.getReceiverId())
                .amount(t.getAmount())
                .status(t.getStatus())
                .createdAt(t.getCreatedAt())
                .build();
    }
}