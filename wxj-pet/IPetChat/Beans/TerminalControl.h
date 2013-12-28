//
//  TerminalControl.h
//  IPetChat
//
//  Created by king star on 13-12-28.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RollCall.h"

@interface TerminalControl : NSObject
@property (nonatomic) NSString *cmdtype;
@property (nonatomic) NSString *deviceno;
@property (nonatomic) RollCall *roll_call;
@end
