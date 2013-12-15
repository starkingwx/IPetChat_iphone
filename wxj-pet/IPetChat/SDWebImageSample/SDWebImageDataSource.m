//
//  SDWebImageDataSource.m
//  Sample
//
//  Created by Kirby Turner on 3/18/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "SDWebImageDataSource.h"
#import "KTPhotoView+SDWebImage.h"
#import "KTThumbView+SDWebImage.h"
#import "Enhttpmanager.h"

#define FULL_SIZE_INDEX 0
#define THUMBNAIL_INDEX 1

@implementation SDWebImageDataSource
@synthesize sddelegate = sddelegate_;

- (void)dealloc {
   [images_ release], images_ = nil;
   [super dealloc];
}

- (id)init {
   self = [super init];
   if (self) {
      // Create a 2-dimensional array. First element of
      // the sub-array is the full size image URL and 
      // the second element is the thumbnail URL.
       NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
       NSMutableArray *array = [[NSMutableArray alloc] init];
       images_ = [[NSMutableArray alloc]init];
       int i = 0;
       while (i < [[defaults objectForKey:@"photourl"] count]) {
           [array addObject:[[defaults objectForKey:@"photourl"] objectAtIndex:i]];
           [array addObject:[[defaults objectForKey:@"photourl"] objectAtIndex:i]];
           [images_ addObject:array];
            array = [[NSMutableArray alloc] init];
           i++;
       }
   }
   return self;
}

-(void)addimageurl:(NSString*)url{
    [images_ addObject:[NSArray arrayWithObjects:url, url, nil]];
}


#pragma mark -
#pragma mark KTPhotoBrowserDataSource

- (NSInteger)numberOfPhotos {
   NSInteger count = [images_ count];
   return count;
}

- (void)imageAtIndex:(NSInteger)index photoView:(KTPhotoView *)photoView {
   NSArray *imageUrls = [images_ objectAtIndex:index];
   NSString *url = [imageUrls objectAtIndex:FULL_SIZE_INDEX];
   [photoView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"photoDefault.png"]];
}

- (void)thumbImageAtIndex:(NSInteger)index thumbView:(KTThumbView *)thumbView {
   NSArray *imageUrls = [images_ objectAtIndex:index];
   NSString *url = [imageUrls objectAtIndex:THUMBNAIL_INDEX];
    [thumbView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"photoDefault.png"]];
}

- (void)deleteImageAtIndex:(NSInteger)index {
    [images_ removeObjectAtIndex:index];
    [self deletePhotoAtPath];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [defaults objectForKey:@"photosinfoarray"];
    Enhttpmanager *http = [[Enhttpmanager alloc]init];
    [http deletephoto:self selector:@selector(deletephotocallback:) photoid:[[[array objectAtIndex:index] objectForKey:@"id"]intValue] username:[defaults objectForKey:@"username"]];
    [http release];
}

-(void)deletephotocallback:(NSArray*)args{
    
}

- (void)deletePhotoAtPath{
    
    [self performSelectorOnMainThread:@selector(sendDidFinishSaveNotification)
                           withObject:nil
                        waitUntilDone:NO];
}

- (void)sendDidFinishSaveNotification {
    if ( sddelegate_!= nil && [sddelegate_ respondsToSelector:@selector(didFinishSave)]) {
        [sddelegate_ didFinishSave];
    }
}

- (void)releasePhotoList {
    // Release cached list of file names to force refresh.
    [images_ release], images_ = nil;
}


@end
