//
//  IPetChat
//
//  Created by XF on 13-11-7.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewController.h"

@interface CommunityViewController : UITableViewController

@property (retain, nonatomic) IBOutlet ListViewController *listViewController;
@property (retain, nonatomic) NSArray *contentArray;
@end
