//
//  SettingsViewController.swift
//  TeachAssist
//
//  Created by hiep tran on 2020-04-07.
//  Copyright © 2020 Ben Tran. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class SettingsViewController: UIViewController {
    var lightThemeEnabled = false
    var lightThemeLightBlack = UIColor(red: 39/255, green: 39/255, blue: 47/255, alpha: 1)
    var lightThemeWhite = UIColor(red:51/255, green:51/255, blue: 61/255, alpha:1)
    var lightThemeBlack = UIColor(red:255/255, green:255/255, blue: 255/255, alpha:1)
    var lightThemeBlue = UIColor(red: 4/255, green: 93/255, blue: 86/255, alpha: 1)
    var lightThemePink = UIColor(red: 255/255, green: 65/255, blue: 128/255, alpha: 1)
    
    var products: [SKProduct] = []
    
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var teachassistProLabel: UILabel!
    @IBOutlet weak var teachassistProDescLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        //check for light theme
        let Preferences = UserDefaults.standard
        let currentPreferenceExists = Preferences.object(forKey: "LightThemeEnabled")
        if currentPreferenceExists != nil{ //preference does exist
            lightThemeEnabled = Preferences.bool(forKey: "LightThemeEnabled")
            if(lightThemeEnabled){
                //set colours
                lightThemeLightBlack = UIColor(red: 228/255, green: 228/255, blue: 235/255, alpha: 1.0)
                lightThemeWhite = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                lightThemeBlack = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
                lightThemeBlue = UIColor(red: 55/255, green: 239/255, blue: 186/255, alpha: 1.0)
                lightThemePink = UIColor(red: 114/255, green: 159/255, blue: 255/255, alpha: 1.0)
                
                self.navigationController?.navigationBar.barTintColor = lightThemeWhite
                navigationItem.backBarButtonItem?.tintColor = lightThemeBlack
                navigationController!.navigationBar.barStyle = UIBarStyle.black
                self.view.backgroundColor = lightThemeWhite
                
            }
        }
        
        //get all currently active products form the store
        PaidProducts.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            if success {
                self.products = products!
                print(products)
                print("HERE")
            }else{
                print("Failed to get products from the app store!")
            }
            
        }
        
        //setup upgrade button
        let gradientColors: [CGColor] = [lightThemeBlue.cgColor, lightThemePink.cgColor]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
        gradientLayer.frame = upgradeButton.bounds
        gradientLayer.cornerRadius = 5
        upgradeButton.layer.insertSublayer(gradientLayer, at: 0)
        upgradeButton.setTitleColor(lightThemeBlack, for: .normal)
        
        if (Preferences.object(forKey: "isProUser") as? Bool) == true{
            upgradeButton.setTitle("Thank for your support!", for: .normal)
            teachassistProLabel.isHidden = true
            teachassistProDescLabel.isHidden = true
        }else{
            upgradeButton.addTarget(self, action: #selector(OnUpgradeButtonPress), for: .touchUpInside)
        }
        
        //debug remove pro, COMMENT OUT IN PRODUCTION
        Preferences.set(false, forKey: "isProUser")
        Preferences.synchronize()
        
        
        //setup Ta pro labels
        teachassistProLabel.superview?.backgroundColor = lightThemeWhite
        teachassistProLabel.textColor = lightThemeBlack
        teachassistProDescLabel.textColor = lightThemeBlack
        
        
    }
    
    @objc func OnUpgradeButtonPress(sender: UIButton) {
        if IAPHelper.canMakePayments(){
            if products.count >= 1{
                let removeAdsProduct = products[0]
                let priceFormatter = NumberFormatter()
                priceFormatter.formatterBehavior = .behavior10_4
                priceFormatter.numberStyle = .currency
                priceFormatter.locale = removeAdsProduct.priceLocale
                if PaidProducts.store.isProductPurchased(removeAdsProduct.productIdentifier){
                    makeUserPro()
                    let alert = UIAlertController(title: "Your purchase has been restored!", message: "Thank you!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action:UIAlertAction!) in
                    }))
                    self.present(alert, animated: true)
                }else{
                    let price = priceFormatter.string(from: removeAdsProduct.price)
                    let alert = UIAlertController(title: "Purchase Item?", message: "Are you sure you want to Remove Ads for \(price!)?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Buy", style: .default, handler: { (action:UIAlertAction!) in
                        PaidProducts.store.buyProduct(removeAdsProduct)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action:UIAlertAction!) in
                    }))
                    self.present(alert, animated: true)
                }
            }else{
                let alert = UIAlertController(title: "Could not connect to Apple", message: "Please check your internet connection and try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action:UIAlertAction!) in
                }))
                self.present(alert, animated: true)
            }
        }else{
            let alert = UIAlertController(title: "In App Purchases Disabled", message: "Please check your parental controls and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action:UIAlertAction!) in
            }))
            self.present(alert, animated: true)
        }
        
    }
    
    public func makeUserPro(){ //should be called in the IAB helper file after the purchase is succesfully completed
        let Preferences = UserDefaults.standard
        Preferences.set(true, forKey: "isProUser")
        Preferences.synchronize()
        
        upgradeButton.setTitle("Thank for your support!", for: .normal)
        teachassistProLabel.isHidden = true
        teachassistProDescLabel.isHidden = true
        print("USER IS NOW PRO")
    }
    
    
}

extension UIAlertController {
    
    func show() {
        present(animated: true, completion: nil)
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFromController(controller: rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFromController(controller: visibleVC, animated: animated, completion: completion)
        } else
            if let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                presentFromController(controller: selectedVC, animated: animated, completion: completion)
            } else {
                controller.present(self, animated: animated, completion: completion);
        }
    }
}
