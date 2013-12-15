//
//  sendphotoController.h
//  IPetChat
//
//  Created by WXJ on 13-12-2.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageRootViewController.h"

@interface sendphotoController : UITableViewController<UITextFieldDelegate>

@property (retain, nonatomic) NSArray *contentArray;
@property (retain, nonatomic) IBOutlet UITextField *photodescribefield;
@property (retain, nonatomic) IBOutlet UIImageView *sendphotoimage;
@property (retain, nonatomic) IBOutlet UIAlertView *basealert;

@end
