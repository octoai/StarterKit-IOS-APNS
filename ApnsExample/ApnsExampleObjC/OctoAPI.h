//
//  OctoAPI.h
//  GcmExample
//
//  Copyright © 2016 Aurora Borealis Inc. All rights reserved.
//

#ifndef OctoAPI_h
#define OctoAPI_h


#endif /* OctoAPI_h */

@interface OctoAPI : NSObject

-(NSDictionary*) sendAppInitCall: (NSInteger) userId
                    onCompletion:(void (^)(NSString*))callbackBlock;

-(NSDictionary*) sendAppLoginCall: (NSInteger) userId
                     onCompletion:(void (^)(NSString*))callbackBlock;

-(NSDictionary*) sendAppLogoutCall: (NSInteger) userId
                      onCompletion:(void (^)(NSString*))callbackBlock;

-(NSDictionary*) sendPageViewCall: (NSInteger)userId
                         routeUrl:(NSString*) url
                       categories:(NSArray*) cats
                             tags:(NSArray*) alltags
                     onCompletion:(void (^)(NSString*))callbackBlock;

-(NSDictionary*) sendProductPageViewCall:(NSInteger) userId
                                routeUrl:(NSString*) url
                               productId:(NSInteger) pid
                             productName:(NSString*) name
                                   price:(double) cost
                              categories:(NSArray*) cats
                                    tags:(NSArray*) alltags
                            onCompletion:(void (^)(NSString*))callbackBlock;

-(NSDictionary*)updatePushToken: (NSInteger) userId
                      pushToken:(NSString*)token
                   onCompletion:(void (^)(NSString*))callbackBlock;


+ (void) updateLocation: (NSArray *) loc;

@end
