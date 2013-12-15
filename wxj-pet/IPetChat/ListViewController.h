//
//  ListViewController.h
//  IPetChat
//
//  Created by XF on 13-11-7.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PetInfoViewController.h"
#import "ConcernPetViewController.h"
#import "LeaveMsgViewController.h"

@interface ListViewController : UITableViewController <UISearchBarDelegate>

@property (assign, nonatomic) NSInteger stylenum;
@property (retain, nonatomic) IBOutlet PetInfoViewController *petInfoViewController;
@property (retain, nonatomic) IBOutlet ConcernPetViewController *concernPetViewController;
@property (retain, nonatomic) IBOutlet LeaveMsgViewController *leaveMsgViewController;
@property (retain, nonatomic) NSMutableArray *indexedArray;
@property (retain, nonatomic) NSMutableDictionary *sortedDictionary;
@property (retain, nonatomic) NSArray *contentArray1;
@property (retain, nonatomic) NSArray *contentArray2;
@property (retain, nonatomic) NSArray *contentArray3;
@property (retain, nonatomic) NSArray *originArray;

@end
