//
//  LeaveMsgViewController.h
//  IPetChat
//
//  Created by orangeskiller on 13-11-27.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"
@class UIBubbleTableView;

@interface LeaveMsgViewController : UIViewController <UIBubbleTableViewDataSource>
@property (assign, nonatomic) NSInteger type;
@property (retain, nonatomic) IBOutlet UIBubbleTableView *bubbleTable;
@property (retain, nonatomic) NSMutableArray *bubbleData;
@property (assign, nonatomic) long msgID;
@property (assign, nonatomic) long petID;

@property (retain, nonatomic) IBOutlet UIView *inputandsendView;
@property (retain, nonatomic) IBOutlet UIImageView *backimg1;
@property (retain, nonatomic) IBOutlet UIImageView *backimg2;
@property (retain, nonatomic) IBOutlet UIButton *sendbutton;
@property (retain, nonatomic) IBOutlet UITextField *textfield;
- (IBAction)sendtext:(id)sender;
@end
