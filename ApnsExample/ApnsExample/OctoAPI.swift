//
//  OctoAPI.swift
//  GcmExample
//
//  Copyright © 2016 Aurora Borealis Inc. All rights reserved.
//

import Foundation
import UIKit

/*
Octo Enterprise API Class
*/
class OctoAPI {
    
    
    /*
    Update your API KEY here.
    var APIKEY = "YOUR_API_KEY"
    */
    
    var APIKEY = "86a92cb65f95499facafc125401144f0"
    
    /*
    ==============[ WARNING ]===================================================
    Do NOT edit/update anything below, or the API may not work properly
    
    For any queries, drop an email to api@octo.ai
    
    ============================================================================
    */
    var BASEURL = "http://192.168.0.109:8000"
    var MANUFACTURER = "Apple"
    
    
    /*
    Set this as per your implementation. The meanings are
    0    =      GCM,    android
    1    =      GCM,    iOS
    2    =      APNS,   iOS
    
    */
    
    var NOTIFICATIONTYPE = 2
    
    static var locations : NSArray = [Double]()
    
    class func updateLocation(loc: NSArray) {
        locations = loc;
    }
    
    init() {
    }
    
    // get user's device ID
    func getDeviceId() -> String {
        return UIDevice.currentDevice().identifierForVendor!.UUIDString
    }
    
    // get phone details
    func getPhoneDetails() -> [String: AnyObject] {
        var lat : Double = 0.0
        var lon : Double = 0.0
        if(OctoAPI.locations.count > 0) {
        let latestLocation: AnyObject = OctoAPI.locations[OctoAPI.locations.count - 1]
            lat = latestLocation.coordinate.latitude
            lon = latestLocation.coordinate.longitude
        }
        return [
            "deviceId" : getDeviceId(),
            "manufacturer" : MANUFACTURER,
            "model": UIDevice.currentDevice().model,
            "latitude" : lat,
            "longitude" : lon
        ]
    }
    
    // Send App Logout Calls
    func sendAppLogoutCall(userId: Int, completion: (result: String) -> Void) {
        let JSONObject: [String : AnyObject] = [
            "userId" : userId,
            "phoneDetails" : getPhoneDetails()
        ]
        makeEventsAPICall(JSONObject, event: "app.logout", completion: completion)
        
    }
    
    // Send App Init Calls
    func sendAppInitCall(userId: Int, completion: (result: String) -> Void) {
        let JSONObject: [String : AnyObject] = [
            "userId" : userId,
            "phoneDetails" : getPhoneDetails()
        ]
        makeEventsAPICall(JSONObject, event: "app.init", completion: completion)
    }
    
    
    
    // Send App Login Call
    func sendAppLoginCall(userId: Int, completion: (result: String) -> Void) {
        let JSONObject: [String : AnyObject] = [
            "userId" : userId,
            "phoneDetails" : getPhoneDetails()
        ]
        makeEventsAPICall(JSONObject, event: "app.login", completion: completion)
    }
    
    // Send page view call
    func sendPageViewCall(userId: Int, routeUrl: String, categories: [String],
        tags: [String], completion: (result: String) -> Void) {
            let JSONObject: [String : AnyObject] = [
                "userId" : userId,
                "phoneDetails" : getPhoneDetails(),
                "routeUrl" : routeUrl,
                "categories" : categories,
                "tags" : tags
            ]
            makeEventsAPICall(JSONObject, event: "page.view", completion: completion)
    }
    
    
    // Send Product page view call
    func sendProductPageViewCall(userId: Int, routeUrl: String, productId: Int,
        price: Double, productName: String, categories: [String], tags: [String],
        completion: (result: String) -> Void) {
            
            let JSONObject: [String : AnyObject] = [
                "userId" : userId,
                "phoneDetails" : getPhoneDetails(),
                "routeUrl" : routeUrl,
                "categories" : categories,
                "tags" : tags,
                "productId" : productId,
                "productName" : productName,
                "price" : price
            ]
            makeEventsAPICall(JSONObject, event: "productpage.view", completion: completion)
    }
    
    // Send Push Notification Token
    func sendPushToken(userId: Int?, pushToken: String, completion: (result: String) -> Void) {
        let JSONObject: [String: AnyObject] = [
            "userId" : userId!,
            "pushToken": pushToken,
            "pushKey": "",
            "notificationType" : NOTIFICATIONTYPE,
            "phoneDetails" : getPhoneDetails()
        ]
        makeUpdatePushTokenAPICall(JSONObject, completion: completion)
    }
    
    
    // Make EventsAPI Call
    func makeEventsAPICall(JSONObject:[String: AnyObject], event:String, completion: (result: String) -> Void) {
        // create the request & response
        let request = NSMutableURLRequest(
            URL: NSURL(string: BASEURL + "/events/" + event + "/")!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 5)
        makeAPICall(request, JSONObject: JSONObject, completion: completion)
    }
    
    // Make Update Push Token API Call
    func makeUpdatePushTokenAPICall(JSONObject:[String: AnyObject], completion: (result: String) -> Void) {
        let request = NSMutableURLRequest(
            URL: NSURL(string: BASEURL + "/update_push_token/")!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 5)
        makeAPICall(request, JSONObject: JSONObject, completion: completion)
    }
    
    // raw API Call
    func makeAPICall(request:NSMutableURLRequest, JSONObject:[String: AnyObject], completion: (result: String) -> Void) {
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(
                JSONObject, options:  NSJSONWritingOptions(rawValue:0))
        }
        catch (let e) {
            print(e)
        }
        
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(APIKEY, forHTTPHeaderField: "apikey")
        
        // send the request
        do {
            httpGet(request){
                (data, error) -> Void in
                if error != nil {
                    print(error)
                } else {
                    completion(result: data)
                }
            }
        }
        catch (let e) {
            print(e)
        }
    }
    
    func httpGet(request: NSURLRequest!, callback: (String, String?) -> Void) {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){
            (data, response, error) -> Void in
            if error != nil {
                callback("", error!.localizedDescription)
            } else {
                let result = NSString(data: data!, encoding:
                    NSASCIIStringEncoding)!
                callback(result as String, nil)
            }
        }
        task.resume()
    }
}
