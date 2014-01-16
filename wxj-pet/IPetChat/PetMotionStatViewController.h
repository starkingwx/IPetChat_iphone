//
//  PetMotionStatViewController.h
//  IPetChat
//
//  Created by king star on 14-1-5.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsynImageView.h"
#import "XYPieChart.h"
#import "BarChartView.h"

@interface PetMotionStatViewController : UIViewController <XYPieChartDataSource>
@property (strong, nonatomic) IBOutlet UIView *avatarImageViewContainer;
@property (strong, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (strong, nonatomic) IBOutlet UILabel *breedLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *heightLabel;
@property (strong, nonatomic) IBOutlet UILabel *weightLabel;
@property (strong, nonatomic) IBOutlet UILabel *usageCountLabel;
@property (strong, nonatomic) IBOutlet UIView *todayTabBody;
@property (strong, nonatomic) IBOutlet UIView *historyTabBody;
@property (strong, nonatomic) IBOutlet XYPieChart *piechart;
@property (strong, nonatomic) IBOutlet BarChartView *barChart;


- (IBAction)selectTodayStat:(id)sender;
- (IBAction)selectHistoryStat:(id)sender;

@end
