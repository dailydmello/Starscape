//
//  OnboardingViewController.swift
//  AR-Portal
//
//  Created by Ethan D'Mello on 2020-02-19.
//  Copyright © 2020 Rayan Slim. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var container: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        container.layer.cornerRadius = 20
        skipButton.layer.borderWidth = 1.2
        skipButton.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func skipTapped(_ sender: Any) {
        UserDefaults.standard.set("true", forKey: "OnboardScreenShown")
        performSegue(withIdentifier: "toMain", sender: self)
    }
}
