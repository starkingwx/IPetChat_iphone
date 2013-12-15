//
//  ConcernPetViewController.h
//  IPetChat
//
//  Created by orangeskiller on 13-11-20.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PetInfoViewController.h"

@interface ConcernPetViewController : UIViewController

@property (retain, nonatomic) IBOutlet UITextField *phonenumTextField;
@property (retain, nonatomic) IBOutlet PetInfoViewController *petInfoAndConernViewController;
@end
