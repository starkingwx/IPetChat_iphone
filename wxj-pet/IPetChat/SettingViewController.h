//
//  SettingViewController.h
//  IPetChat
//
//  Created by XF on 13-11-7.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsynImageView.h"
#import "GalleryViewController.h"

#define server_path_image   "http://www.segopet.com/segoimg/"

@interface SettingViewController : UITableViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSString *imagePath;
    NSMutableDictionary *petdatadic;
    BOOL whichback;                                 //返回键处于哪个页面的标识
    NSArray *pettypes;
    NSArray *petsexs;
}

@property (retain, nonatomic) NSArray *contentArray;
@property (retain, nonatomic) NSArray *contentArray1;
@property (retain, nonatomic) NSDictionary *contentdict;
@property (retain, nonatomic) NSIndexPath *lastIndexPath;
@property (retain, nonatomic) NSIndexPath *lastIndexPath1;


@property (retain, nonatomic) IBOutlet UITableView *Petdocumentlist;
@property (retain, nonatomic) IBOutlet UITableView *Pettypelist;
@property (retain, nonatomic) IBOutlet UITableView *sextype;
@property (retain, nonatomic) IBOutlet UIButton *takephotobtn;
@property (retain, nonatomic) IBOutlet AsynImageView *petphoto;
@property (retain, nonatomic) IBOutlet UITextField *nameinput;
@property (retain, nonatomic) IBOutlet UILabel *petinfo;
@property (retain, nonatomic) IBOutlet UILabel *unitlabel;
@property (retain, nonatomic) IBOutlet UIViewController *petinfotableview;
@property (retain, nonatomic) IBOutlet UIViewController *backviewctrl;
@property (retain, nonatomic) UIDatePicker *datePicker;
@property (retain, nonatomic) GalleryViewController *gallerylistctrl;

- (void)addbackviewandsavebtn;
@end
