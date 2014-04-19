//
//  Constant.h
//  IPetChat
//
//  Created by king star on 13-12-15.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#ifndef IPetChat_Constant_h
#define IPetChat_Constant_h

#import <Foundation/Foundation.h>

#define CHINESE_FONT            @"ArialMT"
#define CHINESE_BOLD_FONT       @"Arial-BoldMT"
#define CHARACTER_FONT          @"ArialMT"
#define CHARACTER_BOLD_FONT     @"Arial-BoldMT"


// color
#define BLUE                [UIColor colorWithIntegerRed:0 integerGreen:171 integerBlue:223 alpha:1]
#define GREEN               [UIColor colorWithIntegerRed:166 integerGreen:206 integerBlue:57 alpha:1]
#define YELLOW              [UIColor colorWithIntegerRed:254 integerGreen:194 integerBlue:14 alpha:1]
#define ORANGE              [UIColor colorWithIntegerRed:246 integerGreen:136 integerBlue:32 alpha:1]

#define COLOR_OFFLINE       [UIColor colorWithIntegerRed:222 integerGreen:222 integerBlue:220 alpha:1]
#define COLOR_ONLINE        COLOR_OFFLINE
#define COLOR_REST          [UIColor colorWithIntegerRed:141 integerGreen:179 integerBlue:228 alpha:1]  
#define COLOR_WALK          [UIColor colorWithIntegerRed:169 integerGreen:241 integerBlue:221 alpha:1]
#define COLOR_PLAY          [UIColor colorWithIntegerRed:254 integerGreen:251 integerBlue:110 alpha:1]
#define COLOR_RUNNING       [UIColor colorWithIntegerRed:248 integerGreen:195 integerBlue:1 alpha:1]


#define BLUE_VALUE          @"00abdf"
#define GREEN_VALUE         @"a6ce39"
#define YELLOW_VALUE        @"fec20e"
#define ORANGE_VALUE        @"f68820"
#define WHITE_VALUE         @"ffffff"
static NSString *RESULT = @"result";

// Account CONSTANTS
static NSString *PASSWORD = @"password";
static NSString *USERKEY = @"userkey";
static NSString *USERNAME = @"username";


// Device Fields
static NSString *ID = @"id";
static NSString *TERMID = @"termid";
static NSString *DAYTIME = @"daytime";
static NSString *TYPE = @"type";
static NSString *ALARM_SIZE = @"alarmsize";
static NSString *CRITIC_ALARM = @"criticalarm";
static NSString *DISTANCE0 = @"distance0";
static NSString *DISTANCEN = @"distancen";
static NSString *VITALITY10 = @"vitality10";
static NSString *VITALITY1N = @"vitality1n";
static NSString *VITALITY20 = @"vitality20";
static NSString *VITALITY2N = @"vitality2n";
static NSString *VITALITY30 = @"vitality30";
static NSString *VITALITY3N = @"vitality3n";
static NSString *VITALITY40 = @"vitality40";
static NSString *VITALITY4N = @"vitality4n";
static NSString *X = @"x";
static NSString *Y = @"y";
static NSString *POSID = @"posid";
static NSString *SPEED = @"speed";
static NSString *HEIGHT = @"height";
static NSString *DIRECTION = @"direction";
static NSString *TERMTIME = @"termtime";
static NSString *SERVTIME = @"servtime";
static NSString *IOPORT = @"ioport";
static NSString *STATUS = @"status";
static NSString *ALARM = @"alarm";
static NSString *FENCE = @"fence";
static NSString *FENCEID = @"fenceid";
static NSString *MAINVOLTAGE = @"mainvoltage";
static NSString *CELLVOLTAGE = @"cellvoltage";
static NSString *TERMPERATURE = @"temperature";
static NSString *DISTANCE = @"distance";
static NSString *VITALITY = @"vitality";
static NSString *ADDRESS = @"roughaddr";
static NSString *TICKACT = @"tickact";

// Database Opertaion
static NSString *QUERY = @"QUERY";

// Cmd Type
static NSString *ARCHIVE_OPERATION = @"ARCHIVE_OPERATION";
static NSString *TERMINAL_CONTROL = @"TERMINAL_CONTROL";


// Archive Operation
static NSString *ArchOperation = @"archive_operation";
static NSString *TABLENAME = @"tablename";
static NSString *TRACK_SDATE = @"track_sdata";

// Termial control
static NSString *ROLL_CALL = @"ROLL_CALL";

// Pet Info
static NSString *PETINFO = @"petinfo";
static NSString *PETID = @"petid";
static NSString *AVATAR = @"avatar";
static NSString *NICKNAME = @"nickname";
static NSString *SEX = @"sex";
static NSString *BREED = @"breed";
static NSString *BIRTHDAY = @"birthday";
static NSString *WEIGHT = @"weight";
static NSString *DISTRICT = @"district";
static NSString *PLACEOFTENGO = @"placeoftengo";
static NSString *DEVICEID = @"deviceid";
static NSString *DEVICEPWD = @"devicepwd";

// Other
static NSString *LIST = @"list";
static NSString *SUCCESS = @"SUCCESS";

static NSString *KEY_TOTAL_STAT = @"TOTAL_STAT";
static NSString *KEY_PART_STAT = @"PART_STAT";

static NSString *KEY_OFFLINE = @"OFFLINE";
static NSString *KEY_ONLINE = @"ONLINE";
static NSString *KEY_REST = @"REST";
static NSString *KEY_WALK = @"WALK";
static NSString *KEY_PLAY = @"PLAY";
static NSString *KEY_RUNNING = @"RUNNING";

enum MotionType {
    MT_OFFLINE = 0,
    MT_ONLINE = 1,
    MT_REST   = 2,
    MT_WALK   = 3,
    MT_PLAY   = 4,
    MT_RUNNING = 5
    };
#endif
