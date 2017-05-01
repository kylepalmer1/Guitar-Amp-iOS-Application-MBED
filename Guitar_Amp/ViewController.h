//
//  ViewController.h
//  Guitar_Amp
//
//  Created by Kyle Palmer on 4/14/17.
//  Copyright © 2017 Kyle Palmer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISlider *positionSlider;
@property (weak, nonatomic) IBOutlet UISlider *positionSlider2;
@property (weak, nonatomic) IBOutlet UISlider *positionSlider3;
@property (weak, nonatomic) IBOutlet UIImageView *imgBluetoothStatus;
@property (weak, nonatomic) IBOutlet UIImageView *guitarNeck;
@property (weak, nonatomic) IBOutlet UILabel *note;
@property (weak, nonatomic) IBOutlet UILabel *volume;
@property (weak, nonatomic) IBOutlet UILabel *delay;
@property (weak, nonatomic) IBOutlet UILabel *distortion;
@property (weak, nonatomic) IBOutlet UILabel *other;
@property (weak, nonatomic) IBOutlet UILabel *enabled;
@property (weak, nonatomic) IBOutlet UILabel *disabled;
@property (weak, nonatomic) IBOutlet UILabel *heartRateBPM;
@property (weak, nonatomic) IBOutlet UILabel *update;
@property (weak, nonatomic) IBOutlet UILabel *leftTune;
@property (weak, nonatomic) IBOutlet UILabel *rightTune;
@property (weak, nonatomic) IBOutlet UISwitch *tuner;
- (IBAction)positionSliderChanged:(UISlider *)sender;
-(IBAction)toggleSwitch1:(id)sender;

@end

