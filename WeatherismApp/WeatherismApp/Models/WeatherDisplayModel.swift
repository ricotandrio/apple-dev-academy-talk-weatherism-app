//
//  WeatherDisplayModel.swift
//  WeatherismApp
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import Foundation

// MARK: - Weather Display Model
struct WeatherDisplayModel {
    let locationName: String
    let weatherIconName: String
    let weatherDescription: String
    let currentTemperature: String
    let feelsLikeTemperature: String
    let minTemperature: String
    let maxTemperature: String
    let humidity: String
    let windSpeed: String
    let weatherCondition: WeatherCondition
}

// MARK: - Weather Display Model Factory
extension WeatherDisplayModel {
    static func from(
        weatherData: WeatherResponse,
        location: GeocodingResult,
        weatherIconProvider: (Int) -> String,
        weatherDescriptionProvider: (Int) -> String,
        weatherConditionProvider: (Int) -> WeatherCondition
    ) -> WeatherDisplayModel {
        let current = weatherData.current
        let daily = weatherData.daily
        
        return WeatherDisplayModel(
            locationName: "\(location.name), \(location.country)",
            weatherIconName: weatherIconProvider(current.weatherCode),
            weatherDescription: weatherDescriptionProvider(current.weatherCode),
            currentTemperature: "\(Int(current.temperature2m))°C",
            feelsLikeTemperature: "Feels like \(Int(current.apparentTemperature))°C",
            minTemperature: "\(Int(daily.temperature2mMin.first ?? 0))°C",
            maxTemperature: "\(Int(daily.temperature2mMax.first ?? 0))°C",
            humidity: "\(current.relativeHumidity2m)%",
            windSpeed: "\(String(format: "%.1f", current.windSpeed10m)) km/h",
            weatherCondition: weatherConditionProvider(current.weatherCode)
        )
    }
}