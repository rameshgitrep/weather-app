//
//  WeatherViewControllerTests.swift
//  WeatherAppTests
//
//  Created by Ramesh Maddali on 8/28/24.
//

import XCTest
@testable import WeatherApp

class WeatherViewControllerTests: XCTestCase {
    
    var viewController: WeatherViewController!
    var viewModel: MockWeatherViewModel!
    
    override func setUp() {
        super.setUp()
        let networkManager: NetworkManager = NetworkManager()
        viewModel = MockWeatherViewModel(networkManager: networkManager)
        viewController = WeatherViewController(viewModel: viewModel)
        viewController.loadViewIfNeeded() // Load the view hierarchy
    }
    
    override func tearDown() {
        viewController = nil
        viewModel = nil
        super.tearDown()
    }
    
    // Test UI elements setup
    func testUIElements() {
        XCTAssertNotNil(viewController.searchBar, "Search bar should be initialized")
        XCTAssertNotNil(viewController.weatherInfoLabel, "Weather info label should be initialized")
        XCTAssertNotNil(viewController.weatherIconImageView, "Weather icon image view should be initialized")
    }
    
    // Test if weather info is updated correctly
    func testWeatherInfoUpdate() {
        let expectation = self.expectation(description: "Weather info updated")
        
        viewModel.weatherInfo = "Temperature: 25°C"
        viewModel.iconURL = "http://openweathermap.org/img/wn/01d@2x.png"
        
        viewModel.onWeatherUpdate = { info, iconURL in
            XCTAssertEqual(info, "Temperature: 25°C", "Weather info should be updated")
            XCTAssertEqual(iconURL, "http://openweathermap.org/img/wn/01d@2x.png", "Icon URL should be updated")
            expectation.fulfill()
        }
        
        viewModel.fetchWeather(for: "New York")
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Test search functionality
    func testSearchFunctionality() {
        let searchText = "New York"
        viewController.searchBar.text = searchText
        viewController.searchBarSearchButtonClicked(viewController.searchBar)
        if let viewModel = viewModel {
            XCTAssertTrue(viewModel.searchCityCalled, "Search city should be called with correct parameters")
            XCTAssertEqual(viewModel.searchedCity, searchText, "Searched city should match the search bar text")
        }
    }
    
    // Mock ViewModel to use for testing
    class MockWeatherViewModel: WeatherViewModel {
        var searchedCity: String?
        var searchCityCalled = false
        var weatherInfo: String?
        var iconURL: String?
        
        override func fetchWeather(for city: String) {
            searchedCity = city
            searchCityCalled = true
            onWeatherUpdate?(weatherInfo ?? "", iconURL)
        }
    }
}
