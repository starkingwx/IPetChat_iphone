//
//  TestApiViewController.h
//  IPetChat
//
//  Created by king star on 13-12-21.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClockChart.h"

@interface TestApiViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet ClockChart *motionCircleChart;

- (IBAction)testQueryLatestPetInfo:(id)sender;

- (IBAction)testQueryMotionStatInfo:(id)sender;

- (IBAction)testOrderDeviceServer:(id)sender;
@end
