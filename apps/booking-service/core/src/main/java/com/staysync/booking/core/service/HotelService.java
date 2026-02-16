package com.staysync.booking.core.service;

import com.staysync.booking.core.dto.HotelDTO;
import com.staysync.booking.database.entity.Hotel;
import com.staysync.booking.database.repository.HotelRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class HotelService {

    private final HotelRepository hotelRepository;

    @Transactional(readOnly = true)
    public List<HotelDTO> getAllHotels() {
        return hotelRepository.findAll().stream()
                .map(this::toDTO)
                .toList();
    }

    private HotelDTO toDTO(Hotel hotel) {
        return new HotelDTO(
                hotel.getId(),
                hotel.getName(),
                hotel.getAddressLine(),
                hotel.getStarRating(),
                hotel.getDescription(),
                hotel.getLatitude(),
                hotel.getLongitude(),
                hotel.getCity().getName(),
                hotel.getCity().getCountry().getName());
    }
}
