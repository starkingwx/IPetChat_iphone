//
//  SDWebImageDataSource.h
//  Sample
//
//  Created by Kirby Turner on 3/18/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTPhotoBrowserDataSource.h"

@protocol sdwebimagedatadelegate;
@interface SDWebImageDataSource : NSObject <KTPhotoBrowserDataSource> {
    id<sdwebimagedatadelegate> sddelegate_;
   NSMutableArray *images_;
     NSOperationQueue *queue_;
}

-(void)addimageurl:(NSString*)url;
@property (nonatomic, assign) id<sdwebimagedatadelegate> sddelegate;
@end

@protocol sdwebimagedatadelegate <NSObject>
@optional
- (void)didFinishSave;
@end