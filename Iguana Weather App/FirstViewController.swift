//
//  FirstViewController.swift
//  Iguana Weather App
//
//  Created by Niko Hienonen on 04/10/2019.
//  Copyright © 2019 Niko Hienonen. All rights reserved.
//

import UIKit;
import CoreLocation;

class FirstViewController: UIViewController{
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!

    var weatherModel: WeatherModel! = WeatherModel();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        activityView.hidesWhenStopped = true;
        activityView.startAnimating()
        fetchWeather();
    }
    override func viewWillAppear(_ animated: Bool) {
        load(self);
    }
    @IBAction func load(_ sender: Any){
        let db = UserDefaults.standard;
        let city = db.string(forKey: "city");
        if city != nil {
            self.weatherModel.city = city!;
            self.fetchWeather();
        }
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
            self.showAlert();
            print("vttusatana")
            return;
        }
        let decoder = JSONDecoder();
        do {
            let weatherJson = try decoder.decode(WeatherJson.self, from: data!);
            print(weatherJson);
            updateModel(json: weatherJson);
        }catch let jsonError {
            self.showAlert();
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
        DispatchQueue.main.async {
            self.cityLabel.text = "\(self.weatherModel.city!), \(self.weatherModel.country!)";
            self.tempLabel.text = "\(self.weatherModel.temperature!) °C";
            self.activityView.stopAnimating();
        }
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
        DispatchQueue.main.async{
            self.icon.image = UIImage(data: data!);
        }
    }
    func kelvinToCelsius(kelvin: Double) -> Double{
        let celsius  = Double(round((kelvin - 273.15)*100)/100);
        return celsius;
    }
    func showAlert(){
        let alert = UIAlertController(title: "No City Found!", message: "No weather information for \(self.weatherModel.city!)!", preferredStyle: .alert);
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil);
        alert.addAction(action);
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil);
        }
    }
}
