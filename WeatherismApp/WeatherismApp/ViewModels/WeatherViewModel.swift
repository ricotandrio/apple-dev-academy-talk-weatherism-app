//
//  WeatherViewModel.swift
//  WeatherismApp
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import Foundation

// MARK: - Weather ViewModel
@MainActor
class WeatherViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var weatherData: WeatherResponse?
    @Published var currentLocation: GeocodingResult?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var cityName = "London"
    
    // MARK: - Dependencies
    private let weatherService: WeatherServiceProtocol
    
    // MARK: - Initialization
    init(weatherService: WeatherServiceProtocol = WeatherService()) {
        self.weatherService = weatherService
    }
    
    // MARK: - Public Methods
    func searchWeather(for city: String) {
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCity.isEmpty else {
            errorMessage = "Please enter a city name"
            return
        }
        
        Task {
            await fetchWeather(for: trimmedCity)
        }
    }
    
    func searchCurrentCity() {
        searchWeather(for: cityName)
    }
    
    func refreshWeather() {
        guard let location = currentLocation else { return }
        Task {
            await fetchWeather(for: location.name)
        }
    }
    
    // MARK: - Private Methods
    private func fetchWeather(for city: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let (weather, location) = try await weatherService.fetchWeather(for: city)
            
            weatherData = weather
            currentLocation = location
        } catch {
            errorMessage = error.localizedDescription
            weatherData = nil
            currentLocation = nil
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    func weatherIconName(for weatherCode: Int) -> String {
        switch weatherCode {
        case 0: return "sun.max" // Clear sky
        case 1, 2, 3: return "cloud.sun" // Mainly clear, partly cloudy, and overcast
        case 45, 48: return "cloud.fog" // Fog and depositing rime fog
        case 51, 53, 55: return "cloud.drizzle" // Drizzle: Light, moderate, and dense intensity
        case 56, 57: return "cloud.sleet" // Freezing Drizzle: Light and dense intensity
        case 61, 63, 65: return "cloud.rain" // Rain: Slight, moderate and heavy intensity
        case 66, 67: return "cloud.sleet" // Freezing Rain: Light and heavy intensity
        case 71, 73, 75: return "cloud.snow" // Snow fall: Slight, moderate, and heavy intensity
        case 77: return "cloud.snow" // Snow grains
        case 80, 81, 82: return "cloud.heavyrain" // Rain showers: Slight, moderate, and violent
        case 85, 86: return "cloud.snow" // Snow showers slight and heavy
        case 95: return "cloud.bolt" // Thunderstorm: Slight or moderate
        case 96, 99: return "cloud.bolt.rain" // Thunderstorm with slight and heavy hail
        default: return "sun.max"
        }
    }
    
    func weatherDescription(for weatherCode: Int) -> String {
        switch weatherCode {
        case 0: return "Clear sky"
        case 1: return "Mainly clear"
        case 2: return "Partly cloudy"
        case 3: return "Overcast"
        case 45: return "Fog"
        case 48: return "Depositing rime fog"
        case 51: return "Light drizzle"
        case 53: return "Moderate drizzle"
        case 55: return "Dense drizzle"
        case 56: return "Light freezing drizzle"
        case 57: return "Dense freezing drizzle"
        case 61: return "Slight rain"
        case 63: return "Moderate rain"
        case 65: return "Heavy rain"
        case 66: return "Light freezing rain"
        case 67: return "Heavy freezing rain"
        case 71: return "Slight snow fall"
        case 73: return "Moderate snow fall"
        case 75: return "Heavy snow fall"
        case 77: return "Snow grains"
        case 80: return "Slight rain showers"
        case 81: return "Moderate rain showers"
        case 82: return "Violent rain showers"
        case 85: return "Slight snow showers"
        case 86: return "Heavy snow showers"
        case 95: return "Thunderstorm"
        case 96: return "Thunderstorm with slight hail"
        case 99: return "Thunderstorm with heavy hail"
        default: return "Unknown weather"
        }
    }
    
    // MARK: - Computed Properties
    var hasWeatherData: Bool {
        weatherData != nil
    }
    
    var hasError: Bool {
        errorMessage != nil
    }
    
    var locationDisplayName: String {
        guard let location = currentLocation else { return "Unknown" }
        return "\(location.name), \(location.country)"
    }
    
    var currentWeatherCondition: WeatherCondition {
        guard let weatherCode = weatherData?.current.weatherCode else {
            return .clear
        }
        return weatherCondition(for: weatherCode)
    }
    
    var weatherDisplayModel: WeatherDisplayModel? {
        guard let weatherData = weatherData,
              let location = currentLocation else {
            return nil
        }
        
        return WeatherDisplayModel.from(
            weatherData: weatherData,
            location: location,
            weatherIconProvider: weatherIconName,
            weatherDescriptionProvider: weatherDescription,
            weatherConditionProvider: weatherCondition
        )
    }
    
    // MARK: - Weather Condition Logic
    func weatherCondition(for weatherCode: Int) -> WeatherCondition {
        switch weatherCode {
        case 0: return .clear // Clear sky
        case 1, 2: return .partlyCloudy // Mainly clear, partly cloudy
        case 3: return .cloudy // Overcast
        case 45, 48: return .foggy // Fog
        case 51, 53, 55, 56, 57: return .drizzle // Drizzle
        case 61, 63, 65, 66, 67, 80, 81, 82: return .rainy // Rain
        case 71, 73, 75, 77, 85, 86: return .snowy // Snow
        case 95, 96, 99: return .stormy // Thunderstorm
        default: return .clear
        }
    }
}