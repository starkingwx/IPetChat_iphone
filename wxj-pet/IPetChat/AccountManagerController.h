//
//  AccountManagerController.h
//  IPetChat
//
//  Created by WXJ on 13-11-25.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountManagerController : UIViewController<UITextFieldDelegate>



@property (retain, nonatomic) IBOutlet UITableView *accountshow;
@property (retain, nonatomic) IBOutlet UILabel *username;
@property (retain, nonatomic) IBOutlet UIView *backview;
@property (retain, nonatomic) IBOutlet UITextField *oldpwd;
@property (retain, nonatomic) IBOutlet UITextField *newpwd;
@property (retain, nonatomic) IBOutlet UITextField *confirmpwd;
@property (retain, nonatomic) IBOutlet UIViewController *modifyctrl;
@end
