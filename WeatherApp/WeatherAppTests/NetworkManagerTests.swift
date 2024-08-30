//
//  NetworkManagerTests.swift
//  WeatherAppTests
//
//  Created by Ramesh Maddali on 8/28/24.
//

import XCTest
@testable import WeatherApp

class NetworkManagerTests: XCTestCase {
    
    var mockNetworkManager: NetworkManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = NetworkManager()
    }
    
    func testForService() {
        let expectation = self.expectation(description: "Fetch weather with spaces")
        let city = "Los Angeles"
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        mockNetworkManager.fetchWeather(for: encodedCity) { result in
            switch result {
            case .success(let weatherData):
                XCTAssertNotNil(weatherData)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Add more test cases as needed
}

class MockNetworkManager: NetworkManagerProtocol {
    var mockWeatherData: WeatherData?
    var mockError: Error?
    
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        if let error = mockError {
            completion(.failure(error))
        } else if let weatherData = mockWeatherData {
            completion(.success(weatherData))
        }
    }
}
