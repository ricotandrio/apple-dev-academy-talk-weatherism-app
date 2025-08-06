//
//  WeatherViewModelTests.swift
//  WeatherismAppTests
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import XCTest
@testable import WeatherismApp

@MainActor
final class WeatherViewModelTests: XCTestCase {
    
    // MARK: - Properties
    var viewModel: WeatherViewModel!
    var mockService: MockWeatherService!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockService = MockWeatherService()
        viewModel = WeatherViewModel(weatherService: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    func testInitialState() {
        XCTAssertNil(viewModel.weatherData)
        XCTAssertNil(viewModel.currentLocation)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.hasWeatherData)
        XCTAssertFalse(viewModel.hasError)
        XCTAssertEqual(viewModel.locationDisplayName, "Unknown")
        XCTAssertEqual(viewModel.cityName, "London") // New test for cityName
        XCTAssertNil(viewModel.weatherDisplayModel) // New test for display model
    }
    
    // MARK: - Search Weather Tests
    func testSearchWeatherSuccess() async {
        // Given
        mockService.setupSuccessResponse()
        let city = "London"
        
        // When
        let expectation = expectation(description: "Weather search completed")
        viewModel.searchWeather(for: city)
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertNotNil(viewModel.weatherData)
        XCTAssertNotNil(viewModel.currentLocation)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.hasWeatherData)
        XCTAssertFalse(viewModel.hasError)
        XCTAssertEqual(mockService.fetchWeatherCallCount, 1)
        XCTAssertEqual(mockService.lastSearchedCity, city)
        XCTAssertEqual(viewModel.locationDisplayName, "London, United Kingdom")
    }
    
    func testSearchWeatherFailure() async {
        // Given
        mockService.shouldThrowError = true
        mockService.errorToThrow = NetworkError.cityNotFound
        let city = "InvalidCity"
        
        // When
        let expectation = expectation(description: "Weather search failed")
        viewModel.searchWeather(for: city)
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertNil(viewModel.weatherData)
        XCTAssertNil(viewModel.currentLocation)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.hasWeatherData)
        XCTAssertTrue(viewModel.hasError)
        XCTAssertEqual(mockService.fetchWeatherCallCount, 1)
        XCTAssertEqual(viewModel.errorMessage, "City not found. Please check the spelling and try again.")
    }
    
    func testSearchWeatherEmptyCity() {
        // When
        viewModel.searchWeather(for: "")
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Please enter a city name")
        XCTAssertEqual(mockService.fetchWeatherCallCount, 0)
    }
    
    func testSearchWeatherWhitespaceCity() {
        // When
        viewModel.searchWeather(for: "   ")
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Please enter a city name")
        XCTAssertEqual(mockService.fetchWeatherCallCount, 0)
    }
    
    func testSearchCurrentCity() async {
        // Given
        mockService.setupSuccessResponse()
        viewModel.cityName = "Paris"
        
        // When
        let expectation = expectation(description: "Current city search completed")
        viewModel.searchCurrentCity()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(mockService.lastSearchedCity, "Paris")
        XCTAssertEqual(mockService.fetchWeatherCallCount, 1)
        XCTAssertTrue(viewModel.hasWeatherData)
    }
    
    func testSearchCurrentCityWithEmptyName() {
        // Given
        viewModel.cityName = ""
        
        // When
        viewModel.searchCurrentCity()
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Please enter a city name")
        XCTAssertEqual(mockService.fetchWeatherCallCount, 0)
    }
    
    func testCityNameStateManagement() {
        // Given
        let newCityName = "Tokyo"
        
        // When
        viewModel.cityName = newCityName
        
        // Then
        XCTAssertEqual(viewModel.cityName, newCityName)
    }
    
    func testSearchWeatherTrimsWhitespace() async {
        // Given
        mockService.setupSuccessResponse()
        let cityWithWhitespace = "  London  "
        
        // When
        let expectation = expectation(description: "Weather search completed")
        viewModel.searchWeather(for: cityWithWhitespace)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(mockService.lastSearchedCity, "London")
    }
    
    // MARK: - Search Current City Tests
    func testSearchCurrentCity() async {
        // Given
        mockService.setupSuccessResponse()
        viewModel.cityName = "Paris"
        
        // When
        let expectation = expectation(description: "Current city search completed")
        viewModel.searchCurrentCity()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(mockService.lastSearchedCity, "Paris")
        XCTAssertEqual(mockService.fetchWeatherCallCount, 1)
        XCTAssertTrue(viewModel.hasWeatherData)
    }
    
    func testSearchCurrentCityWithEmptyName() {
        // Given
        viewModel.cityName = ""
        
        // When
        viewModel.searchCurrentCity()
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Please enter a city name")
        XCTAssertEqual(mockService.fetchWeatherCallCount, 0)
    }
    
    func testCityNameStateManagement() {
        // Given
        let newCityName = "Tokyo"
        
        // When
        viewModel.cityName = newCityName
        
        // Then
        XCTAssertEqual(viewModel.cityName, newCityName)
    }
    }
    
    // MARK: - Refresh Weather Tests
    func testRefreshWeatherWithLocation() async {
        // Given
        mockService.setupSuccessResponse()
        viewModel.searchWeather(for: "London")
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Reset call count
        mockService.fetchWeatherCallCount = 0
        
        // When
        let expectation = expectation(description: "Weather refresh completed")
        viewModel.refreshWeather()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(mockService.fetchWeatherCallCount, 1)
        XCTAssertEqual(mockService.lastSearchedCity, "London")
    }
    
    func testRefreshWeatherWithoutLocation() {
        // When
        viewModel.refreshWeather()
        
        // Then
        XCTAssertEqual(mockService.fetchWeatherCallCount, 0)
    }
    
    // MARK: - Weather Icon Tests
    func testWeatherIconName() {
        // Test various weather codes
        XCTAssertEqual(viewModel.weatherIconName(for: 0), "sun.max") // Clear sky
        XCTAssertEqual(viewModel.weatherIconName(for: 1), "cloud.sun") // Mainly clear
        XCTAssertEqual(viewModel.weatherIconName(for: 45), "cloud.fog") // Fog
        XCTAssertEqual(viewModel.weatherIconName(for: 61), "cloud.rain") // Rain
        XCTAssertEqual(viewModel.weatherIconName(for: 71), "cloud.snow") // Snow
        XCTAssertEqual(viewModel.weatherIconName(for: 95), "cloud.bolt") // Thunderstorm
        XCTAssertEqual(viewModel.weatherIconName(for: 999), "sun.max") // Unknown code
    }
    
    // MARK: - Weather Description Tests
    func testWeatherDescription() {
        // Test various weather codes
        XCTAssertEqual(viewModel.weatherDescription(for: 0), "Clear sky")
        XCTAssertEqual(viewModel.weatherDescription(for: 1), "Mainly clear")
        XCTAssertEqual(viewModel.weatherDescription(for: 45), "Fog")
        XCTAssertEqual(viewModel.weatherDescription(for: 61), "Slight rain")
        XCTAssertEqual(viewModel.weatherDescription(for: 71), "Slight snow fall")
        XCTAssertEqual(viewModel.weatherDescription(for: 95), "Thunderstorm")
        XCTAssertEqual(viewModel.weatherDescription(for: 999), "Unknown weather")
    }
    
    // MARK: - Weather Condition Tests
    func testWeatherCondition() {
        // Test weather condition mapping
        XCTAssertEqual(viewModel.weatherCondition(for: 0), .clear) // Clear sky
        XCTAssertEqual(viewModel.weatherCondition(for: 1), .partlyCloudy) // Mainly clear
        XCTAssertEqual(viewModel.weatherCondition(for: 3), .cloudy) // Overcast
        XCTAssertEqual(viewModel.weatherCondition(for: 45), .foggy) // Fog
        XCTAssertEqual(viewModel.weatherCondition(for: 55), .drizzle) // Drizzle
        XCTAssertEqual(viewModel.weatherCondition(for: 61), .rainy) // Rain
        XCTAssertEqual(viewModel.weatherCondition(for: 71), .snowy) // Snow
        XCTAssertEqual(viewModel.weatherCondition(for: 95), .stormy) // Thunderstorm
        XCTAssertEqual(viewModel.weatherCondition(for: 999), .clear) // Unknown defaults to clear
    }
    
    func testCurrentWeatherCondition() async {
        // Initially should be clear (default)
        XCTAssertEqual(viewModel.currentWeatherCondition, .clear)
        
        // After loading rainy weather
        mockService.mockWeatherResponse = TestDataFactory.createRainyWeatherResponse()
        mockService.mockGeocodingResult = TestDataFactory.createMockGeocodingResult()
        
        let expectation = expectation(description: "Weather condition update")
        viewModel.searchWeather(for: "London")
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Should now be rainy (weather code 61 from TestDataFactory.createRainyWeatherResponse)
        XCTAssertEqual(viewModel.currentWeatherCondition, .rainy)
    }
    
    // MARK: - Weather Display Model Tests
    func testWeatherDisplayModel() async {
        // Initially should be nil
        XCTAssertNil(viewModel.weatherDisplayModel)
        
        // Given
        mockService.setupSuccessResponse()
        
        // When
        let expectation = expectation(description: "Weather display model created")
        viewModel.searchWeather(for: "London")
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertNotNil(viewModel.weatherDisplayModel)
        
        let displayModel = viewModel.weatherDisplayModel!
        XCTAssertEqual(displayModel.locationName, "London, United Kingdom")
        XCTAssertEqual(displayModel.weatherIconName, "sun.max") // Weather code 0
        XCTAssertEqual(displayModel.weatherDescription, "Clear sky")
        XCTAssertEqual(displayModel.currentTemperature, "23°C") // 22.5 rounded
        XCTAssertEqual(displayModel.feelsLikeTemperature, "Feels like 24°C")
        XCTAssertEqual(displayModel.minTemperature, "18°C")
        XCTAssertEqual(displayModel.maxTemperature, "25°C")
        XCTAssertEqual(displayModel.humidity, "65%")
        XCTAssertEqual(displayModel.windSpeed, "10.5 km/h")
        XCTAssertEqual(displayModel.weatherCondition, .clear)
    }
    
    func testWeatherDisplayModelWithoutData() {
        // When no weather data
        XCTAssertNil(viewModel.weatherDisplayModel)
        
        // When only weather data without location
        viewModel.weatherData = TestDataFactory.createMockWeatherResponse()
        XCTAssertNil(viewModel.weatherDisplayModel)
        
        // When only location without weather data
        viewModel.weatherData = nil
        viewModel.currentLocation = TestDataFactory.createMockGeocodingResult()
        XCTAssertNil(viewModel.weatherDisplayModel)
    }
    
    // MARK: - Computed Properties Tests
    func testComputedProperties() async {
        // Initially no data
        XCTAssertFalse(viewModel.hasWeatherData)
        XCTAssertFalse(viewModel.hasError)
        XCTAssertEqual(viewModel.locationDisplayName, "Unknown")
        
        // After successful search
        mockService.setupSuccessResponse()
        let expectation = expectation(description: "Weather search completed")
        viewModel.searchWeather(for: "London")
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertTrue(viewModel.hasWeatherData)
        XCTAssertFalse(viewModel.hasError)
        XCTAssertEqual(viewModel.locationDisplayName, "London, United Kingdom")
    }
    
    // MARK: - Loading State Tests
    func testLoadingState() {
        // Given
        mockService.setupSuccessResponse()
        
        // Initially not loading
        XCTAssertFalse(viewModel.isLoading)
        
        // When starting search
        viewModel.searchWeather(for: "London")
        
        // Should be loading (briefly)
        // Note: In real async tests, you might need more sophisticated timing
        
        // After completion, should not be loading
        // This would be tested with proper async expectations in a real scenario
    }
    
    // MARK: - Integration Tests
    func testCompleteWeatherFlow() async {
        // Given
        mockService.setupSuccessResponse()
        
        // When
        let expectation = expectation(description: "Complete weather flow")
        viewModel.searchWeather(for: "London")
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Then verify complete state
        XCTAssertNotNil(viewModel.weatherData)
        XCTAssertEqual(viewModel.weatherData?.current.temperature2m, 22.5)
        XCTAssertEqual(viewModel.weatherData?.current.weatherCode, 0)
        XCTAssertEqual(viewModel.currentLocation?.name, "London")
        XCTAssertTrue(viewModel.hasWeatherData)
        XCTAssertFalse(viewModel.hasError)
        XCTAssertFalse(viewModel.isLoading)
    }
}