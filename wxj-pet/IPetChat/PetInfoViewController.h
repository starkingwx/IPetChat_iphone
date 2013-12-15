//
//  PetInfoViewController.h
//  IPetChat
//
//  Created by XF on 13-11-8.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsynImageView.h"
#import "LeaveMsgViewController.h"

@interface PetInfoViewController : UIViewController

@property (assign, nonatomic) NSInteger type;
@property (retain, nonatomic) NSDictionary *contentDic;
@property (assign, nonatomic) long petId;
@property (retain, nonatomic) IBOutlet AsynImageView *avatar;
@property (retain, nonatomic) IBOutlet UILabel *nickname;
@property (retain, nonatomic) IBOutlet UIImageView *sex;
@property (retain, nonatomic) IBOutlet UILabel *detail;
@property (retain, nonatomic) IBOutlet UIButton *leavemsgButton;
@property (retain, nonatomic) IBOutlet UIButton *concernpetButton;
@property (retain, nonatomic) UIView *moreactionView;
@property (retain, nonatomic) IBOutlet UIScrollView *picsScrollView;
@property (retain, nonatomic) IBOutlet LeaveMsgViewController *leavemsgViewController;

- (IBAction)leavemsgButtonClick:(id)sender;
- (IBAction)concernpetButtonClick:(id)sender;
@end
