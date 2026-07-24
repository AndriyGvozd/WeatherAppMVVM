WeatherAppMVVM
An iOS weather app built with MVVM architecture. Shows current weather, hourly and daily forecasts. You can search for a city or use your current location.

Tech Stack
Swift 5, UIKit (programmatic UI)
MVVM — ViewController, ViewModel, Services
Open-Meteo API — weather data (no API key required)
Geoapify API — city search and geocoding
CoreLocation — current location
URLSession + async/await
Localization: uk, en
Unit tests (XCTest)
Requirements
macOS with Xcode
iOS 26.2+ (minimum deployment target in the project)
Geoapify API key
Setup
Clone the repository:

git clone <repository-url>
cd WeatherAppMVVM
Create the config file with your API key:

cp WeatherAppMVVM/Config/Config.example.xcconfig WeatherAppMVVM/Config/Config.xcconfig
Open Config.xcconfig and replace (your_api_key) with your Geoapify API key:

GEOAPIFY_API_KEY = your_key_here
Do not commit Config.xcconfig with a real API key to Git.

Run
Open WeatherAppMVVM.xcodeproj in Xcode.
Select a simulator or a connected iPhone.
Press Run (Cmd + R).
Allow location access when prompted.
