import CoreLocation

protocol LocationServiceProtocol {
    func searchCity(q: String) async throws -> (GeoCodeAPIResponse)
    func getCityNameFromCoordinates(lat: Double, lon: Double) async throws -> String
    func getCurrentCoordinates() async -> CLLocationCoordinate2D
}
