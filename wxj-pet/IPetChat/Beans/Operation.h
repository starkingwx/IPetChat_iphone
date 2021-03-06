//
//  Operation.h
//  IPetChat
//
//  Created by king star on 13-12-21.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArchiveOperation.h"
#import "TerminalControl.h"

@interface Operation : NSObject

@property (nonatomic, strong) NSString *cmdtype;
@property (nonatomic, strong) ArchiveOperation *archive_operation;
@property (nonatomic, strong) TerminalControl *terminal_control;
@end
