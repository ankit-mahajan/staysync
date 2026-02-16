package com.staysync.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@EnableJpaRepositories(basePackages = "com.staysync.booking.database.repository",
                       entityManagerFactoryRef = "entityManagerFactory")
@SpringBootApplication(scanBasePackages = {"com.staysync.app", "com.staysync.booking"})
public class BookingServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(BookingServiceApplication.class, args);
	}

}
