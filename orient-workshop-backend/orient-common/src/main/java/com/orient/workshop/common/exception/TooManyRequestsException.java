package com.orient.workshop.common.exception;

public class TooManyRequestsException extends AppException {
    public TooManyRequestsException(String message) {
        super(429, message);
    }
}
