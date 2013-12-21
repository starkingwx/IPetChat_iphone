//
//  WhereClause.h
//  IPetChat
//
//  Created by king star on 13-12-21.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WhereClause : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *op;
@property (nonatomic, strong) NSString *value;
@end
