//
//  OnboardingViewController.swift
//  AR-Portal
//
//  Created by Ethan D'Mello on 2020-02-19.
//  Copyright © 2020 Rayan Slim. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var exitButton: UIButton!
    
    @IBAction func exitTapped(_ sender: Any) {
        UserDefaults.standard.set("true", forKey: K.onboardScreenShown)
        performSegue(withIdentifier: K.toMain, sender: self)
    }
}
