protocol NetworkServiceProtocol {
    func fetchWeather(
        latitude: Double,
        longitude: Double,
        cityName: String
    ) async throws -> Weather
}
