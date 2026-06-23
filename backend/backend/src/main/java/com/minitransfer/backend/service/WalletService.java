package com.minitransfer.backend.service;

import com.minitransfer.backend.dto.BalanceResponse;
import com.minitransfer.backend.model.User;
import com.minitransfer.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class WalletService {

    private final UserRepository userRepository;

    // Used by WalletController — lookup by email
    public BalanceResponse getBalance(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return new BalanceResponse(user.getBalance());
    }

    // Used internally — lookup by id
    public BalanceResponse getBalanceById(String userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return new BalanceResponse(user.getBalance());
    }
}
