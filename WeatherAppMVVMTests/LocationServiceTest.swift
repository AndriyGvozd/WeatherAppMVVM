import XCTest
@testable import WeatherAppMVVM

final class LocationServiceTests: XCTestCase {
    
    func testGeoapifyResponseDecoding() throws {
        
        let data = try Bundle.loadJSONFixture(named: "geoapify_response")
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(GeoCodeAPIResponse.self, from: data)
        
        XCTAssertEqual(response.results.first?.city, "Kyiv")
        XCTAssertEqual(response.results.first?.country, "Ukraine")
        XCTAssertEqual(response.results.first?.lat, 50.4501)
        XCTAssertEqual(response.results.first?.lon, 30.5234)
    }
    
    func testCitySearchURLBuilding_WithSpacesAndUnicode() throws {
        
        let query = "Kyiv Україна"
        
        var urlComponents = URLComponents(string: "https://api.geoapify.com")
        urlComponents?.path = "/v1/geocode/autocomplete"
        urlComponents?.queryItems = [
            URLQueryItem(name: "text", value: query),
            URLQueryItem(name: "limit", value: "5")
        ]
        
        let url = try XCTUnwrap(urlComponents?.url)
        let urlString = url.absoluteString
        
        XCTAssertTrue(urlString.contains("/v1/geocode/autocomplete"))
        XCTAssertTrue(urlString.contains("limit=5"))
        
        // Перевірка що пробіл/кирилиця енкодяться
        XCTAssertFalse(urlString.contains(" "))
        XCTAssertTrue(urlString.contains("text="))
    }
}
