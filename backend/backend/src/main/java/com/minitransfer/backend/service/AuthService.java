package com.minitransfer.backend.service;

import com.minitransfer.backend.dto.AuthResponse;
import com.minitransfer.backend.dto.LoginRequest;
import com.minitransfer.backend.dto.RegisterRequest;
import com.minitransfer.backend.model.User;
import com.minitransfer.backend.repository.UserRepository;
import com.minitransfer.backend.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthResponse register(RegisterRequest request) {

        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("Email already exists");
        }

        User user = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .phone(request.getPhone())
                .password(passwordEncoder.encode(request.getPassword()))
                .balance(10000L)
                .build();

        User saved = userRepository.save(user);
        String token = jwtService.generateToken(saved.getEmail());

        return new AuthResponse(token, saved.getId(), saved.getEmail());
    }

    public AuthResponse login(LoginRequest request) {

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));

        boolean validPassword = passwordEncoder.matches(
                request.getPassword(),
                user.getPassword()
        );

        if (!validPassword) {
            throw new RuntimeException("Invalid credentials");
        }

        String token = jwtService.generateToken(user.getEmail());

        return new AuthResponse(token, user.getId(), user.getEmail());
    }
}