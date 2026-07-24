import Foundation
struct GeoCode: Decodable, Sendable {
    
    let country: String
    let state: String?
    var city: String
    
    let lon: Double
    let lat: Double
    
    let otherNames: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case country
        case state
        case city
        case lon
        case lat
    
        case otherNames = "other_names"
    }
}

struct GeoCodeAPIResponse: Decodable, Sendable {
    let results: [GeoCode]
}

struct CityLocation: Sendable {
    var name: String
    let state: String?
    let country: String
    let latitude: Double
    let longitude: Double
}

extension GeoCode {
    
    func toCityLocation() -> CityLocation {
        
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        
        let localizedName =
        otherNames?["name:\(languageCode)"] ??
        city
        
        return CityLocation(
            name: localizedName,
            state: state,
            country: country,
            latitude: lat,
            longitude: lon
        )
    }
}
