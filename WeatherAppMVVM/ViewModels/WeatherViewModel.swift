
import Foundation
import MapKit

final class WeatherViewModel {
    
    private let networkService: NetworkServiceProtocol
    private let locationService: LocationServiceProtocol
    
    var onWeatherLoaded: ((Weather) -> Void)?
    var onCityFound: (([CityLocation]) -> Void)?
    var onError: ((String) -> Void)?
    
    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        locationService: LocationServiceProtocol = LocationService()
    ) {
        self.networkService = networkService
        self.locationService = locationService
    }
    
    func fetchWeather(lat: Double, lon: Double) {
        
        Task {
            do {
                
                let cityName = try await self.locationService.getCityNameFromCoordinates(lat: lat, lon: lon)
                let weather = try await networkService.fetchWeather(latitude: lat, longitude: lon, cityName: cityName)
                
                self.onWeatherLoaded?(weather)
                
            } catch {
                let message: String
                
                if let networkError = error as? ErrorCatch {
                    message = networkError.localizedDescription
                } else {
                    message = error.localizedDescription
                }
                
                self.onError?(message)
                
            }
        }
    }
    
    func setupCurrentLocation() {
        Task { [weak self] in
            guard let self else { return }
            
            let location = await self.locationService.getCurrentCoordinates()
            
            self.fetchWeather(lat: location.latitude, lon: location.longitude)
            
        }
    }
    
    func searchCity(city: String) {
        Task {
            do {
                let response = try await locationService.searchCity(q: city)
                
                var seen = Set<String>()
                
                let uniqueResults = response.results.filter { result in
                    let key = "\(result.lat)-\(result.lon)"
                    return seen.insert(key).inserted
                }
                
                let cities = uniqueResults.map { $0.toCityLocation() }
                
                self.onCityFound?(cities)
                
            } catch {
                self.onError?("Failed to find city. Please try again.")
                
            }
        }
    }
    
    func selectCity(_ city: CityLocation){
        fetchWeather(lat: city.latitude, lon: city.longitude)
    }
    
}
