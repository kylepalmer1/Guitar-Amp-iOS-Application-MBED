//
//  BTService.m
//
//  Created by Owen Lacy Brown on 5/21/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//  edited by: Kyle Palmer 5/1/2017

#import "BTService.h"
#import "ViewController.h"


@interface BTService()
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) CBCharacteristic *positionCharacteristic;
@end

@implementation BTService

#pragma mark - Lifecycle

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
  self = [super init];
  if (self) {
    self.peripheral = peripheral;
    [self.peripheral setDelegate:self];
  }
  return self;
}

- (void)dealloc {
  [self reset];
}

- (void)startDiscoveringServices {
  [self.peripheral discoverServices:@[RWT_BLE_SERVICE_UUID]];
}

- (void)reset {
  
  if (self.peripheral) {
    self.peripheral = nil;
  }
  
  // Deallocating therefore send notification
  [self sendBTServiceNotificationWithIsBluetoothConnected:NO];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
  NSArray *services = nil;
  NSArray *uuidsForBTService = @[RWT_POSITION_CHAR_UUID];
  
  if (peripheral != self.peripheral) {
    //NSLog(@"Wrong Peripheral.\n");
    return ;
  }
  
  if (error != nil) {
    //NSLog(@"Error %@\n", error);
    return ;
  }
  
  services = [peripheral services];
  if (!services || ![services count]) {
    //NSLog(@"No Services");
    return ;
  }
  
  for (CBService *service in services) {
    if ([[service UUID] isEqual:RWT_BLE_SERVICE_UUID]) {
      [peripheral discoverCharacteristics:uuidsForBTService forService:service];
    }
      if ([[service UUID] isEqual:RX_POSITION_CHAR_UUID]) {
          [peripheral discoverCharacteristics:uuidsForBTService forService:service];
      }
  }
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service: %@", service.UUID);
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
  NSArray     *characteristics    = [service characteristics];
  
  if (peripheral != self.peripheral) {
    //NSLog(@"Wrong Peripheral.\n");
    return ;
  }
  
  if (error != nil) {
    //NSLog(@"Error %@\n", error);
    return ;
  }
    
  
  for (CBCharacteristic *characteristic in characteristics) {
    if ([[characteristic UUID] isEqual:RWT_POSITION_CHAR_UUID]) {
      self.positionCharacteristic = characteristic;
      
      // Send notification that Bluetooth is connected and all required characteristics are discovered
      [self sendBTServiceNotificationWithIsBluetoothConnected:YES];
    }
    if ([[characteristic UUID] isEqual:RX_POSITION_CHAR_UUID]) {
        NSLog(@"INSIDE");
        [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
  }
}
#pragma mark - Private

- (void)writePosition:(UInt8)position {
    // See if characteristic has been discovered before writing to it
    if (!self.positionCharacteristic) {
        return;
    }
    
    NSData *data = nil;
    data = [NSData dataWithBytes:&position length:sizeof(position)];
    [self.peripheral writeValue:data
              forCharacteristic:self.positionCharacteristic
                           type:CBCharacteristicWriteWithResponse];
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData *data = [characteristic value];      // 1
    const uint8_t *reportData = [data bytes];
    uint16_t bpm = 0;
    
    if ((reportData[0] & 0x01) == 0) {          // 2
        // Retrieve the BPM value for the Heart Rate Monitor
        bpm = reportData[1];
    }
    else {
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));  // 3
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DataUpdated" object:data];
    
}

- (void)sendBTServiceNotificationWithIsBluetoothConnected:(BOOL)isBluetoothConnected {
  NSDictionary *connectionDetails = @{@"isConnected": @(isBluetoothConnected)};
  [[NSNotificationCenter defaultCenter] postNotificationName:RWT_BLE_SERVICE_CHANGED_STATUS_NOTIFICATION object:self userInfo:connectionDetails];
}

@end
