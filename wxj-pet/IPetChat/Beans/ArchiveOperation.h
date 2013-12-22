//
//  DatabaseOperation.h
//  IPetChat
//
//  Created by king star on 13-12-21.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArchiveOperation : NSObject

@property (nonatomic, strong) NSString *tablename;
@property (nonatomic, strong) NSString *operation;
@property (nonatomic, strong) NSArray *field;
@property (nonatomic, strong) NSArray *wherecond;

@end
