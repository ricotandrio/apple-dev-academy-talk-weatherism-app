//
//  WeatherView.swift
//  WeatherismApp
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import SwiftUI

// MARK: - Weather View
struct WeatherView: View {
    let displayModel: WeatherDisplayModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Location
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.white)
                Text(displayModel.locationName)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            // Weather icon and description
            VStack(spacing: 10) {
                Image(systemName: displayModel.weatherIconName)
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text(displayModel.weatherDescription)
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            // Temperature
            VStack(spacing: 5) {
                Text(displayModel.currentTemperature)
                    .font(.system(size: 72, weight: .thin))
                    .foregroundColor(.white)
                
                Text(displayModel.feelsLikeTemperature)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Weather details
            HStack(spacing: 20) {
                WeatherDetailView(
                    icon: "thermometer.low",
                    title: "Min",
                    value: displayModel.minTemperature
                )
                
                WeatherDetailView(
                    icon: "thermometer.high",
                    title: "Max",
                    value: displayModel.maxTemperature
                )
                
                WeatherDetailView(
                    icon: "humidity",
                    title: "Humidity",
                    value: displayModel.humidity
                )
                
                WeatherDetailView(
                    icon: "wind",
                    title: "Wind",
                    value: displayModel.windSpeed
                )
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
        }
        .padding()
    }
}

// MARK: - Weather Detail View
struct WeatherDetailView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Preview
#Preview("Sunny Weather") {
    let sunnyDisplayModel = WeatherDisplayModel(
        locationName: "London, United Kingdom",
        weatherIconName: "sun.max",
        weatherDescription: "Clear sky",
        currentTemperature: "23°C",
        feelsLikeTemperature: "Feels like 24°C",
        minTemperature: "18°C",
        maxTemperature: "25°C",
        humidity: "65%",
        windSpeed: "10.5 km/h",
        weatherCondition: .clear
    )
    
    WeatherView(displayModel: sunnyDisplayModel)
        .background(WeatherCondition.clear.backgroundGradient)
}

#Preview("Rainy Weather") {
    let rainyDisplayModel = WeatherDisplayModel(
        locationName: "London, United Kingdom",
        weatherIconName: "cloud.rain",
        weatherDescription: "Slight rain",
        currentTemperature: "15°C",
        feelsLikeTemperature: "Feels like 13°C",
        minTemperature: "12°C",
        maxTemperature: "18°C",
        humidity: "85%",
        windSpeed: "15.0 km/h",
        weatherCondition: .rainy
    )
    
    WeatherView(displayModel: rainyDisplayModel)
        .background(WeatherCondition.rainy.backgroundGradient)
}

#Preview("Snowy Weather") {
    let snowyDisplayModel = WeatherDisplayModel(
        locationName: "London, United Kingdom",
        weatherIconName: "cloud.snow",
        weatherDescription: "Slight snow fall",
        currentTemperature: "-2°C",
        feelsLikeTemperature: "Feels like -5°C",
        minTemperature: "-5°C",
        maxTemperature: "1°C",
        humidity: "90%",
        windSpeed: "20.0 km/h",
        weatherCondition: .snowy
    )
    
    WeatherView(displayModel: snowyDisplayModel)
        .background(WeatherCondition.snowy.backgroundGradient)
}