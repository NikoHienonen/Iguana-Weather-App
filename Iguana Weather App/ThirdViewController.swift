//
//  FirstViewController.swift
//  Iguana Weather App
//
//  Created by Niko Hienonen on 04/10/2019.
//  Copyright © 2019 Niko Hienonen. All rights reserved.
//

import UIKit;
import CoreLocation;

class ThirdViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate{
    
    var cities = ["Use GPS", "Tampere", "Helsinki", "Vaasa"];
    
    var locationManager: CLLocationManager!;
    var weatherModel: WeatherModel! = WeatherModel();
    
    @IBOutlet weak var cityTableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        cityTableView.tableFooterView = UIView(frame: CGRect.zero);
        
        self.cityTableView.dataSource = self;
        self.cityTableView.delegate = self;
        
        self.locationManager = CLLocationManager();
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        locationManager.requestAlwaysAuthorization();
        self.locationManager.startUpdatingLocation();
    }
    @IBAction func addPressed(_ sender: UIButton) {
        cities.append(textField.text!);
        
        let indexPath = IndexPath(row: (cities.count - 1), section: 0);
        
        cityTableView.beginUpdates();
        cityTableView.insertRows(at: [indexPath], with: .automatic);
        cityTableView.endUpdates();
        
        textField.text = "";
        view.endEditing(true);
    }

    //From delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("\(cities[indexPath.row])");
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cities.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "citycell", for: indexPath);
        cell.textLabel!.text = self.cities[indexPath.row];
        
        return cell;
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            cities.remove(at: indexPath.row);
            
            cityTableView.beginUpdates();
            cityTableView.deleteRows(at: [indexPath], with: .automatic);
            cityTableView.endUpdates();
        }
    }
    
    func locationManager(_ locationManager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = locations.last;
        
        //self.weatherModel.lat = location?.coordinate.latitude;
        //self.weatherModel.lon = location?.coordinate.longitude;
        self.locationManager?.stopUpdatingLocation();

    }

}
