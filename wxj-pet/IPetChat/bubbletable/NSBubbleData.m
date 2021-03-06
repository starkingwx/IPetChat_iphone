//
//  NSBubbleData.m
//
//  Created by Alex Barinov
//  StexGroup, LLC
//  http://www.stexgroup.com
//
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "NSBubbleData.h"

@implementation NSBubbleData

@synthesize date = _date;
@synthesize type = _type;
@synthesize text = _text;
@synthesize avatar = _avatar;

+ (id)dataWithText:(NSString *)text andDate:(NSDate *)date andType:(NSBubbleType)type andAvatar:(NSString *)avatar
{
    return [[[NSBubbleData alloc] initWithText:text andDate:date andType:type andAvatar:avatar] autorelease];
}

- (id)initWithText:(NSString *)initText andDate:(NSDate *)initDate andType:(NSBubbleType)initType andAvatar:(NSString *)initAvatar
{
    self = [super init];
    if (self)
    {
        _text = [initText retain];
        if (!_text || [_text isEqualToString:@""]) _text = @" ";
        
        _date = [initDate retain];
        _type = initType;
        _avatar = [initAvatar retain];
    }
    return self;
}

- (void)dealloc
{
    [_date release];
	_date = nil;
	[_text release];
	_text = nil;
    [_avatar release];
    _avatar = nil;
    [super dealloc];
}

@end
