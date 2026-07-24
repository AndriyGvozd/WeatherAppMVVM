import Foundation

struct OpenMeteoResponse: Decodable, Sendable {
    let current: Current
    let daily: Daily
    let hourly: Hourly
}

struct Current: Decodable, Sendable {
    let temperature_2m: Double
    let weather_code: Int
    let wind_speed_10m: Double
}

struct Daily: Decodable, Sendable {
    let time: [String]
    let weather_code: [Int]
    let temperature_2m_max: [Double]
    let temperature_2m_min: [Double]
}

struct Hourly: Decodable, Sendable {
    let time: [String]
    let temperature_2m: [Double]
    let weather_code: [Int]
}
