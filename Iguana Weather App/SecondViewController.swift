//
//  FirstViewController.swift
//  Iguana Weather App
//
//  Created by Niko Hienonen on 04/10/2019.
//  Copyright © 2019 Niko Hienonen. All rights reserved.
//

import UIKit;
import CoreLocation;

class SecondViewController: UITableViewController{
    
    var forecasts = ["Day 1", "Day 2", "Day 3", "Day 4", "Day 5"];
    
    var weatherModel: WeatherModel! = WeatherModel();
    
    override func viewDidLoad() {
        super.viewDidLoad();

    }
    //From delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("\(forecasts[indexPath.row])");
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.forecasts.count;
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath);
        cell.textLabel!.text = self.forecasts[indexPath.row];
        
        return cell;
    }
    
}
