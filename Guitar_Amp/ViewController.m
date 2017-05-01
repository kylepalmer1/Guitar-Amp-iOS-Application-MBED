//
//  ViewController.m
//  Guitar_Amp
//
//  Created by Kyle Palmer on 4/14/17.
//  Copyright © 2017 Kyle Palmer. All rights reserved.
//

#import "ViewController.h"
#import "BTDiscovery.h"
#import "BTService.h"


@interface ViewController ()
@property (strong, nonatomic) NSTimer *timerTXDelay;
@property (nonatomic) BOOL allowTX;
@end
uint16_t bpm = 0;
UIColor *color1;
@implementation ViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Rotate slider to vertical position
    UIView *superView = self.positionSlider.superview;
    [self.positionSlider removeFromSuperview];
    [self.positionSlider removeConstraints:self.view.constraints];
    //self.positionSlider.translatesAutoresizingMaskIntoConstraints = YES;
    //self.positionSlider.transform = CGAffineTransformMakeRotation(M_PI_2);
    [superView addSubview:self.positionSlider];
    self.enabled.hidden = YES;
    self.disabled.hidden = NO;
    // Set thumb image on slider
    _positionSlider.value = 15;
    [self.positionSlider setThumbImage:[UIImage imageNamed:@"fingertip"] forState:UIControlStateNormal];
    [self.positionSlider2 setThumbImage:[UIImage imageNamed:@"fingertip"] forState:UIControlStateNormal];
    [self.positionSlider3 setThumbImage:[UIImage imageNamed:@"fingertip"] forState:UIControlStateNormal];
    _volume.text = [NSString stringWithFormat: @"%.00f", 50.00];
    _delay.text = [NSString stringWithFormat: @"%.00f", 0.00];
    _distortion.text = [NSString stringWithFormat: @"%.00f", 0.00];
    _update.text = @"NONE";
    [self sendPosition1:(uint8_t)14];
    [self sendPosition2:(uint8_t)31];
    self.allowTX = YES;
    
    // Watch Bluetooth connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:RWT_BLE_SERVICE_CHANGED_STATUS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUpdatedData:)
                                                 name:@"DataUpdated"
                                               object:nil];
    // Start the Bluetooth discovery process
    [BTDiscovery sharedInstance];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RWT_BLE_SERVICE_CHANGED_STATUS_NOTIFICATION object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopTimerTXDelay];
}

#pragma mark - IBActions

- (IBAction)positionSliderChanged:(UISlider *)sender {
    // Since the slider value range is from 0 to 180, it can be sent directly to the Arduino board
    
    [self sendPosition1:(uint8_t)sender.value];
}
- (IBAction)positionSliderReleased:(UISlider *)sender {
    // Since the slider value range is from 0 to 180, it can be sent directly to the Arduino board
    [sender setContinuous: NO];
    //uint8_t newValue = self.positionSlider.value + 1000;
    int holder =(uint8_t)sender.value;
    float percent = (float)holder/30 * 100;
    _volume.text = [NSString stringWithFormat: @"%.00f", percent];
    [self sendPosition1:(uint8_t)sender.value];
    //[self sendPosition:newValue];
}
- (IBAction)positionSliderReleased2:(UISlider *)sender1 {
    // Since the slider value range is from 0 to 180, it can be sent directly to the Arduino board
    [sender1 setContinuous: NO];
    //uint8_t newValue = self.positionSlider.value + 1000;
    int holder =(uint8_t)sender1.value;
    float percent = ((float)holder-30)/30 * 100;
    if(holder == 31)
    {
        percent = 0;
    }
    _delay.text = [NSString stringWithFormat: @"%.00f", percent];
    [self sendPosition2:(uint8_t)sender1.value];
    //[self sendPosition:newValue];
}
- (IBAction)positionSliderReleased3:(UISlider *)sender2 {
    // Since the slider value range is from 0 to 180, it can be sent directly to the Arduino board
    [sender2 setContinuous: NO];
    //uint8_t newValue = self.positionSlider.value + 1000;
    int holder =(uint8_t)sender2.value;
    float percent = ((float)holder-60)/30 * 100;
    if(holder == 61)
    {
        percent = 0;
    }
    _distortion.text = [NSString stringWithFormat: @"%.00f", percent];
    [self sendPosition3:(uint8_t)sender2.value];
    //[self sendPosition:newValue];
}


#pragma mark - Private

- (void)connectionChanged:(NSNotification *)notification {
    // Connection status changed. Indicate on GUI.
    BOOL isConnected = [(NSNumber *) (notification.userInfo)[@"isConnected"] boolValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Set image based on connection status
        self.imgBluetoothStatus.image = isConnected ? [UIImage imageNamed:@"Bluetooth_Connected"]: [UIImage imageNamed:@"Bluetooth_Disconnected"];
        /*if(!isConnected)
        {
            self.imgBluetoothStatus.image = [UIImage imageNamed:@"Bluetooth_Disconnected"];
        }*/

        /*if (isConnected) {
            // Send current slider position
            [self sendPosition:(uint8_t)self.positionSlider.value];
        }*/
    });
}


- (void)sendPosition1:(uint8_t)position {
    // Valid position range: 0 to 180
    static uint8_t lastPosition = 255;
    if (!self.allowTX) { // 1
        return;
    }
    
    // Validate value
    if (position == lastPosition) { // 2
        return;
    }
    else if ((position < 0) || (position > 90)) { // 3
        return;
    }
    
    // Send position to BLE Shield (if service exists and is connected)
    if ([BTDiscovery sharedInstance].bleService) { // 4
        [[BTDiscovery sharedInstance].bleService writePosition:position];
        lastPosition = position;
        
        // Start delay timer
        self.allowTX = NO;
        if (!self.timerTXDelay) { // 5
            self.timerTXDelay = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerTXDelayElapsed) userInfo:nil repeats:NO];
        }
    }
     
}

- (void)sendPosition2:(uint8_t)position {
    // Valid position range: 0 to 180
    static uint8_t lastPosition = 255;
    
    if (!self.allowTX) { // 1
        return;
    }
    
    // Validate value
    if (position == lastPosition) { // 2
        return;
    }
    else if ((position < 0) || (position > 90)) { // 3
        return;
    }
    
    // Send position to BLE Shield (if service exists and is connected)
    if ([BTDiscovery sharedInstance].bleService) { // 4
        [[BTDiscovery sharedInstance].bleService writePosition:position];
        lastPosition = position;
        
        // Start delay timer
        self.allowTX = NO;
        if (!self.timerTXDelay) { // 5
            self.timerTXDelay = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerTXDelayElapsed) userInfo:nil repeats:NO];
        }
    }
    
}

- (void)sendPosition3:(uint8_t)position {
    // Valid position range: 0 to 180
    static uint8_t lastPosition = 255;
    
    if (!self.allowTX) { // 1
        return;
    }
    
    // Validate value
    if (position == lastPosition) { // 2
        return;
    }
    else if ((position < 0) || (position > 90)) { // 3
        return;
    }
    
    // Send position to BLE Shield (if service exists and is connected)
    if ([BTDiscovery sharedInstance].bleService) { // 4
        [[BTDiscovery sharedInstance].bleService writePosition:position];
        lastPosition = position;
        
        // Start delay timer
        self.allowTX = NO;
        if (!self.timerTXDelay) { // 5
            self.timerTXDelay = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerTXDelayElapsed) userInfo:nil repeats:NO];
        }
    }
}
- (void)sendTuner1:(uint8_t)position {
    // Valid position range: 0 to 180
    if (!self.allowTX) { // 1
        return;
    }
    // Send position to BLE Shield (if service exists and is connected)
    if ([BTDiscovery sharedInstance].bleService) { // 4
        [[BTDiscovery sharedInstance].bleService writePosition:position];
        
        // Start delay timer
        self.allowTX = NO;
        if (!self.timerTXDelay) { // 5
            self.timerTXDelay = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerTXDelayElapsed) userInfo:nil repeats:NO];
        }
    }
    
}

-(IBAction)toggleSwitch1:(id)sender
{
    [self sendTuner1:(uint8_t)200];
}

-(void)handleUpdatedData:(NSNotification *)notification {
    NSData *purchased = [notification object];
    const uint8_t *reportData = [purchased bytes];
    //_distortion.text = [NSString stringWithFormat:@"%s", reportData];
    NSString *titleStr =[NSString stringWithFormat:@"%s", reportData];
    int value = [titleStr intValue];
    if(value < 20)
    {
        titleStr = @"E (Low)";
        //NSLog(@"%@\n",[NSString stringWithFormat:@"%d",value%10]);
        if(value < 10)
        {
        }
        else if(value%10 == 1)
        {
            color1 = [UIColor redColor];
            NSLog(@"inside1");
        }
        else if(value%10 == 2)
        {
            color1 = [UIColor blueColor];
            NSLog(@"inside2");
        }
        else
        {
            color1 = [UIColor greenColor];
            NSLog(@"inside3");
        }
    }
    else if(value < 30)
    {
        titleStr = @"A";
        if(value < 10)
        {
        }
        else if(value%10 == 1)
        {
            color1 = [UIColor redColor];
            NSLog(@"inside");
        }
        else if(value%10 == 2)
        {
            color1 = [UIColor blueColor];
        }
        else
        {
            color1 = [UIColor greenColor];
        }
    }
    else if(value < 40)
    {
        titleStr = @"D";
        if(value < 10)
        {
        }
        else if(value%10 == 1)
        {
            color1 = [UIColor redColor];
            NSLog(@"inside");
        }
        else if(value%10 == 2)
        {
            color1 = [UIColor blueColor];
        }
        else
        {
            color1 = [UIColor greenColor];
        }
    }
    else if(value < 50)
    {
        titleStr = @"G";
        if(value < 10)
        {
        }
        else if(value%10 == 1)
        {
            color1 = [UIColor redColor];
            NSLog(@"inside");
        }
        else if(value%10 == 2)
        {
            color1 = [UIColor blueColor];
        }
        else
        {
            color1 = [UIColor greenColor];
        }
    }
    else if(value < 60)
    {
        titleStr = @"B";
        if(value < 10)
        {
        }
        else if(value%10 == 1)
        {
            color1 = [UIColor redColor];
            NSLog(@"inside");
        }
        else if(value%10 == 2)
        {
            color1 = [UIColor blueColor];
        }
        else
        {
            color1 = [UIColor greenColor];
        }
    }
    else if(value < 70)
    {
        titleStr = @"E (High)";
        if(value < 10)
        {
        }
        else if(value%10 == 1)
        {
            color1 = [UIColor redColor];
            NSLog(@"inside");
        }
        else if(value%10 == 2)
        {
            color1 = [UIColor blueColor];
        }
        else
        {
            color1 = [UIColor greenColor];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.update.textColor = color1;
        [self.update setText:titleStr];
    });

}


- (void)timerTXDelayElapsed {
    self.allowTX = YES;
    [self stopTimerTXDelay];
    
    // Send current slider position
    //[self sendPosition:(uint8_t)self.positionSlider.value];
}

- (void)stopTimerTXDelay {
    if (!self.timerTXDelay) {
        return;
    }
    
    [self.timerTXDelay invalidate];
    self.timerTXDelay = nil;
}

@end
