//
//  SDWebImageRootViewController.m
//  Sample
//
//  Created by Kirby Turner on 3/18/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "SDWebImageRootViewController.h"
#import "SDWebImageDataSource.h"
#import "Enhttpmanager.h"
#import "sendphotoController.h"

#define server_path_image   "http://www.segopet.com/segoimg/"

@interface SDWebImageRootViewController ()
- (void)showActivityIndicator;
- (void)hideActivityIndicator;
@end

@implementation SDWebImageRootViewController

- (void)dealloc 
{
   [activityIndicatorView_ release], activityIndicatorView_ = nil;
   [images_ release], images_ = nil;
   [super dealloc];
}

- (void)viewDidLoad 
{
   [super viewDidLoad];
   self.title = @"相册详情";
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"wherefrom"] == 0) { //判断是从设置tab进入还是社区tab进入
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                   target:self
                                                                                   action:@selector(addPhoto)];
        [[self navigationItem] setRightBarButtonItem:addButton];
        [addButton release];
    }
    
    if (images_ == nil) {
        images_ = [[SDWebImageDataSource alloc] init];
        [images_ setSddelegate:self];
    }
   [self setDataSource:images_];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:false forKey:@"addphotoornot"];                  //作为相册里添加照片的标识
    [defaults synchronize];
}

//设置contentview的高度使相册滚动高度能适应屏幕
- (void)tabbarappear{
    if (self.tabBarController.tabBar.hidden == TRUE) {
        UIView *contentView;
        if ([[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]]) {
            contentView = [self.tabBarController.view.subviews objectAtIndex:1];
        }
        else contentView = [self.tabBarController.view.subviews objectAtIndex:0];
        
        contentView.frame = CGRectMake(self.tabBarController.view.bounds.origin.x, self.tabBarController.view.bounds.origin.y, self.tabBarController.view.bounds.size.width, self.tabBarController.view.bounds.size.height);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"addphotoornot"]) {            //当添加照片时刷新相册
        [self showActivityIndicator];
        Enhttpmanager *http = [[Enhttpmanager alloc]init];
        [http getgallery:self selector:@selector(getgallerycallback:) galleryid:[[defaults objectForKey:@"mygallery"]intValue]];
        [http release];
        [defaults setBool:false forKey:@"addphotoornot"];
        [defaults synchronize];
        //[self setDataSource:images_];
    }
    [self tabbarappear];
}

-(void)getgallerycallback:(NSArray*)args{
    if ([[args objectAtIndex:0]intValue] == PORTAL_RESULT_GET_GALLERY_SUCCESS) {
        NSDictionary *resultdict = [args objectAtIndex:2];
        if ([[resultdict objectForKey:@"result"]intValue] == 0) {
            NSArray *photoarray = [resultdict objectForKey:@"photos"];
            int i = 0;
            NSMutableArray *photourlarray = [[NSMutableArray alloc]init];
            while (i < [photoarray count]) {
                NSMutableString *urlstr = [[NSMutableString alloc]initWithString:@server_path_image];
                [urlstr appendString:[[photoarray objectAtIndex:i] objectForKey:@"path"]];
                [photourlarray addObject:urlstr];
                i++;
            }
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:photourlarray forKey:@"photourl"];
            [defaults setObject:photoarray forKey:@"photosinfoarray"];
            [defaults synchronize];
            [images_ addimageurl:[photourlarray objectAtIndex:([photourlarray count]-1)]];
            [self setDataSource:images_];
        }
    }
    [self hideActivityIndicator];
}

//添加图片
- (void)addPhoto
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"选择一张图片作为头像" delegate:self  cancelButtonTitle:@"取消" destructiveButtonTitle:@"立即拍照上传" otherButtonTitles:@"从手机相册选取",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [actionSheet showInView:self.view];
}


#pragma mark UIActionSheet协议
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==0)
    {
        UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
        [imgPicker setAllowsEditing:YES];
        [imgPicker setDelegate:self];
        [imgPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self.navigationController presentModalViewController:imgPicker animated:YES];
        
    }
    if (buttonIndex ==1) {
        UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
        [imgPicker setAllowsEditing:YES];
        [imgPicker setDelegate:self];
        [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self.navigationController presentModalViewController:imgPicker animated:YES];
        
    }
    else return;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
    if (image != nil) {
        //以下是保存文件到沙盒路径下
        //把图片转成NSData类型的数据来保存文件
        NSData *data;
        //判断图片是不是png格式的文件
        if (UIImagePNGRepresentation(image)) {
            //返回为png图像。
            data = UIImagePNGRepresentation(image);
        }else {
            //返回为JPEG图像。
            data = UIImageJPEGRepresentation(image, 1.0);
        }
        //保存
        [self setimagepath];
        [[NSFileManager defaultManager] createFileAtPath:imagepath_ contents:data attributes:nil];
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.hidesBottomBarWhenPushed = YES;
    sendphotoController *sendctrl = [[sendphotoController alloc]initWithStyle:UITableViewStyleGrouped];
    sendctrl.title = @"上传照片";
    
    NSString * const key = @"nextNumber";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *nextNumber = [defaults valueForKey:key];
    if ( ! nextNumber ) {
        nextNumber = [NSNumber numberWithInt:1];
    }
    [defaults setObject:[NSNumber numberWithInt:([nextNumber intValue] + 1)] forKey:key];
    
    NSArray *array = [NSArray arrayWithObjects:imagepath_,[defaults objectForKey:@"mygallerytitle"], nil];
    [sendctrl setContentArray:array];
    [self.navigationController pushViewController:sendctrl animated:YES];
    self.hidesBottomBarWhenPushed = NO;
    [sendctrl release];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    return;
}

//设置图片本地保存地址
-(void)setimagepath{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    //指定新建文件夹路径
    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:@"ImageFile"];
    //创建ImageFile文件夹
    [[NSFileManager defaultManager] createDirectoryAtPath:imageDocPath withIntermediateDirectories:YES attributes:nil error:nil];
    //保存图片的路径
    imagepath_ = [imageDocPath stringByAppendingPathComponent:@"image.png"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:imagepath_ forKey:@"imagepath"];
    [defaults synchronize];
}


- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)willLoadThumbs 
{
   [self showActivityIndicator];
}


- (void)didLoadThumbs 
{
   [self hideActivityIndicator];
}


#pragma mark -
#pragma mark Activity Indicator

- (UIActivityIndicatorView *)activityIndicator 
{
   if (activityIndicatorView_) {
      return activityIndicatorView_;
   }

    activityIndicatorView_ = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 85, 20, 20)];
    activityIndicatorView_.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
   CGPoint center = [[self view] center];
   [activityIndicatorView_ setCenter:center];
   [activityIndicatorView_ setHidesWhenStopped:YES];
   [activityIndicatorView_ startAnimating];
   [[self view] addSubview:activityIndicatorView_];
   
   return activityIndicatorView_;
}

- (void)showActivityIndicator 
{
   [[self activityIndicator] startAnimating];
}

- (void)hideActivityIndicator 
{
   [[self activityIndicator] stopAnimating];
}

#pragma mark -
#pragma mark sdwebimagedatadelegate

- (void)didFinishSave {
    //[self setDataSource:images_];
    [self reloadThumbs];
}

@end
