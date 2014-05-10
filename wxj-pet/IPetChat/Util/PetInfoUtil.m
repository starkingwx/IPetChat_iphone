//
//  PetInfoUtil.m
//  IPetChat
//
//  Created by king star on 14-1-12.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import "PetInfoUtil.h"
#import "UserBean+Device.h"
#import "Constant.h"


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
}


+ (NSDictionary *)parse288bitsMotionData:(NSString *)motionData {
    if (motionData == nil || motionData.length <= 0) {
        return nil;
    }
    
    NSMutableDictionary *totalDic = [NSMutableDictionary dictionaryWithCapacity:6];
    NSMutableArray *partStatArray = [NSMutableArray arrayWithCapacity:10];
    
    MotionStat *offline = [[MotionStat alloc] init];
    offline.type = MT_OFFLINE;
    MotionStat *online = [[MotionStat alloc] init];
    online.type = MT_ONLINE;
    MotionStat *rest = [[MotionStat alloc] init];
    rest.type = MT_REST;
    MotionStat *walk = [[MotionStat alloc] init];
    walk.type = MT_WALK;
    MotionStat *play = [[MotionStat alloc] init];
    play.type = MT_PLAY;
    MotionStat *running = [[MotionStat alloc] init];
    running.type = MT_RUNNING;
    
    [totalDic setObject:offline forKey:KEY_OFFLINE];
    [totalDic setObject:online forKey:KEY_ONLINE];
    [totalDic setObject:rest forKey:KEY_REST];
    [totalDic setObject:walk forKey:KEY_WALK];
    [totalDic setObject:play forKey:KEY_PLAY];
    [totalDic setObject:running forKey:KEY_RUNNING];
    
    NSInteger previousType = -1;
    NSInteger count = 0;
    for (NSInteger i = 0; i < motionData.length; i++) {
        unichar typeChar = [motionData characterAtIndex:i];
        NSInteger type = typeChar - '0';
        
        // calcuate total statistics
        switch (type) {
            case MT_OFFLINE:
                offline.count++;
                break;
            case MT_ONLINE:
                online.count++;
                break;
            case MT_REST:
                rest.count++;
                break;
            case MT_WALK:
                walk.count++;
                break;
            case MT_PLAY:
                play.count++;
                break;
            case MT_RUNNING:
                running.count++;
                break;
            default:
                break;
        }
        
        // calculate part statistics
        if (previousType == -1) {
            count = 1;
            previousType = type;
        } else if (type == previousType) {
            count++;
        } else {
            // save the previous type and count
            MotionStat *motionStat = [[MotionStat alloc] init];
            motionStat.type = previousType;
            motionStat.count = count;
            [partStatArray addObject:motionStat];
            
            // count new type
            count = 1;
            previousType = type;
        }
    }
    MotionStat *motionStat = [[MotionStat alloc] init];
    motionStat.type = previousType;
    motionStat.count = count;
    [partStatArray addObject:motionStat];
    
    
    rest.timeStr = [self generateTimeStringFromMotionStat:rest];
    walk.timeStr = [self generateTimeStringFromMotionStat:walk];
    play.timeStr = [self generateTimeStringFromMotionStat:play];
    running.timeStr = [self generateTimeStringFromMotionStat:running];
    
    NSDictionary *motionStatDataDic = [NSDictionary dictionaryWithObjectsAndKeys:totalDic, KEY_TOTAL_STAT, partStatArray, KEY_PART_STAT, nil];
    
    return motionStatDataDic;
}

+ (NSString *)generateTimeStringFromMotionStat:(MotionStat *)motionStat {
    long time = motionStat.count * 5; // minutes
    NSString *timeStr = nil;
    timeStr = [NSString stringWithFormat:@"%ld分", time];
    return timeStr;
}
@end
