struct WeatherService {
    
    // MARK: - Description (WMO)
    
    static func mapWeatherCode(_ code: Int) -> String {
        switch code {

        case 0:
            return "weather_service_clear_sky"
        case 1:
            return "weather_service_mainly_clear"
        case 2:
            return "weather_service_partly_cloudy"
        case 3:
            return "weather_service_overcast"

        case 45, 48:
            return "weather_service_fog"

        case 51:
            return "weather_service_light_drizzle"
        case 53:
            return "weather_service_moderate_drizzle"
        case 55:
            return "weather_service_dense_drizzle"

        case 56:
            return "weather_service_light_freezing_drizzle"
        case 57:
            return "weather_service_dense_freezing_drizzle"

        case 61:
            return "weather_service_slight_rain"
        case 63:
            return "weather_service_moderate_rain"
        case 65:
            return "weather_service_heavy_rain"

        case 66:
            return "weather_service_light_freezing_rain"
        case 67:
            return "weather_service_heavy_freezing_rain"

        case 71:
            return "weather_service_slight_snow_fall"
        case 73:
            return "weather_service_moderate_snow_fall"
        case 75:
            return "weather_service_heavy_snow_fall"

        case 77:
            return "weather_service_snow_grains"

        case 80:
            return "weather_service_slight_rain_showers"
        case 81:
            return "weather_service_moderate_rain_showers"
        case 82:
            return "weather_service_violent_rain_showers"

        case 85:
            return "weather_service_slight_snow_showers"
        case 86:
            return "weather_service_heavy_snow_showers"

        case 95:
            return "weather_service_thunderstorm"

        case 96, 99:
            return "weather_service_thunderstorm_with_hail"

        default:
            return "weather_service_unknown"
        }
    }
    
    // MARK: - SF Symbols Icon
    
    static func mapWeatherIcon(_ code: Int) -> String {
        switch code {
            
        case 0:
            return "sun.max.fill"
            
        case 1:
            return "sun.max"
        case 2:
            return "cloud.sun.fill"
        case 3:
            return "cloud.fill"
            
        case 45, 48:
            return "cloud.fog.fill"
            
        case 51...57:
            return "cloud.drizzle.fill"
            
        case 61...67:
            return "cloud.rain.fill"
            
        case 71...77:
            return "snow"
            
        case 80...82:
            return "cloud.heavyrain.fill"
            
        case 85, 86:
            return "cloud.snow.fill"
            
        case 95:
            return "cloud.bolt.rain.fill"
            
        case 96, 99:
            return "cloud.bolt.hail.fill"
            
        default:
            return "questionmark"
        }
    }
}
