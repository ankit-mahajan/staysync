package com.staysync.booking.core.dto;

import java.math.BigDecimal;

public record HotelDTO(
        Long id,
        String name,
        String addressLine,
        Integer starRating,
        String description,
        BigDecimal latitude,
        BigDecimal longitude,
        String cityName,
        String countryName) {
}
