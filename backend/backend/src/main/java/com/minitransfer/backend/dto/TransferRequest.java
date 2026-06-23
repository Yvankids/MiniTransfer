package com.minitransfer.backend.dto;

import lombok.Data;

@Data
public class TransferRequest {
    private String senderEmail;
    private String receiverEmail;
    private Long amount;
}