
struct Weather {
    let cityName: String
    let currentTemp: Double
    let minTemp: Double
    let maxTemp: Double
    let description: String
    let icon: String
    let windSpeed: Double
    
    let dailyForecasts: [DailyForecast]
    let hourlyForecasts: [HourlyForecast]
}

struct DailyForecast {
    var date: String
    let minTemp: Double
    let maxTemp: Double
    let weatherCode: Int
    let icon: String
}

struct HourlyForecast {
    var time: String
    let temp: Double
    let weatherCode: Int
    let icon: String
}

