//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Ramesh Maddali on 8/28/24.
//

import Foundation

import Foundation

struct WeatherData: Codable {
    let main: Main
    let weather: [Weather]
    let name: String
    
    struct Main: Codable {
        let temp: Double
        let tempMin: Double
        let tempMax: Double
        let feelsLike: Double
        
        enum CodingKeys: String, CodingKey {
            case temp
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case feelsLike = "feels_like"
        }
    }
    
    struct Weather: Codable {
        let description: String
        let icon: String
    }
}
