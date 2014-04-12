//
//  MotionStat.m
//  IPetChat
//
//  Created by king star on 14-4-12.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import "MotionStat.h"

@implementation MotionStat

@synthesize type;
@synthesize count;

- (id)init {
    self = [super init];
    if (self) {
        self.type = 0;
        self.count = 0;
    }
    return self;
}

@end
