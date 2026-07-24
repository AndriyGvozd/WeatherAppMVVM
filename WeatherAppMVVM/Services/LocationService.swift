import Foundation
import CoreLocation

final class LocationService: NSObject, LocationServiceProtocol {
    
    private let baseURL = "https://api.geoapify.com"
    private let manager = CLLocationManager()
    
    private var isRequestInProgress = false
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Never>?
    
    private let kyivCoordinates = CLLocationCoordinate2D(
        latitude: 50.4501,
        longitude: 30.5234
    )
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    // MARK: - Search
    
    func searchCity(q: String) async throws -> GeoCodeAPIResponse {
        
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.path = "/v1/geocode/autocomplete"
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "text", value: q),
            URLQueryItem(name: "limit", value: "5"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "type", value: "city"),
            URLQueryItem(name: "apiKey", value: AppConfig.geoapifyAPIKey)
        ]
        
        guard let url = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ErrorCatch.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw ErrorCatch.httpError(statusCode: httpResponse.statusCode)
        }
        
        guard !data.isEmpty else {
            throw ErrorCatch.noData
        }
        
        var responseModel: GeoCodeAPIResponse
        
        do {
            responseModel = try JSONDecoder().decode(GeoCodeAPIResponse.self, from: data)
        } catch {
            throw ErrorCatch.decodingError
        }
        
        return responseModel
    }
    
    // MARK: - Location
    
    func getCurrentCoordinates() async -> CLLocationCoordinate2D {
        
        let status = manager.authorizationStatus
        
        if status == .denied || status == .restricted {
            return kyivCoordinates
        }
        
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        
        if isRequestInProgress {
            return kyivCoordinates
        }
        
        isRequestInProgress = true
        
        return await withCheckedContinuation { continuation in
            
            self.continuation = continuation
            
            // timeout накинув, щоб не зависнути
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                
                self.safeResume(with: self.kyivCoordinates)
            }
            
            manager.requestLocation()
        }
    }
    
    // MARK: - Reverse
    
    func getCityNameFromCoordinates(lat: Double, lon: Double) async throws -> String {
        
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.path = "/v1/geocode/reverse"
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "apiKey", value: AppConfig.geoapifyAPIKey)
        ]
        
        guard let url = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ErrorCatch.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw ErrorCatch.httpError(statusCode: httpResponse.statusCode)
        }
        
        guard !data.isEmpty else {
            throw ErrorCatch.noData
        }
        
        let responseModel: GeoCodeAPIResponse
        
        do {
            responseModel = try JSONDecoder().decode(GeoCodeAPIResponse.self, from: data)
        } catch {
            throw ErrorCatch.decodingError
        }
        
        let cityName = try await searchCity(q: responseModel.results.first?.city ?? "Kyiv")
        
        let name = NSLocalizedString("name_from_coordinate", comment: "")
        
        return cityName.results.first?.otherNames?[name] ?? cityName.results.first?.city ?? "Unknown"
    }
    
    // MARK: - Safe Resume
    
    private func safeResume(with value: CLLocationCoordinate2D) {
        guard let continuation else { return }
        
        continuation.resume(returning: value)
        self.continuation = nil
        isRequestInProgress = false
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            safeResume(with: location.coordinate)
        } else {
            safeResume(with: kyivCoordinates)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        safeResume(with: kyivCoordinates)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        if status == .denied || status == .restricted {
            safeResume(with: kyivCoordinates)
        }
    }
}
