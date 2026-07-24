import Foundation

final class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Date Formatter
    private let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/Kyiv")
        return formatter
    }()
    
    private let baseURL = "https://api.open-meteo.com"
    
    func fetchWeather(latitude: Double, longitude: Double, cityName: String) async throws -> Weather {
        
        let currentVars = "temperature_2m,weather_code,wind_speed_10m"
        let dailyVars = "weather_code,temperature_2m_max,temperature_2m_min"
        let hourlyVars = "temperature_2m,weather_code"
        
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.path = "/v1/forecast"
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "hourly", value: hourlyVars),
            URLQueryItem(name: "current", value: currentVars),
            URLQueryItem(name: "daily", value: dailyVars),
            URLQueryItem(name: "timezone", value: "Europe/Kyiv")
        ]
        
        guard let url = urlComponents?.url else {
            throw ErrorCatch.invalidURL
        }
        
        // MARK: - Request
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // MARK: - Validate HTTP Response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ErrorCatch.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw ErrorCatch.httpError(statusCode: httpResponse.statusCode)
        }
        
        guard !data.isEmpty else {
            throw ErrorCatch.noData
        }
        
        // MARK: - Decode
        let decoder = JSONDecoder()
        
        let responseModel: OpenMeteoResponse
        do {
            responseModel = try decoder.decode(OpenMeteoResponse.self, from: data)
        } catch {
            throw ErrorCatch.decodingError
        }
        
        // MARK: - Daily Forecast
        let daily = responseModel.daily.time.enumerated().map { index, date in
            DailyForecast(
                date: formatDay(from: date),
                minTemp: responseModel.daily.temperature_2m_min[index],
                maxTemp: responseModel.daily.temperature_2m_max[index],
                weatherCode: responseModel.daily.weather_code[index],
                icon: WeatherService.mapWeatherIcon(responseModel.daily.weather_code[index])
            )
        }
        
        // MARK: - Hourly Forecast from current hour
        let startIndex = currentHourIndex(from: responseModel.hourly.time) ?? 0
        
        let hourly = responseModel.hourly.time.enumerated()
            .dropFirst(startIndex)
            .map { index, time in
                HourlyForecast(
                    time: formatTime(from: time),
                    temp: responseModel.hourly.temperature_2m[index],
                    weatherCode: responseModel.hourly.weather_code[index],
                    icon: WeatherService.mapWeatherIcon(responseModel.hourly.weather_code[index])
                )
            }
        
        // MARK: - Weather Model
        return Weather(
            cityName: cityName,
            currentTemp: responseModel.current.temperature_2m,
            minTemp: responseModel.daily.temperature_2m_min.first ?? responseModel.current.temperature_2m,
            maxTemp: responseModel.daily.temperature_2m_max.first ?? responseModel.current.temperature_2m,
            description: WeatherService.mapWeatherCode(responseModel.current.weather_code),
            icon: WeatherService.mapWeatherIcon(responseModel.current.weather_code),
            windSpeed: responseModel.current.wind_speed_10m,
            dailyForecasts: daily,
            hourlyForecasts: hourly
        )
    }
}

// MARK: - Private Helpers
private extension NetworkService {
    
    func formatDay(from string: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: string) else { return "" }
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return String(localized: "forecast_today")
        }
        
        if calendar.isDateInTomorrow(date) {
            return String(localized: "forecast_tomorrow")
        }
        
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).capitalized
    }
    
    func formatTime(from string: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        
        let now = Date()
        let calendar = Calendar.current
        
        guard let date = formatter.date(from: string) else { return "" }
        
        if let forecastDate = apiDateFormatter.date(from: string),
           calendar.isDate(forecastDate, equalTo: now, toGranularity: .hour) {
            return String(localized: "hourly_now")
        } else {
            formatter.dateFormat = "HH"
            return formatter.string(from: date)
        }
    }
    
    func currentHourIndex(from times: [String]) -> Int? {
        let calendar = Calendar.current
        let now = Date()
        
        return times.firstIndex {
            guard let date = apiDateFormatter.date(from: $0) else { return false }
            return calendar.isDate(date, equalTo: now, toGranularity: .hour) || date > now
        }
    }
}
