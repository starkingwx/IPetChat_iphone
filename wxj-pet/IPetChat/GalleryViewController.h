//
//  GalleryViewController.h
//  IPetChat
//
//  Created by WXJ on 13-11-27.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsynImageView.h"

@interface GalleryViewController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate>

@property (retain, nonatomic) NSMutableArray *contentArray;
@property (retain, nonatomic) NSString *imagePath;

@property (retain, nonatomic) IBOutlet UITableView *gallerylist;
@property (retain, nonatomic) IBOutlet UIViewController *Addphotoctrl;
@property (retain, nonatomic) IBOutlet UIImageView *addimage;
@property (retain, nonatomic) IBOutlet UITextView *suggestiontext;
@property (retain, nonatomic) IBOutlet UITableView *gallerybackview;
@property (retain, nonatomic) IBOutlet UILabel *suggestionPlaceholder;
@property (retain, nonatomic) IBOutlet UIViewController *Gallerytitlelistctrl;
@property (retain, nonatomic) IBOutlet UITableView *gallerytitlelist;
@property (retain, nonatomic) IBOutlet UIViewController *Creategalleryctrl;
@property (retain, nonatomic) IBOutlet UITextField *gallerytitleinput;
@property (retain, nonatomic) IBOutlet UIAlertView *basealert;
@property (retain, nonatomic) IBOutlet UILabel *titlelabel;




@property (assign, nonatomic) NSInteger type;

-(void)takephotoclick;
@end
