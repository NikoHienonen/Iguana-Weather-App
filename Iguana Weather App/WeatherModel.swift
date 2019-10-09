//
//  WeatherModel.swift
//  Iguana Weather App
//
//  Created by Niko Hienonen on 04/10/2019.
//  Copyright © 2019 Niko Hienonen. All rights reserved.
//

import Foundation;
import UIKit;

struct WeatherJson: Codable{
    var main: Main;
    var weather: Array<Weather>;
    var sys: Sys;
    var name: String;
}

struct Main: Codable {
    var temp: Double;
}
struct Weather: Codable {
    var id: Int;
    var main: String;
    var description: String;
    var icon: String;
}
struct Sys: Codable {
    var country: String;
}

class WeatherModel {
    var city: String?;
    var country: String?;
    var temperature: Double?;
    var description: String?;
    var icon: String?;
    var lon: Double?;
    var lat: Double?;
    var icons: [UIImage]?;
    
    func getUrl() -> URL?{
        let url: URL? = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(self.lat ?? 61.4978)&lon=\(self.lon ?? 23.7610)&appid=30701f8ebf7c4b28740f8d8576766539");
        return url;
    }
    func getIconUrl() -> URL? {
        let url = URL(string: "http://openweathermap.org/img/wn/\(icon!)@2x.png")!;
        return url;
    }
}
