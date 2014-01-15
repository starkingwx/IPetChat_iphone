//
//  MainPageViewController.h
//  IPetChat
//
//  Created by king star on 14-1-4.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsynImageView.h"

@interface MainPageViewController : UIViewController

@property (strong, nonatomic) IBOutlet AsynImageView *avatarImageView;

@property (strong, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (strong, nonatomic) IBOutlet UIProgressView *powerProgressView;
@property (strong, nonatomic) IBOutlet UILabel *powerLabel;

@property (strong, nonatomic) IBOutlet UIProgressView *motionScoreProgressView;
@property (strong, nonatomic) IBOutlet UILabel *motionScoreLabel;

@property (strong, nonatomic) IBOutlet UILabel *breedLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *heightLabel;
@property (strong, nonatomic) IBOutlet UILabel *weightLabel;
@property (strong, nonatomic) IBOutlet UILabel *areaLabel;
@property (strong, nonatomic) IBOutlet UILabel *placeOftenGoLabel;

- (IBAction)locatePet:(id)sender;


@end
