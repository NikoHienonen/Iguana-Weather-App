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
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var locationManager: CLLocationManager!;
    var weatherModel: WeatherModel! = WeatherModel();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        activityView.hidesWhenStopped = true;
        activityView.startAnimating();
        
        self.locationManager = CLLocationManager();
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;

        locationManager.requestAlwaysAuthorization();
        self.locationManager.startUpdatingLocation();
    }

    func locationManager(_ locationManager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
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
        let task = session.dataTask(with: url!, completionHandler: doneFetching)
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
        getIcon();
        //setIcon();
        changeValues();
    }
    func getIcon(){
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        let url = weatherModel.getIconUrl();
        let task = session.dataTask(with: url!, completionHandler: doneFetchingIcon)
        task.resume();
    }
    func doneFetchingIcon(data: Data?, response: URLResponse?, error: Error?){
        if error != nil {
            print(error!);
            return;
        }
        self.icon.image = UIImage(data: data!);
    }
    func changeValues() {
        self.cityLabel.text = "\(weatherModel.city!), \(weatherModel.country!)";
        self.tempLabel.text = "\(weatherModel.temperature!) °C"
        activityView.stopAnimating();
    }
    func kelvinToCelsius(kelvin: Double) -> Double{
        let celsius  = Double(round((kelvin - 273.15)*100)/100);
        return celsius;
    }
}
