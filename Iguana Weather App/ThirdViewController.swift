//
//  FirstViewController.swift
//  Iguana Weather App
//
//  Created by Niko Hienonen on 04/10/2019.
//  Copyright © 2019 Niko Hienonen. All rights reserved.
//

import UIKit;
import CoreLocation;

class ThirdViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var cities = ["Use GPS", "Tampere", "Helsinki", "Vaasa"];
    
    var weatherModel: WeatherModel! = WeatherModel();
    
    @IBOutlet weak var cityTableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        cityTableView.tableFooterView = UIView(frame: CGRect.zero);
        
        self.load(self);
        
        self.cityTableView.dataSource = self;
        self.cityTableView.delegate = self;
        
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
    @IBAction func save(_ sender: Any) {
        let db = UserDefaults.standard;
        db.set(self.weatherModel.city, forKey: "city");
        db.set(self.cities, forKey: "citiesArray");
        db.synchronize();
    }
    @IBAction func load(_ sender: Any){
        let db = UserDefaults.standard;
        let cities = db.array(forKey: "citiesArray");
        if cities != nil {
            self.cities = cities as! [String];
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.save(self);
    }
    //From delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            let currentCell = tableView.cellForRow(at: indexPath);
            weatherModel.city = currentCell!.textLabel!.text;
        } else {
            weatherModel.city = "useGPS";
        }
        self.save(self);
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
        if editingStyle == .delete && indexPath.row > 0{
            cities.remove(at: indexPath.row);
            
            cityTableView.beginUpdates();
            cityTableView.deleteRows(at: [indexPath], with: .automatic);
            cityTableView.endUpdates();
        }
    }
}
