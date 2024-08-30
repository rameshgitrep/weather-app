//
//  WeatherViewModelTests.swift
//  WeatherAppTests
//
//  Created by Ramesh Maddali on 8/28/24.
//

import Foundation
import XCTest
@testable import WeatherApp

class WeatherViewModelTests: XCTestCase {
    
    var viewModel: WeatherViewModel!
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        viewModel = WeatherViewModel(networkManager: mockNetworkManager)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkManager = nil
        super.tearDown()
    }
    
    func testFetchWeatherSuccess() {
        let weatherData = WeatherData(
            main: WeatherData.Main(temp: 20.0, tempMin: 18.0, tempMax: 22.0, feelsLike: 21.0),
            weather: [WeatherData.Weather(description: "clear sky", icon: "01d")],
            name: "New York"
        )
        mockNetworkManager.mockWeatherData = weatherData
        
        let expectation = self.expectation(description: "Weather fetch success")
        
        viewModel.onWeatherUpdate = { info, iconURL in
            XCTAssertEqual(info, "City: New York\nTemperature: 20.0°C\nMin Temperature: 18.0°C\nMax Temperature: 22.0°C\nDescription: clear sky")
            XCTAssertEqual(iconURL, "https://openweathermap.org/img/wn/01d@2x.png")
            expectation.fulfill()
        }
        
        viewModel.fetchWeather(for: "New York")
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchWeatherFailure() {
        mockNetworkManager.mockError = NSError(domain: "Network Error", code: 500, userInfo: nil)
        
        let expectation = self.expectation(description: "Weather fetch failure")
        
        viewModel.onError = { errorMessage in
            XCTAssertEqual(errorMessage, "The operation couldn’t be completed. (Network Error error 500.)")
            expectation.fulfill()
        }
        
        viewModel.fetchWeather(for: "New York")
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}

