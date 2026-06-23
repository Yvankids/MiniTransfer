package com.minitransfer.backend.service;

import com.minitransfer.backend.dto.TransferRequest;
import com.minitransfer.backend.model.Transaction;
import com.minitransfer.backend.model.User;
import com.minitransfer.backend.repository.TransactionRepository;
import com.minitransfer.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class TransferService {

    private final UserRepository userRepository;
    private final TransactionRepository transactionRepository;
    private final MongoTemplate mongoTemplate;

    public Transaction transfer(TransferRequest request) {

        // 1. Validate amount
        if (request.getAmount() <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }

        // 2. Load sender and receiver
        User sender = userRepository.findByEmail(request.getSenderEmail())
                .orElseThrow(() -> new RuntimeException("Sender not found"));

        User receiver = userRepository.findByEmail(request.getReceiverEmail())
                .orElseThrow(() -> new RuntimeException("Receiver not found"));

        // 3. Prevent self-transfer
        if (sender.getId().equals(receiver.getId())) {
            throw new IllegalArgumentException("Cannot transfer to yourself");
        }

        // 4. Check balance
        if (sender.getBalance() < request.getAmount()) {
            throw new RuntimeException("Insufficient balance");
        }

        // 5. Update balances directly in MongoDB — no full document reload
        mongoTemplate.updateFirst(
                Query.query(Criteria.where("_id").is(sender.getId())),
                new Update().inc("balance", -request.getAmount()),
                User.class
        );

        mongoTemplate.updateFirst(
                Query.query(Criteria.where("_id").is(receiver.getId())),
                new Update().inc("balance", request.getAmount()),
                User.class
        );

        // 6. Save and return transaction record
        Transaction transaction = Transaction.builder()
                .senderId(sender.getId())
                .receiverId(receiver.getId())
                .amount(request.getAmount())
                .status("SUCCESS")
                .createdAt(LocalDateTime.now())
                .build();

        return transactionRepository.save(transaction);
    }
}