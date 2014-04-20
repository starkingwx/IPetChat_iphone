//
//  PetMotionStatViewController.h
//  IPetChat
//
//  Created by king star on 14-1-5.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsynImageView.h"
#import "ClockChart.h"
#import "BarChartView.h"
#import "LineBarChart.h"

@interface PetMotionStatViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *avatarImageViewContainer;
@property (strong, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (strong, nonatomic) IBOutlet UILabel *breedLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *heightLabel;
@property (strong, nonatomic) IBOutlet UILabel *weightLabel;

@property (strong, nonatomic) IBOutlet UIView *todayTabBody;
@property (strong, nonatomic) IBOutlet UIView *historyTabBody;


@property (strong, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *runningTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *walkTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *restTimeLabel;
@property (strong, nonatomic) IBOutlet ClockChart *clockChart;



- (IBAction)selectTodayStat:(id)sender;
- (IBAction)selectHistoryStat:(id)sender;

@end
