//
//  ViewController.swift
//  ApnsExample
//
//  Copyright © 2016 Aurora Borialis. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    
    var label = UILabel(frame: CGRectMake(10, 460, 300, 50))


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeNotificationServices()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Add buttons for Events
        
        // add app login button
        let button   = UIButton(type: UIButtonType.System) as UIButton
        button.frame = CGRectMake(10, 100, 200, 50)
        button.backgroundColor = UIColor.greenColor()
        button.setTitle("App Login", forState: UIControlState.Normal)
        button.addTarget(self, action: "AppLoginBtnHandler:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
        
        // add app logout button
        let button2   = UIButton(type: UIButtonType.System) as UIButton
        button2.frame = CGRectMake(10, 200, 200, 50)
        button2.backgroundColor = UIColor.blueColor()
        button2.setTitle("App Logout", forState: UIControlState.Normal)
        button2.addTarget(self, action: "AppLogoutBtnHandler:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button2)
        
        // add page view button
        let button3   = UIButton(type: UIButtonType.System) as UIButton
        button3.frame = CGRectMake(10, 300, 200, 50)
        button3.backgroundColor = UIColor.redColor()
        button3.setTitle("Page View", forState: UIControlState.Normal)
        button3.addTarget(self, action: "PageViewBtnHandler:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button3)
        
        // add product page view button
        let button4   = UIButton(type: UIButtonType.System) as UIButton
        button4.frame = CGRectMake(10, 400, 200, 50)
        button4.backgroundColor = UIColor.purpleColor()
        button4.setTitle("Product Page View", forState: UIControlState.Normal)
        button4.addTarget(self, action: "ProductPageViewBtnHandler:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button4)
        
        // Create a label for showing Response IDs
        label.text = "Events Results here..."
        label.numberOfLines = 3
        self.view.addSubview(label)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeNotificationServices() -> Void {
        let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        // This is an asynchronous method to retrieve a Device Token
        // Callbacks are in AppDelegate.swift
        // Success = didRegisterForRemoteNotificationsWithDeviceToken
        // Fail = didFailToRegisterForRemoteNotificationsWithError
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func showAPIResult(response: NSString) -> (Void) {
        print(response)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.label.text = response as String
        }
        
    }
    
    func AppLoginBtnHandler(sender:UIButton!){
        let api = OctoAPI()
        api.sendAppLoginCall(5) { (result) -> Void in
            self.showAPIResult(result)
        }
    }
    
    
    func AppLogoutBtnHandler(sender:UIButton!){
        let api = OctoAPI()
        api.sendAppLogoutCall(5) { (result) -> Void in
            self.showAPIResult(result)
        }
    }
    
    
    func PageViewBtnHandler(sender:UIButton) {
        
        let api = OctoAPI()
        
        let routeUrl = "/Home"
        let categories = ["something", "something else"]
        let tags = ["cat1", "cat2"]
        
        api.sendPageViewCall(5, routeUrl: routeUrl,
            categories: categories, tags: tags) { (result) -> Void in
                self.showAPIResult(result)
        }
    }
    
    
    func ProductPageViewBtnHandler(sender:UIButton) {
        
        let api = OctoAPI()
        
        let userId = 5
        let routeUrl = "/Home/Phone"
        let productName = "Smartphone Series S02"
        let price = 999.00
        let productId = 635373
        let categories = ["electronics", "phones"]
        let tags = ["selfie", "cheap"]
        
        api.sendProductPageViewCall(userId, routeUrl: routeUrl,
            productId: productId, price: price, productName: productName,
            categories: categories, tags: tags) { (result) -> Void in
                self.showAPIResult(result)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        OctoAPI.updateLocation(locations)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError: \(error.description)")

    }
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        if status == .AuthorizedAlways {
            if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                }
            }
        }
    }
}