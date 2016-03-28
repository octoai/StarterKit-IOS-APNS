# iOS, APNS Starter Kit #

This kit covers an app published on iOS platform and uses Apple Push Notification Service (APNS) for push notifications.

[TOC]

# Get Started #

## Download Kit##

[Download](downloads/ApnsExample.zip	) the starter kit from here. This starter kit contains a working sample of code that takes all permissions from users, and sends appropriate API calls at appropriate times.

If you already have an app, chances are most of the steps would have been already done. However, it is advised to go through the document and remove any inconsistencies.

The code snippets mentioned here can be found in the starter kit. Should you have any difficulty understaning the flow, the starter kit code should help you out.

### Libraries ###

If you just want to download the libraries for Octomatic API, choose your language below:

- [Objective C API](downloads/OctoAPI_ObjC.zip)
- [Swift API](downloads/OctoAPI_swift.zip)

## Setup Capabilities ##

### GeoLocation ###

---

In order to be able to use geolocation while app is running in foreground, you need to do the following steps:

#### Provide an explanation for why location is being used ####

Create a key named `NSLocationWhenInUseUsageDescription` in `Info.plist`. The string value of this key should be the description. By default, the description reads "*We use geolocation to provide better recommendations*". You may change to a suitable text, if necessary.

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use geolocation to provide better recommendations</string>
```

#### Link to CoreLocation framework ####

Go to `Build Phases > Link Binary with Libraries`. Click on the `+` sign and select `CoreLocation.framework` from the list that comes.

### Push Notification ###

---

- Follow the apple developer's app distribution guide to [configure push notifications](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/AddingCapabilities/AddingCapabilities.html#//apple_ref/doc/uid/TP40012582-CH26-SW6) for your app.
- Send an email to `api@octo.ai` along with the SSL certificates (in .p12) format. You should send us your development and production certificates.

## Setup Octomatic Enterprise API ##

The Octomatic Enterprise API contains following files

- Swift
	- `OctoAPI.swift`
- Objective C
	- `OctoAPI.h`
	- `OctoAPI.m`

Copy these files to your corresponding project's source directory.

### Add API Keys ###

Once copied, you would require to add appropriate API Key and server key at the right places.

**Objective C**

Open `OctoAPI.m` and you should see something like below. Update the `APIKEY` with your Octomatic's Enterprise API Key. You should leave the `SERVER_API_KEY` as it is. It is required only for GCM.

```

/*
 SET YOUR API KEY HERE
 You must manually set the API Key here
 */
NSString *APIKEY = @"";

```

**Swift**

Open `OctoAPI.swift` and update `APIKEY` with your Octomatic's Enterprise API Key. You should also update `SERVER_API_KEY` with the GCM server api key.

```

/*
Update your API KEY here.
*/
var APIKEY = ""

```

### Update the API Endpoint (Optional) ###

By default, the API Endpoint points to production environment. Optionally, you can change this to sandbox endpoint for development purposes. If you need to do so, do it where `BASEURL` is defined.

**Objective C**

```

NSString *BASEURL = @"http://192.168.0.109:8000";

```

**Swift**

```

var BASEURL = "http://192.168.0.109:8000"

```

Modifying the API files any further should not be necessary. However, if you feel any need to do so, please contact us at api@octo.ai beforehand.

## Code Implementation ##

The following section will detail about the actual code implementation and is divided into following parts

- Initialising Octomatic API and handling callback
- Updating user's registrationToken to Octomatic
- Updating user's location
- Sending out API calls
- Handling remote notifications

### Initialising Octomatic API and handling callback ###

In order to initialize Octomatic API import the API files, and initialize the client. The calls are made using `NSUrlSession` and are executed async. A callback can be associated with the request which gets executed with the response value. The response value is a string which contains the eventId of the API call. This eventId can always be used from the dashboard to trace an event.

In the following example, an `app.init` call is made for a user with ID as 2. In the callback, the response is logged to console.

**Objective C**

```

#import "OctoAPI.h"


// somewhere in the code
OctoAPI *api = [[OctoAPI alloc] init];

NSInteger userId = 2;
[api sendAppInitCall:userId
        onCompletion: ^(NSString* response){
            NSLog(@"Got response from App.Init %@",
            response);
    	  }];

```

**Swift**

```

let api = OctoAPI()
let userId = 2
    
api.sendAppInitCall(userId) { (result) -> Void in
    print(result)
}

```

### Updating user's location ###

#### Objective C ####

Include the CoreLocation framework in `AppDelegate.h` header file. Also add a property `locationManager` to AppDelegate interface

```

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>



@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) CLLocationManager *locationManager;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

```

Requesting Geolocation from user should be done when the app finishes launching. Typically, this could be in `AppDelegate.m`'s `didFinishLaunchingWithOptions` function.

```

- (BOOL)application:(UIApplication *)application
      didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Get geolocation permissions from user
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Disabled");
        // location services is disabled, alert user
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DisabledTitle", @"DisabledTitle")
                                                                        message:NSLocalizedString(@"DisabledMessage", @"DisabledMessage")
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"OKButtonTitle", @"OKButtonTitle")
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
    else
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
        NSLog(@"Not Disabled");
    }
}

```

Once the permissions to get geolocation from user is available, then add a delegate method that would update the location to Octomatic's API. Not that this does not necessarily mean an API call. It just means that the next API call happening would include the updated location of the user.

This should typically reside in `AppDelegate.m`

```

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [OctoAPI updateLocation:locations];
}

```

#### Swift ####

Import the required framework in `ViewController.swift` and add it's delegate

```

import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

	var locationManager: CLLocationManager!
	
	// ...
}

```

Ask for authorization when the view loads

```

override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    
}

```

Update Octo API about new locations when they happen. This does not necessarily mean making an API call to Octomatic's endpoint. It only means that the next API call will happen with the new location that is available.

```

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

```

### Sending out API calls ###

#### app.init ####
---

This call should be made everytime the app comes to foreground. Place the code inside `applicationDidBecomeActive` function in `appdelegate` file. There could be potentially more stuff inside it. Make sure to add it to the last of all the other things happening.

**Objective C (AppDelegate.m)**

```

// [START connect_gcm_service]
- (void)applicationDidBecomeActive:(UIApplication *)application {

	// Authenticate the user
	NSInteger userId = 2;

	// Send app.init call to Octomatic
    OctoAPI *api = [[OctoAPI alloc] init];
    [api sendAppInitCall:userId onCompletion: ^(NSString* response){
        NSLog(@"Got response from App.Init %@", response);
    }];
    
}

```

**Swift (AppDelegate.swift)**

```

func applicationDidBecomeActive( application: UIApplication) {

	// authenticate the user
	let userId = 2

	// send App Init API Call to Octo
	let api = OctoAPI()
	api.sendAppInitCall(userId) { (result) -> Void in
	    print("App.Init result", result)
	}
}

```

#### app.login ####
---

This call should be made everytime an un-authenticated user authenticates themselves and logs into the system. Place this at your login callback function.

In the starter kit, these calls are placed in `ViewController` files. They are triggered by corresponding button actions.

**Objective C**

```

// user who just logged in
NSInteger userId = 2;

OctoAPI *api = [[OctoAPI alloc] init];
[api sendAppLoginCall:userId  onCompletion: ^(NSString* response){
    NSLog(@"Got response from App.Login %@", response);
    
    // Possibly store this response for tracing it
}];

```

**Swift**

```

// authenticate the user

let userId = 2

let api = OctoAPI()
api.sendAppLoginCall(userId) { (result) -> Void in
    // do something with the response.
    // possibly store it for tracing/debugging purposes
    print(result)
}

```

#### app.logout ####
---

This call should be made everytime a user chooses to logout from the system. Place this call just before the logout action happens.

In the starter kit, these calls are placed in `ViewController` files. They are triggered by corresponding button actions.

**Objective C**

```

// user who is logging out
NSInteger userId = 2;

OctoAPI *api = [[OctoAPI alloc] init];
[api sendAppLogoutCall:userId  onCompletion: ^(NSString* response){
    NSLog(@"Got response from App.Logout %@", response);
    
	// Possibly store this response for tracing it
}]

```

**Swift**

```

let userId = 2

let api = OctoAPI()
api.sendAppLogoutCall(userId) { (result) -> Void in
    // do something with the response.
    // possibly store it for tracing/debugging purposes
    print(result)
}

```

#### page.view ####
---

This call should be send upon every page view call happening. A pageview is said to happen when a user is browsing any page that is **not a product page**. Product pages are handled separately by a `productpage.view` call.

In the starter kit, these calls are placed in `ViewController` files. They are triggered by corresponding button actions.

**Objective C**

```

// authenticated user who is viewing the page
NSInteger userId = 2;

// Symbolic URL (or other unique identifier)
// for the page being viewed
NSString *routeUrl = @"Home#Index";

// Categories this page belongs to
NSArray *categories = @[@"Aldo", @"Women"];

// Tags that belong to the page
NSArray *tags = @[@"Red", @"Handbag", @"Leather"];

OctoAPI *api = [[OctoAPI alloc] init];
[api sendPageViewCall:userId
				routeUrl:routeUrl
           categories:categories
                 tags:tags
         onCompletion: ^(NSString* response){
             NSLog(@"Got response from Page.View %@", response);
     }];

```

**Swift**

``` 

// Symbolic URL (or other unique identifier)
// for the page being viewed
let routeUrl = "/Home"

// Categories this page belongs to
let categories = ["something", "something else"]

// Tags that belong to the page
let tags = ["cat1", "cat2"]

// authenticated user who is viewing the page
let userId = 2

let api = OctoAPI() 
api.sendPageViewCall(userId, routeUrl: routeUrl,
    categories: categories, tags: tags) { (result) -> Void in
        self.showAPIResult(result)
}

```

#### productpage.view ####
---

This call should be sent on every product pageview. This call differs from the `page.view` call.

In the starter kit, these calls are placed in `ViewController` files. They are triggered by corresponding button actions.

**Objective C**

```

// authenticated user who is viewing the page
NSInteger userId = 2;

// Symbolic URL (or other unique identifier)
// for the page being viewed
NSString *routeUrl = @"Home#Index";

// id of the product
NSInteger pid = 8263243

// name of the product
NSString* name = @"SmartPhone Series S10";

// price of the product
double price = 899.99;

// Categories this page belongs to
NSArray *categories = @[@"Aldo", @"Women"];

// Tags that belong to the page
NSArray *tags = @[@"Red", @"Handbag", @"Leather"];

OctoAPI *api = [[OctoAPI alloc] init];
    [api sendProductPageViewCall:userId
                        routeUrl:routeUrl
                       productId:pid
                     productName:name
                           price:price
                      categories:categories
                            tags:tags
                    onCompletion: ^(NSString* response){
                        NSLog(@"Got response from Productpage.view %@",
                        response);
                    }
     ];

```

**Swift**

```

// authenticated user who is viewing this product
let userId = 4

// Symbolic URL (or other unique identifier)
// for the page being viewed
let routeUrl = "/Home/Phone"

// name of the product being viewed
let productName = "Smartphone Series S02"

// price of the product
let price = 999.00

// ID of the product
let productId = 635373

// categories this product belongs to
let categories = ["electronics", "phones"]

// tags that belong to this product
let tags = ["selfie", "cheap"]

let api = OctoAPI() 
api.sendProductPageViewCall(userId, routeUrl: routeUrl,
    productId: productId, price: price, productName: productName,
    categories: categories, tags: tags) { (result) -> Void in
        print(result)
}

```

### Registering for remote notifications ###

**Objective C (AppDelegate.m)**

Put the following inside `didFinishLaunchingWithOptions` so as to ask permissions about push notifications.

```
// Get Push Notifications permissions from user
if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
    // iOS 7.1 or earlier
    UIRemoteNotificationType allNotificationTypes =
    (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge);
    [application registerForRemoteNotificationTypes:allNotificationTypes];
} else {
    // iOS 8 or later
    // [END_EXCLUDE]
    UIUserNotificationType allNotificationTypes =
    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}
```

The following functions check the status of push notifications permissions and appropriately handle the situation. If it is a success asking for permissions, updates Octo with the push Token of the user.

```
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSLog(@"My token is: %@", hexToken);
    
    
    // update the token to Octo
    OctoAPI *api = [[OctoAPI alloc] init];
    [api updatePushToken:2 pushToken:hexToken  onCompletion: ^(NSString* response){
        NSLog(@"Got response from Push Token %@", response);
    }];
    
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
     NSLog(@"Failed to get token, error: %@", error);
}

```

**Swift (ViewController.swift)**

The following will ask for push notifications permissions from the user.

```
let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil)
UIApplication.sharedApplication().registerUserNotificationSettings(settings)
```

Inside the `AppDelegate.swift` do the handler functions for success or failure of the permissions.

```
func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    
    let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
    let deviceTokenString = ( deviceToken.description as NSString )
        .stringByTrimmingCharactersInSet( characterSet )
        .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        // Update to Octomatic
        
    let api = OctoAPI()
    api.sendPushToken(5, pushToken: deviceTokenString) { (result) -> Void in
        print("Push Token Response", result)
    }
}
    
func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    print("Device token for push notifications: FAIL -- ")
    print(error.description)
}
```

### Handling remote notifications ###

In order to inform the user about an incoming remote notification, the appropriate `didReceiveRemoteNotification` call needs to be worked upon. Here is how you can do it:

**Objective C (AppDelegate.m)**

```
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"App In foreground");
        
        if ([UIAlertController class])
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert title"
                                                                                     message:@"Alert message"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
//            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Push Notification" message:userInfo[@"aps"][@"alert"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        
        
    }
    else if (application.applicationState == UIApplicationStateBackground || application.applicationState == UIApplicationStateInactive) {
        NSLog(@"App in background");
        // Do something else rather than showing an alert view, because it won't be displayed.
        
        NSLog(@"Notification 2 received: %@", userInfo);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"APNS ObjC"
                                                            object:nil
                                                          userInfo:userInfo];
        handler(UIBackgroundFetchResultNewData);
        
        NSLog(@"Done with notification stuff.");
    }
    
    
}
```

**Swift (AppDelegate.swift)**

```
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        print("Recived: \(userInfo)")
        // do something if you want to do with this message
    }
```
