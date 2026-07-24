//
//  AppConfig.swift
//  WeatherAppMVVM
//
//  Created by Mac on 29.04.2026.
//

import Foundation

enum AppConfig {
    static var geoapifyAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GEOAPIFY_API_KEY") as? String,
              !key.isEmpty else {
            fatalError("GEOAPIFY_API_KEY not found")
        }
        return key
    }
}
