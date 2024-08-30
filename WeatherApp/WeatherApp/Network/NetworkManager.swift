//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Ramesh Maddali on 8/28/24.
//

import Foundation

protocol NetworkManagerProtocol {
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherData, Error>) -> Void)
}

class NetworkManager: NetworkManagerProtocol {
    
    private let apiKey = "a4d642cf5a2a6193e521702b7d3d33ab"
    
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                completion(.success(weatherData))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
