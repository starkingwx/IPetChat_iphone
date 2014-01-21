//
//  PetInfoUtil.h
//  IPetChat
//
//  Created by king star on 14-1-12.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PetInfoUtil : NSObject

+ (NSString *)getBreedByType:(NSNumber *)type;
+ (NSNumber *)getAgeByBirthday:(NSNumber *)birthday;

/**
 * Whether user has set pet info
 */
+ (BOOL)isPetInfoSet;

+ (float)parsePetRestPercentage:(long)vitality;
+ (float)parsePetWalkPercentage:(long)vitality;
+ (float)parsePetRunSlightlyPercentage:(long)vitality;
+ (float)parsePetRunHeavilyPercentage:(long)vitality;

+ (NSInteger)calculateMotionPoint:(long)vitality;
+ (float)calculateAvgMotionPercentage:(long)vitality;
@end
