//
//  activitySpinner.swift
//  Iguana Weather App
//
//  Created by Niko Hienonen on 07/10/2019.
//  Copyright © 2019 Niko Hienonen. All rights reserved.
//

import Foundation;
import UIKit;

var spinner: UIView?

extension UIViewController{
    func showSpinner(onView: UIView){
        let spinnerView = UIView.init(frame: onView.bounds);
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5);
        let ai = UIActivityIndicatorView.init(style: .whiteLarge);
        ai.startAnimating();
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai);
            onView.addSubview(spinnerView);
        }
        spinner = spinnerView;
    }
    func removeSpinner(){
        DispatchQueue.main.async {
            spinner?.removeFromSuperview();
            spinner = nil;
        }
    }
}
