//
//  ViewController.m
//  ApnsExampleObjC
//
//  Created by Pranav Prakash on 14/03/16.
//  Copyright © 2016 Aurora Borialis. All rights reserved.
//

#import "ViewController.h"
#import "OctoAPI.h"

@interface ViewController ()

@end

@implementation ViewController

UILabel* myLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /*
     Create Buttons for various calls
     */
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(appLogoutBtnHandler:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"App Logout" forState:UIControlStateNormal];
    UIColor *color = [UIColor colorWithRed:14.0/255.0 green:114.0/255.0 blue:199.0/255.0 alpha:1];
    [button setBackgroundColor:color];
    button.frame = CGRectMake(10, 100, 200, 50);
    [self.view addSubview:button];
    
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 addTarget:self
                action:@selector(appLoginBtnHandler:)
      forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitle:@"App Login" forState:UIControlStateNormal];
    [button2 setBackgroundColor:[UIColor colorWithRed:119.0/255.0 green:114.0/255.0 blue:199.0/255.0 alpha:1]];
    button2.frame = CGRectMake(10, 200, 200, 50);
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3 addTarget:self
                action:@selector(pageViewBtnHandler:)
      forControlEvents:UIControlEventTouchUpInside];
    [button3 setTitle:@"Page View" forState:UIControlStateNormal];
    [button3 setBackgroundColor:[UIColor colorWithRed:119.0/255.0 green:9.0/255.0 blue:199.0/255.0 alpha:1]];
    button3.frame = CGRectMake(10, 300, 200, 50);
    [self.view addSubview:button3];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button4 addTarget:self
                action:@selector(productPageViewBtnHandler:)
      forControlEvents:UIControlEventTouchUpInside];
    [button4 setTitle:@"Product Page View" forState:UIControlStateNormal];
    [button4 setBackgroundColor:[UIColor colorWithRed:119.0/255.0 green:114.0/255.0 blue:1.0/255.0 alpha:1]];
    button4.frame = CGRectMake(10, 400, 200, 50);
    [self.view addSubview:button4];
    
    
    myLabel =  [[UILabel alloc] initWithFrame: CGRectMake(10, 455, 300, 100)];
    myLabel.text = @"Responses show here...";
    myLabel.numberOfLines = 3;
    [self.view addSubview:myLabel];

    
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    NSLog(@"lat%f - lon%f", location.coordinate.latitude, location.coordinate.longitude);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) appLogoutBtnHandler: (UIButton*)sender {
    OctoAPI *api = [[OctoAPI alloc] init];
    [api sendAppLogoutCall:2  onCompletion: ^(NSString* response){
        NSLog(@"Got response from App.Logout %@", response);
        dispatch_async(dispatch_get_main_queue(), ^{
            [myLabel setText:response];
        });
        
    }];
}

- (void) appLoginBtnHandler: (UIButton*)sender {
    OctoAPI *api = [[OctoAPI alloc] init];
    [api sendAppLoginCall:2  onCompletion: ^(NSString* response){
        NSLog(@"Got response from App.Login %@", response);
        dispatch_async(dispatch_get_main_queue(), ^{
            [myLabel setText:response];
        });
    }];
}

- (void) pageViewBtnHandler: (UIButton*)sender {
    OctoAPI *api = [[OctoAPI alloc] init];
    [api sendPageViewCall:2 routeUrl: @"Home#Index"
               categories:@[@"Aldo", @"Women"]
                     tags:@[@"Red", @"Handbag", @"Leather"]
             onCompletion: ^(NSString* response){
        NSLog(@"Got response from Page.View %@", response);
        dispatch_async(dispatch_get_main_queue(), ^{
            [myLabel setText:response];
        });
    }];
}

- (void) productPageViewBtnHandler: (UIButton*)sender {
    OctoAPI *api = [[OctoAPI alloc] init];
    [api sendProductPageViewCall:2
                        routeUrl:@"Home#Deals"
                       productId:88
                     productName:@"SmartPhone"
                           price:899.9
                      categories:@[@"Electronics", @"Mobile"]
                            tags:@[@"Delhi", @"Motorola"]
                    onCompletion: ^(NSString* response){
                            NSLog(@"Got response from Productpage.view %@", response);
                        dispatch_async(dispatch_get_main_queue(), ^{
            [myLabel setText:response];
        });
    }
     ];
}


@end
