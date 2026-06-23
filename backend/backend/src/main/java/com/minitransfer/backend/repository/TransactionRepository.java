package com.minitransfer.backend.repository;

import com.minitransfer.backend.model.Transaction;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface TransactionRepository extends MongoRepository<Transaction, String> {

    List<Transaction> findBySenderIdOrReceiverIdOrderByCreatedAtDesc(String senderId, String receiverId);

    List<Transaction> findBySenderIdOrderByCreatedAtDesc(String senderId);

    List<Transaction> findByReceiverIdOrderByCreatedAtDesc(String receiverId);
}