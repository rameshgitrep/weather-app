//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Ramesh Maddali on 8/28/24.
//

import Foundation

class WeatherViewModel {
    
    var onWeatherUpdate: ((String, String?) -> Void)?
    var onError: ((String) -> Void)?
    
    private var networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchWeather(for city: String) {
        // URL encode the city name
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            DispatchQueue.main.async {
                self.onWeatherUpdate?("Error: Invalid city name", nil)
            }
            return
        }
        
        networkManager.fetchWeather(for: encodedCity) { [weak self] result in
            switch result {
            case .success(let weatherData):
                let temperature = weatherData.main.temp
                let tempMin = weatherData.main.tempMin
                let tempMax = weatherData.main.tempMax
                let description = weatherData.weather.first?.description ?? "No description"
                let iconCode = weatherData.weather.first?.icon ?? "01d" // default to clear sky icon if missing
                let iconURL = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
                
                let weatherInfo = """
                City: \(weatherData.name)
                Temperature: \(String(format: "%.1f", temperature))°C
                Min Temperature: \(String(format: "%.1f", tempMin))°C
                Max Temperature: \(String(format: "%.1f", tempMax))°C
                Description: \(description)
                """
                
                DispatchQueue.main.async {
                    self?.onWeatherUpdate?(weatherInfo, iconURL)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
}



