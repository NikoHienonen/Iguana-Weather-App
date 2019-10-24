//
//  FirstViewController.swift
//  Iguana Weather App
//
//  Created by Niko Hienonen on 04/10/2019.
//  Copyright © 2019 Niko Hienonen. All rights reserved.
//

import UIKit;
import CoreLocation;

struct CellData {
    let icon: UIImage?;
    let weather: String?;
}

class SecondViewController: UITableViewController, CLLocationManagerDelegate{
    
    var forecasts = [CellData]();
    var temperatures: [String]();
    
    var weatherModel: WeatherModel! = WeatherModel();
    var locationManager: CLLocationManager! = CLLocationManager();
    var isLoadUp: Bool = true;
    
    override func viewDidLoad() {
        super.viewDidLoad();

        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
    }
    override func viewWillAppear(_ animated: Bool) {
        load(self);
    }
    
    //From delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("\(forecasts[indexPath.row])");
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.forecasts.count;
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: indexPath);
        print("forecast in view:\(self.forecasts)");
        cell.textLabel!.text = self.forecasts[indexPath.row].weather;
        
        return cell;
    }
    
    @IBAction func load(_ sender: Any){
        let db = UserDefaults.standard;
        let city = db.string(forKey: "city");
        if city != nil {
            if city == "useGPS" {
                locationManager.requestAlwaysAuthorization();
                self.locationManager.startUpdatingLocation();
            }else {
                self.weatherModel.city = city!;
                self.fetchWeather();
            }
        }
    }
    func fetchWeather(){
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        let url = weatherModel.getForecastUrl();
        let task = session.dataTask(with: url!, completionHandler: doneFetching)
        task.resume();
    }
    func doneFetching(data: Data?, response: URLResponse?, error: Error?){
        if error != nil {
            return;
        }
        let decoder = JSONDecoder();
        do {
            let weatherJson = try decoder.decode(Forecast.self, from: data!);
            setTheArray(weatherJson: weatherJson);
        }catch let jsonError {
            if(isLoadUp){
                print(jsonError);
                isLoadUp = false;
                return;
            } else {
                self.showAlert();
                return;
            }
        }
    }
    func setTheArray(weatherJson: Forecast){
        let list = weatherJson.list;
        if list.count > 0 {
            for item in list {
                let temp = "\(item.weather[0].main) \(self.kelvinToCelsius(kelvin: item.main.temp)) °C";
                self.temperatures.append(temp);
            }
            DispatchQueue.main.async{
                self.tableView.reloadData();
            }
        } else {
            return;
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
            //self.icon.image = UIImage(data: data!);
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
    func locationManager(_ locationManager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if locations.count > 0 {
            let location = locations.last;
            //self.weatherModel.lat = location?.coordinate.latitude;
            //self.weatherModel.lon = location?.coordinate.longitude;
            self.locationManager?.stopUpdatingLocation();
            let geoCoder = CLGeocoder();
            geoCoder.reverseGeocodeLocation(location!, completionHandler: { (placemarks, error) in
                if error == nil {
                    let loc = placemarks![0];
                    self.weatherModel.city = loc.locality!;
                    self.fetchWeather();
                    print("set city in locationmanager")
                } else {
                    print(error!);
                }
            })
        } else {
            return;
        }
    }
}
