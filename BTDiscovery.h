//
//  BTDiscovery.h
//
//  Created by Owen Lacy Brown on 5/21/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//  edited by: Kyle Palmer 5/1/2017

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTService.h"
#import "ViewController.h"


@interface BTDiscovery : NSObject <CBCentralManagerDelegate>

+ (instancetype)sharedInstance;

@property (strong, nonatomic) BTService *bleService;

@end
