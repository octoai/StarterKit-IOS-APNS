//
//  OctoAPI.m
//  GcmExample
//
//  Copyright © 2016 Aurora Borealis Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdlib.h>
@import UIKit;
#import "OctoAPI.h"
#import <sys/utsname.h>

#import <CoreLocation/CoreLocation.h>

@implementation OctoAPI

/*
 SET YOUR API KEY HERE
 You must manually set the API Key here
 */
NSString *APIKEY = @"86a92cb65f95499facafc125401144f0";


/*
 Keep it empty as this is an APNS Implementation and does not require a
 server key
 */
NSString *SERVER_API_KEY = @"";

/*
 ===============================================================================
 WARNING:
 DO NOT EDIT ANYTHING BELOW.
 THIS MAY CAUSE API TO BREAK DOWN
 
 Write to api@octo.ai for any questions
 ===============================================================================
 */

NSString *MANUFACTURER = @"Apple";

NSString *BASEURL = @"http://192.168.0.109:8000";

NSArray *locations;


/*
 Set this as per your implementation. The meanings are
    0    =      GCM,    android
    1    =      GCM,    iOS
    2    =      APNS,   iOS
 
 */
int NOTIFICATIONTYPE = 2;


NSString*
machineName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (NSDictionary*) getPhoneDetails {
    NSString *uniqueIdentifier = [[
                                   [UIDevice currentDevice] identifierForVendor]
                                  UUIDString];
    
    CLLocationCoordinate2D coordinate = [[locations lastObject] coordinate];

    NSNumber* latitude = [NSNumber numberWithDouble:coordinate.latitude];
    NSNumber* longitude = [NSNumber numberWithDouble:coordinate.longitude];
    
    NSString *model = machineName();
    
    NSDictionary *phoneDetails = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  uniqueIdentifier, @"deviceId",
                                  MANUFACTURER, @"manufacturer",
                                  model, @"model",
                                  latitude, @"latitude",
                                  longitude, @"longitude", nil
                                  ];
    return phoneDetails;
    
    
}

+ (void) updateLocation: (NSArray*)loc {
    locations = loc;
}

/*
 Send app init call.
 This method should be called with the appropriate userId
 every time the app comes to foreground
 */
- (NSDictionary*) sendAppInitCall: (NSInteger)userId
                     onCompletion:(void (^)(NSString*))callbackBlock {
    
    NSNumber *val = [NSNumber numberWithInteger:userId];
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                          val, @"userId",
                          [self getPhoneDetails], @"phoneDetails",
                          nil];
    NSString *eventName = @"app.init";
    return [self makeEventsAPICallWithHandler: data
                                    eventName:eventName
                                 onCompletion:callbackBlock];
}

/*
 Send app login call.
 This method should be called with the appropriate userId
 every time there is a login happening
 */
- (NSDictionary*) sendAppLoginCall:(NSInteger)userId
                      onCompletion:(void (^)(NSString*))callbackBlock {
    NSNumber *val = [NSNumber numberWithInteger:userId];
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                          val, @"userId",
                          [self getPhoneDetails], @"phoneDetails",
                          nil];
    NSString *eventName = @"app.login";
    
    return [self makeEventsAPICallWithHandler: data
                                    eventName:eventName
                                 onCompletion:callbackBlock];
}

/*
 Send app logout call.
 This method should be called with the appropriate userId
 every time there is a logout happening.
 */
- (NSDictionary*) sendAppLogoutCall:(NSInteger)userId
                       onCompletion:(void (^)(NSString*))callbackBlock {
    NSNumber *val = [NSNumber numberWithInteger:userId];
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                          val, @"userId",
                          [self getPhoneDetails], @"phoneDetails",
                          nil];
    NSString *eventName = @"app.logout";
    
    return [self makeEventsAPICallWithHandler: data
                                    eventName:eventName
                                 onCompletion:callbackBlock];
}

/*
 Send Page View Call.
 This method should be called with the appropriate parameters
 every time a page is viewed.
 */
- (NSDictionary*) sendPageViewCall:(NSInteger)userId
                          routeUrl:(NSString *)url
                        categories:(NSArray *)cats
                              tags:(NSArray *)alltags
                      onCompletion:(void (^)(NSString*))callbackBlock {
    NSNumber *val = [NSNumber numberWithInteger:userId];
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                          val, @"userId",
                          url, @"routeUrl",
                          cats, @"categories",
                          alltags, @"tags",
                          [self getPhoneDetails], @"phoneDetails",
                          nil];
    NSString *eventName = @"page.view";
    
    return [self makeEventsAPICallWithHandler: data
                                    eventName:eventName
                                 onCompletion:callbackBlock];
}

/*
 Send Product Page View Call.
 Anthing that is consumed is a product. So it could be a content article which
 is consumed in terms of time. Or a material which is consumed in terms of money
 . The value of consumption is what makes price. So, if the blog has 500 words
 and typically takes 3 minutes of reading time, the price of that blog is
 3*60 = 180. Similarly, if a product on ecommerce store has a MRP of 90. The
 price of that product is 90.
 */
- (NSDictionary*) sendProductPageViewCall:(NSInteger)userId
                                 routeUrl:(NSString *)url
                                productId:(NSInteger)pid
                              productName:(NSString *)name
                                    price:(double)cost
                               categories:(NSArray *)cats
                                     tags:(NSArray *)alltags
                             onCompletion:(void (^)(NSString*))callbackBlock
{
    NSNumber *val = [NSNumber numberWithInteger:userId];
    NSNumber *_pid = [NSNumber numberWithInteger:pid];
    NSNumber *_cost = [NSNumber numberWithDouble:cost];
    
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                          val, @"userId",
                          url, @"routeUrl",
                          cats, @"categories",
                          _cost, @"price",
                          _pid, @"productId",
                          name, @"productName",
                          alltags, @"tags",
                          [self getPhoneDetails], @"phoneDetails",
                          nil];
    NSString *eventName = @"productpage.view";
    
    return [self makeEventsAPICallWithHandler: data
                                    eventName:eventName
                                 onCompletion:callbackBlock];
}

/*
 Updates the push token for the user
 */
- (NSDictionary*) updatePushToken:(NSInteger)userId
                        pushToken:(NSString *)token
                     onCompletion:(void (^)(NSString*))callbackBlock {
    NSNumber *val = [NSNumber numberWithInteger:userId];
    
    NSNumber *nType = [NSNumber numberWithInteger:NOTIFICATIONTYPE];
    
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                          val, @"userId",
                          token, @"pushToken",
                          SERVER_API_KEY, @"pushKey",
                          nType, @"notificationType",
                          [self getPhoneDetails], @"phoneDetails",
                          nil];
    return [self makeTokenUpdateCallWithHandler:data onCompletion:callbackBlock];
}

- (NSDictionary*) makeEventsAPICallWithHandler: (NSDictionary*)data
                                     eventName:(NSString*)name
                                  onCompletion:(void (^)(NSString*))callbackBlock {
    NSString* apiUrl = [NSString stringWithFormat:@"%@/%@/%@/", BASEURL,
                        @"events" ,name];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiUrl]];
    NSDictionary* temp = [self makeAPICallWithHandler:data
                                              request:request
                                         onCompletion:callbackBlock];
    NSLog( @"%@", temp );
    return temp;
}

- (NSDictionary*) makeTokenUpdateCallWithHandler: (NSDictionary*)data
                                    onCompletion:(void (^)(NSString*))callbackBlock {
    NSString* apiUrl = [NSString stringWithFormat:@"%@/%@/", BASEURL,
                        @"update_push_token"];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiUrl]];
    return [self makeAPICallWithHandler:data
                                request:request
                           onCompletion:callbackBlock];
}

- (NSDictionary*) makeAPICallWithHandler: (NSDictionary*)data
                                 request:(NSMutableURLRequest*)req
                            onCompletion:(void (^)(NSString*))callbackBlock{
    
    NSDictionary *response = [NSDictionary dictionary];
    NSError *error = nil;
    NSDictionary *header = [[NSDictionary alloc] initWithObjectsAndKeys:
                            APIKEY, @"apikey"
                            , nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                       options:0
                                                         error:&error];
    if (jsonData) {
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:jsonData];
        [req setAllHTTPHeaderFields:header];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:req
                                                completionHandler:
                                      ^(NSData *_data, NSURLResponse *response, NSError *error) {
                                          if(_data) {
                                              [self onHTTPResponse:_data
                                                          response:response
                                                             error:error
                                                      onCompletion:callbackBlock];
                                          }
                                          else {
                                              NSLog(@"%@:%s Error saving context: %@",
                                                    [self class], _cmd,
                                                    [error localizedDescription]);
                                          }
                                      }];
        [task resume];
    } else {
        NSLog(@"Unable to serialize the data %@: %@", data, error);
    }
    return response;
}

- (void) onHTTPResponse: (NSData*) responseData
               response:(NSURLResponse*)res
                  error:(NSError*)err
           onCompletion:(void (^)(NSString*))callbackBlock{
    NSError *errorJson;
    NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:kNilOptions
                                                               error:&errorJson];
    if(response) {
        NSString *strData = [[NSString alloc]initWithData:responseData
                                                 encoding:NSUTF8StringEncoding];
        if(callbackBlock) {
            callbackBlock(strData);
        }
    }
}

@end
