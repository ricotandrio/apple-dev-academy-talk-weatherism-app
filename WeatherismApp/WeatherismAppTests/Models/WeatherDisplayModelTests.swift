//
//  WeatherDisplayModelTests.swift
//  WeatherismAppTests
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import XCTest
@testable import WeatherismApp

final class WeatherDisplayModelTests: XCTestCase {
    
    // MARK: - Test Display Model Creation
    func testDisplayModelCreation() {
        // Given
        let weatherData = TestDataFactory.createMockWeatherResponse()
        let location = TestDataFactory.createMockGeocodingResult()
        
        let weatherIconProvider: (Int) -> String = { code in
            switch code {
            case 0: return "sun.max"
            default: return "cloud.sun"
            }
        }
        
        let weatherDescriptionProvider: (Int) -> String = { code in
            switch code {
            case 0: return "Clear sky"
            default: return "Unknown"
            }
        }
        
        let weatherConditionProvider: (Int) -> WeatherCondition = { code in
            switch code {
            case 0: return .clear
            default: return .partlyCloudy
            }
        }
        
        // When
        let displayModel = WeatherDisplayModel.from(
            weatherData: weatherData,
            location: location,
            weatherIconProvider: weatherIconProvider,
            weatherDescriptionProvider: weatherDescriptionProvider,
            weatherConditionProvider: weatherConditionProvider
        )
        
        // Then
        XCTAssertEqual(displayModel.locationName, "London, United Kingdom")
        XCTAssertEqual(displayModel.weatherIconName, "sun.max")
        XCTAssertEqual(displayModel.weatherDescription, "Clear sky")
        XCTAssertEqual(displayModel.currentTemperature, "23°C") // 22.5 rounded to 23
        XCTAssertEqual(displayModel.feelsLikeTemperature, "Feels like 24°C")
        XCTAssertEqual(displayModel.minTemperature, "18°C")
        XCTAssertEqual(displayModel.maxTemperature, "25°C")
        XCTAssertEqual(displayModel.humidity, "65%")
        XCTAssertEqual(displayModel.windSpeed, "10.5 km/h")
        XCTAssertEqual(displayModel.weatherCondition, .clear)
    }
    
    func testDisplayModelWithRainyWeather() {
        // Given
        let weatherData = TestDataFactory.createRainyWeatherResponse()
        let location = TestDataFactory.createMockGeocodingResult()
        
        let weatherIconProvider: (Int) -> String = { code in
            switch code {
            case 61: return "cloud.rain"
            default: return "sun.max"
            }
        }
        
        let weatherDescriptionProvider: (Int) -> String = { code in
            switch code {
            case 61: return "Slight rain"
            default: return "Clear sky"
            }
        }
        
        let weatherConditionProvider: (Int) -> WeatherCondition = { code in
            switch code {
            case 61: return .rainy
            default: return .clear
            }
        }
        
        // When
        let displayModel = WeatherDisplayModel.from(
            weatherData: weatherData,
            location: location,
            weatherIconProvider: weatherIconProvider,
            weatherDescriptionProvider: weatherDescriptionProvider,
            weatherConditionProvider: weatherConditionProvider
        )
        
        // Then
        XCTAssertEqual(displayModel.locationName, "London, United Kingdom")
        XCTAssertEqual(displayModel.weatherIconName, "cloud.rain")
        XCTAssertEqual(displayModel.weatherDescription, "Slight rain")
        XCTAssertEqual(displayModel.currentTemperature, "15°C")
        XCTAssertEqual(displayModel.feelsLikeTemperature, "Feels like 13°C")
        XCTAssertEqual(displayModel.minTemperature, "12°C")
        XCTAssertEqual(displayModel.maxTemperature, "18°C")
        XCTAssertEqual(displayModel.humidity, "85%")
        XCTAssertEqual(displayModel.windSpeed, "15.0 km/h")
        XCTAssertEqual(displayModel.weatherCondition, .rainy)
    }
    
    func testDisplayModelWithEdgeCaseTemperatures() {
        // Given
        let weatherData = WeatherResponse(
            current: CurrentWeather(
                time: "2024-01-01T12:00",
                temperature2m: -0.6, // Should round to -1
                relativeHumidity2m: 95,
                apparentTemperature: -2.4, // Should round to -2
                windSpeed10m: 25.7,
                windDirection10m: 90.0,
                weatherCode: 71
            ),
            daily: DailyWeather(
                time: ["2024-01-01"],
                temperature2mMax: [0.4], // Should round to 0
                temperature2mMin: [-5.8] // Should round to -6
            ),
            hourly: HourlyWeather(
                time: ["2024-01-01T12:00"],
                temperature2m: [-0.6]
            )
        )
        let location = TestDataFactory.createMockGeocodingResult()
        
        let weatherIconProvider: (Int) -> String = { _ in "cloud.snow" }
        let weatherDescriptionProvider: (Int) -> String = { _ in "Snow" }
        let weatherConditionProvider: (Int) -> WeatherCondition = { _ in .snowy }
        
        // When
        let displayModel = WeatherDisplayModel.from(
            weatherData: weatherData,
            location: location,
            weatherIconProvider: weatherIconProvider,
            weatherDescriptionProvider: weatherDescriptionProvider,
            weatherConditionProvider: weatherConditionProvider
        )
        
        // Then
        XCTAssertEqual(displayModel.currentTemperature, "-1°C")
        XCTAssertEqual(displayModel.feelsLikeTemperature, "Feels like -2°C")
        XCTAssertEqual(displayModel.minTemperature, "-6°C")
        XCTAssertEqual(displayModel.maxTemperature, "0°C")
        XCTAssertEqual(displayModel.windSpeed, "25.7 km/h")
    }
}