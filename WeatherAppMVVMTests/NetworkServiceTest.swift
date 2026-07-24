import XCTest
@testable import WeatherAppMVVM

final class NetworkServiceTests: XCTestCase {
    
    func testOpenMeteoResponseDecoding() throws {
        
        let data = try Bundle.loadJSONFixture(named: "open_meteo_response")
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(OpenMeteoResponse.self, from: data)
        
        XCTAssertEqual(response.current.temperature_2m, 18.5)
        XCTAssertEqual(response.current.weather_code, 1)
        XCTAssertEqual(response.daily.time.count, 2)
        XCTAssertEqual(response.hourly.temperature_2m.first, 18.5)
    }
    
    func testWeatherURLBuilding() throws {
        
        let latitude = 50.45
        let longitude = 30.52
        
        var urlComponents = URLComponents(string: "https://api.open-meteo.com")
        urlComponents?.path = "/v1/forecast"
        urlComponents?.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)")
        ]
        
        let url = try XCTUnwrap(urlComponents?.url)
        let urlString = url.absoluteString
        
        XCTAssertTrue(urlString.contains("latitude=50.45"))
        XCTAssertTrue(urlString.contains("longitude=30.52"))
        XCTAssertTrue(urlString.contains("/v1/forecast"))
    }
}
