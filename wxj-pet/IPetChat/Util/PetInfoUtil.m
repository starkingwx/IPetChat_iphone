//
//  PetInfoUtil.m
//  IPetChat
//
//  Created by king star on 14-1-12.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import "PetInfoUtil.h"
#import "UserBean+Device.h"

static const long DaySeconds = 24 * 60 * 60;
static const NSInteger TotalMotionIndex = (0.9 + 1.2 +1.6 + 1.8)*100*2;

@implementation PetInfoUtil

+ (NSString *)getBreedByType:(NSNumber *)type {
    NSArray *pettypes = [NSArray arrayWithObjects:@"黄金猎犬",@"哈士奇",@"贵宾（泰迪）",@"萨摩耶",@"博美",@"雪纳瑞",@"苏格兰牧羊犬",@"松狮",@"京巴",@"其他犬种", nil];
    if ([type intValue] >= 0 && [type intValue] < pettypes.count) {
        return [pettypes objectAtIndex:[type intValue]];
    } else {
        return nil;
    }
    
}

+ (NSNumber *)getAgeByBirthday:(NSNumber *)birthday {
    if (birthday == nil) {
        return [NSNumber numberWithInt:0];
    }
    NSDate *today = [NSDate date];
    NSDate *birthDate = [NSDate dateWithTimeIntervalSince1970:birthday.longLongValue / 1000];
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calender components:NSMonthCalendarUnit fromDate:birthDate toDate:today options:0];
    NSNumber *ret = [NSNumber numberWithInt:comps.month];
    return ret;
}

+ (BOOL)isPetInfoSet {
    UserBean *user = [[UserManager shareUserManager] userBean];
    PetInfo *petInfo = user.petInfo;
    if (petInfo == nil || petInfo.petId == nil) {
        return NO;
    }
    return YES;
}

+ (float)parsePetRestPercentage:(unsigned long)vitality {
    return (vitality & 0x000000FF) * 1.0f / 100;
}

+ (float)parsePetWalkPercentage:(unsigned long)vitality {
    return ((vitality & 0x0000FF00) >> 8) * 1.0f / 100;
}

+ (float)parsePetRunSlightlyPercentage:(unsigned long)vitality {
    return ((vitality & 0x00FF0000) >> 16) * 1.0f / 100;
}

+ (float)parsePetRunHeavilyPercentage:(unsigned long)vitality {
    return ((vitality & 0xFF000000) >> 24) * 1.0f / 100;
}

+ (NSInteger)calculateMotionPoint:(unsigned long)vitality {
    float rest = [self parsePetRestPercentage:vitality];
    float walk = [self parsePetWalkPercentage:vitality];
    float runSlightly = [self parsePetRunSlightlyPercentage:vitality];
    float runHeavily = [self parsePetRunHeavilyPercentage:vitality];
    NSLog(@"rest: %f walk: %f runslightly: %f runheavily: %f", rest, walk, runSlightly, runHeavily);
    NSInteger point = (0.9 * rest + 1.2 * walk + 1.6 * runSlightly + 1.8 * runHeavily) * 100 * 2;
    return point;
}

+ (float)calculateAvgMotionPercentage:(unsigned long)vitality {
    NSInteger point = [self calculateMotionPoint:vitality];
    float percentage = (point * 1.0f) / TotalMotionIndex;
    NSLog(@"total: %d point: %d percentage: %f", TotalMotionIndex, point, percentage);
    return percentage;
}

+ (unsigned long)calculate4MotionPartPercentageByWalkTime:(unsigned long)walkTime andRunSlightlyTime:(unsigned long)runSlightlyTime andRunHeavily:(unsigned long)runHeavilyTime {
    unsigned long walkPercent = (walkTime * 100 / DaySeconds);
    unsigned long runSlightlyPercent = (runSlightlyTime * 100 / DaySeconds);
    unsigned long runHeavilyPercent = (runHeavilyTime * 100 / DaySeconds);
    unsigned long restPercent = 100 - walkPercent - runSlightlyPercent - runHeavilyPercent;
    unsigned long vitality = restPercent | (walkPercent << 8) | (runSlightlyPercent << 16) | (runHeavilyPercent << 24);
    NSLog(@"rest: %ld walk: %ld runslightly: %ld runheavily: %ld, vitality: %ld", restPercent, walkPercent, runSlightlyPercent, runHeavilyPercent, vitality);
    return vitality;
//    NSArray *ret = [NSArray arrayWithObjects:[NSNumber numberWithInt:restPercent], [NSNumber numberWithInt:walkPercent], [NSNumber numberWithInt:runSlightlyPercent], [NSNumber numberWithInt:runHeavilyPercent], nil];
//    return ret;
}

@end
