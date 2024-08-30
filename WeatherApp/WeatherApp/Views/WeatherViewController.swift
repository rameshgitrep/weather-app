//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Ramesh Maddali on 8/28/24.
//
import UIKit
import CoreLocation

class WeatherViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    // UI Elements
    let searchBar = UISearchBar()
    let weatherInfoLabel = UILabel()
    let weatherIconImageView = UIImageView()
    
    // Location Manager
    let locationManager = CLLocationManager()
    
    // ViewModel
    let viewModel: WeatherViewModel
    
    init(networkManager: NetworkManagerProtocol = NetworkManager(),
         viewModel: WeatherViewModel? = nil) {
        self.viewModel = viewModel ?? WeatherViewModel(networkManager: networkManager)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        checkLocationAuthorizationStatus()
        loadLastSearchedCity()
    }
    
    func setupUI() {
        // Configure the search bar
        searchBar.placeholder = "Enter city"
        searchBar.delegate = self
        //navigationItem.titleView = searchBar
        
        view.addSubview(searchBar)
        // Configure the weather label
        weatherInfoLabel.textAlignment = .center
        weatherInfoLabel.numberOfLines = 0
        weatherInfoLabel.font = UIFont.systemFont(ofSize: 18)
        view.addSubview(weatherInfoLabel)
        
        // Configure the weather icon
        weatherIconImageView.contentMode = .scaleAspectFit
        view.addSubview(weatherIconImageView)
        
        // Layout the UI elements
        setupLayout()
    }
    
    func setupLayout() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        weatherInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherIconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Constrain search bar to top of safe area
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Constrain weather icon image view
            weatherIconImageView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            weatherIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherIconImageView.widthAnchor.constraint(equalToConstant: 100),
            weatherIconImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Constrain weather info label
            weatherInfoLabel.topAnchor.constraint(equalTo: weatherIconImageView.bottomAnchor, constant: 20),
            weatherInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            weatherInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            weatherInfoLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func setupBindings() {
        viewModel.onWeatherUpdate = { [weak self] weatherInfo, iconURL in
            self?.weatherInfoLabel.text = weatherInfo
            if let iconURL = iconURL {
                self?.loadImage(from: iconURL)
            }
        }
    }
    
    func loadLastSearchedCity() {
        let lastCity = UserDefaults.standard.string(forKey: "lastCity") ?? "Dallas"
        searchBar.text = lastCity
        fetchWeather(for: lastCity)
    }
    
    func checkLocationAuthorizationStatus() {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.requestLocation()
        }
    }
    
    func fetchWeather(for city: String) {
        viewModel.fetchWeather(for: city)
        UserDefaults.standard.set(city, forKey: "lastCity")
    }
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.weatherIconImageView.image = image
            }
        }.resume()
    }
    
    // UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let city = searchBar.text, !city.isEmpty {
            fetchWeather(for: city)
        }
    }
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        // Reverse geocoding to get city name from coordinates is required here
        // You can use CLGeocoder to get city name
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error)")
    }
}

