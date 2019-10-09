//
//  FirstViewController.swift
//  Iguana Weather App
//
//  Created by Niko Hienonen on 04/10/2019.
//  Copyright © 2019 Niko Hienonen. All rights reserved.
//

import UIKit;
import CoreLocation;

class FirstViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var locationManager: CLLocationManager!;
    var weatherModel: WeatherModel!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        activityView.hidesWhenStopped = true;
        activityView.startAnimating();

        self.weatherModel = WeatherModel();

        self.locationManager = CLLocationManager();
        locationManager.delegate = self;
        self.fetchWeather();
        self.locationManager.startUpdatingLocation();
        locationManager.requestAlwaysAuthorization();
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        print("locationManager")
        let location = locations.last;
        self.weatherModel.lat = location?.coordinate.latitude;
        self.weatherModel.lon = location?.coordinate.longitude;
        
        self.locationManager?.stopUpdatingLocation();
        fetchWeather();
    }
    func fetchWeather(){
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        let url = weatherModel.getUrl();
        let task = session.dataTask(with: url!, completionHandler: doneFetching);
        task.resume();
    }
    func doneFetching(data: Data?, response: URLResponse?, error: Error?){
        if error != nil {
            print(error!);
            return;
        }
        let decoder = JSONDecoder();
        do {
            let weatherJson = try decoder.decode(WeatherJson.self, from: data!);
            updateModel(json: weatherJson);
            //let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers);
            print("vittuhä")
        }catch let jsonError {
            print(jsonError);
        }
    }
    func updateModel(json: WeatherJson){
        weatherModel.temperature = kelvinToCelsius(kelvin: json.main.temp);
        weatherModel.description = json.weather[0].description;
        weatherModel.icon = json.weather[0].icon;
        weatherModel.country = json.sys.country;
        weatherModel.city = json.name;
        changeValues();
    }
    func changeValues() {
        self.cityLabel.text = "\(weatherModel.city!), \(weatherModel.country!)";
        self.tempLabel.text = "\(kelvinToCelsius(kelvin: weatherModel.temperature!)) °C"
        activityView.stopAnimating();
    }
    func kelvinToCelsius(kelvin: Double) -> Double{
        let celsius  = Double(round((kelvin - 273.15)*100)/100);
        return celsius;
    }
}
