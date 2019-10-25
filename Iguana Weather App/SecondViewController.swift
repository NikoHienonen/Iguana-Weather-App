//
//  FirstViewController.swift
//  Iguana Weather App
//
//  Created by Niko Hienonen on 04/10/2019.
//  Copyright © 2019 Niko Hienonen. All rights reserved.
//

import UIKit;
import CoreLocation;

class ForecastCell: UITableViewCell {

    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}

class SecondViewController: UITableViewController, CLLocationManagerDelegate{
    var temperatures = [String]();
    var dates = [String]();
    var iconCodes = [String]();
    var icons: [String: UIImage] = [:];
    
    var weatherModel: WeatherModel! = WeatherModel();
    var locationManager: CLLocationManager! = CLLocationManager();
    var isLoadUp: Bool = true;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        fetchWeather();
    }
    override func viewWillAppear(_ animated: Bool) {
        self.clearArrays();
        load(self);
    }
    
    //From delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("\(temperatures[indexPath.row])");
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.temperatures.count;
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ForecastCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: indexPath) as! ForecastCell;
        cell.tempLabel.text = self.temperatures[indexPath.row];
        cell.dateLabel.text = self.dates[indexPath.row];
        cell.iconImg.image = self.icons[iconCodes[indexPath.row]];
        return cell;
    }
    
    @IBAction func load(_ sender: Any){
        let db = UserDefaults.standard;
        let city = db.string(forKey: "city");
        if city == "useGPS" || city == nil {
            locationManager.requestAlwaysAuthorization();
            self.locationManager.startUpdatingLocation();
        }else {
            self.weatherModel.city = city!;
            self.fetchWeather();
        }
        
    }
    func clearArrays(){
        self.temperatures.removeAll();
        self.dates.removeAll();
        self.iconCodes.removeAll();
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
                let temp = "\(item.weather[0].main) \(self.kelvinToCelsius(kelvin: item.main.temp))°C";
                let date = "\(item.dt_txt)";
                let icon = item.weather[0].icon;
                if icons[icon] == nil {
                    getIcon(iconCode: icon);
                }
                self.iconCodes.append(icon);
                self.dates.append(date);
                self.temperatures.append(temp);
            }
            DispatchQueue.main.async{
                self.tableView.reloadData();
            }
        } else {
            return;
        }
    }
    func getIcon(iconCode: String){
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        let url = weatherModel.getForecastIconUrl(iconCode: iconCode);
        let task = session.dataTask(with: url!) { [weak self] data, response, error in
            if error != nil {
                print(error!);
                return;
            }
            else {
                DispatchQueue.main.async{
                    self!.icons[iconCode] = UIImage(data: data!);
                }
            }
        }
        task.resume();
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
                } else {
                    print(error!);
                }
            })
        } else {
            return;
        }
    }
}
