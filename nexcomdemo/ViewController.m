//
//  ViewController.m
//  nexcomdemo
//
//  Created by kuang-ting liu on 2015/12/15.
//  Copyright © 2015年 kuang-ting liu. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *iv;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController
{
    bool isCheckfinish;
    int CurrentMinor;
    int CurrentRssi;
    CLBeacon *MaxBeacon;
    int MaxRssi;
    NSTimer *myTimer;
    NSTimer *clearTimer;


}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    NSUUID * nsuuid = [[NSUUID alloc] initWithUUIDString:@"28C3AC12-1CCB-4FB7-93B5-890021F0E30B"];
    CLBeaconRegion * beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:nsuuid identifier:[NSString stringWithFormat:@"region%d",1]];
    [_locationManager startMonitoringForRegion:beaconRegion];
    _iv.image = [UIImage imageNamed:@"load.jpg"];
    
    isCheckfinish = YES;
    CurrentRssi = -100;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"%@",error);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"didStartMonitoringForRegion %@",region);
    CLBeaconRegion * beaconRegion  = (CLBeaconRegion * )region;
    [self.locationManager startRangingBeaconsInRegion:beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if(isCheckfinish)
    {
        isCheckfinish = NO;
        NSLog(@"didRangeBeacons %@",beacons);
        for (NSObject *b in beacons) {
            CLBeacon *beacon = (CLBeacon *)b;
            if([beacon.major integerValue] == 77 &&
               ([beacon.minor integerValue] == 31 ||
                [beacon.minor integerValue] == 32 ||
                [beacon.minor integerValue] == 33 ))
            {
                if(beacon.rssi> -70 && beacon.rssi != 0)
                {
                    if(CurrentRssi<beacon.rssi)
                    {
                        MaxRssi = beacon.rssi;
                        MaxBeacon = beacon;
                    }
                }
            }
            
        }
        MaxRssi = -100;
        if([MaxBeacon.major integerValue] == 77)
        {
            if(clearTimer != nil)
            {
                [clearTimer invalidate];
                clearTimer = nil;
            }
            myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                              selector:@selector(changePicture)
                                                              userInfo:nil
                                                               repeats:false];
            clearTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                       target:self
                                                     selector:@selector(clearPicture)
                                                     userInfo:nil
                                                      repeats:false];
        }
        else
        {
            isCheckfinish = YES;
        }
    }
    
}

-(void)changePicture
{
    if([MaxBeacon.minor integerValue] != CurrentMinor)
    {
        CurrentMinor = [MaxBeacon.minor integerValue];
        if([MaxBeacon.major integerValue] == 77 && [MaxBeacon.minor integerValue]== 31)
            _iv.image = [UIImage imageNamed:@"s1.jpg"];
        else if([MaxBeacon.major integerValue]== 77 && [MaxBeacon.minor integerValue]== 32)
            _iv.image = [UIImage imageNamed:@"s2.jpg"];
        else if([MaxBeacon.major integerValue]== 77 && [MaxBeacon.minor integerValue]== 33)
            _iv.image = [UIImage imageNamed:@"s3.jpg"];
        
        [myTimer invalidate];
        myTimer = nil;
    }
    isCheckfinish = YES;
}

-(void)clearPicture
{
    _iv.image = [UIImage imageNamed:@"load.jpg"];
}
@end
