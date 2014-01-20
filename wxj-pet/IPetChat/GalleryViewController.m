//
//  GalleryViewController.m
//  IPetChat
//
//  Created by WXJ on 13-11-27.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "GalleryViewController.h"
#import "Enhttpmanager.h"
#import "SDWebImageRootViewController.h"
#import "UserBean+Device.h"

#define server_path_image   "http://www.segopet.com/segoimg/"

@interface GalleryViewController ()

@end

@implementation GalleryViewController
@synthesize gallerylist = _gallerylist;
@synthesize contentArray = _contentArray;
@synthesize Addphotoctrl = _Addphotoctrl;
@synthesize addimage = _addimage;
@synthesize suggestiontext = _suggestiontext;
@synthesize gallerybackview = _gallerybackview;
@synthesize suggestionPlaceholder = _suggestionPlaceholder;
@synthesize imagePath = _imagePath;
@synthesize Gallerytitlelistctrl = _Gallerytitlelistctrl;
@synthesize gallerytitlelist = _gallerytitlelist;
@synthesize gallerytitleinput = _gallerytitleinput;
@synthesize Creategalleryctrl = _Creategalleryctrl;
@synthesize type = _type;
@synthesize basealert = _basealert;
@synthesize titlelabel = _titlelabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:false forKey:@"refresh"];
    [defaults synchronize];
    _gallerylist.scrollEnabled = YES;
    _gallerylist.separatorStyle = UITableViewCellSeparatorStyleNone;
     _gallerylist.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(239/255.0) blue:(240/255.0) alpha:1];
    
    
    _gallerybackview.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(239/255.0) blue:(240/255.0) alpha:1];
    _gallerybackview.scrollEnabled = YES;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 2)];
    view.backgroundColor = [UIColor lightGrayColor];
    _gallerylist.tableFooterView = view;
    [view release];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"fromset"]) {

    }else{
        if ([defaults boolForKey:@"refresh"]) {
            [self setContentArray:[defaults objectForKey:@"refreshlist"]];
            [_gallerylist reloadData];
            [defaults setBool:false forKey:@"refresh"];
        }
        self.hidesBottomBarWhenPushed = YES;
        [self tabbarappear];
    }
}

//tabbar显示
- (void)tabbarappear{
    if (self.tabBarController.tabBar.hidden == TRUE) {
        UIView *contentView;
        if ([[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]]) {
            contentView = [self.tabBarController.view.subviews objectAtIndex:1];
        }
        else contentView = [self.tabBarController.view.subviews objectAtIndex:0];
        
        contentView.frame = CGRectMake(self.tabBarController.view.bounds.origin.x, self.tabBarController.view.bounds.origin.y, self.tabBarController.view.bounds.size.width, self.tabBarController.view.bounds.size.height+49);
        
        self.tabBarController.tabBar.hidden = YES;
    }
}

//隐藏tabbar
- (void)makeTabBarHidden:(BOOL)hide {
    UIView *contentView;
    if ([[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]]) {
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    }
    else contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    
    if (hide) {
        contentView.frame = CGRectMake(self.tabBarController.view.bounds.origin.x, self.tabBarController.view.bounds.origin.y, self.tabBarController.view.bounds.size.width, self.tabBarController.view.bounds.size.height+49);
    }
    self.tabBarController.tabBar.hidden = hide;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView.tag == 1) {
        return 3;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 1) {
        return 1;
    }
    return [_contentArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 0) {
        if (_type == 0) {
            return 70;
        }else{
            return 0;
        }
    }else if (tableView.tag == 2) {
        return 70;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 0) {
        return 70;
    }else if (tableView.tag == 1) {
        if ([indexPath section] == 0) {
            return 88;
        }else if ([indexPath section] == 1){
            return 100;
        }else if ([indexPath section] == 2){
            return 44;
        }
    }
    return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView.tag == 0) {
        if (self.type == 0) {
            UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
            UIImageView *petphoto = [[UIImageView alloc]initWithFrame:CGRectMake(100, 5, 60, 60)];
            UIButton *takephotobtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [takephotobtn addTarget:self action:@selector(takephotoclick) forControlEvents:UIControlEventTouchUpInside];
            takephotobtn.frame = CGRectMake(0, 0, 320, 70);
            
            petphoto.image = [UIImage imageNamed:@"img_new_petalbum_cover.png"];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 60)];
            titleLabel.text= @"今天";
            titleLabel.font = [UIFont systemFontOfSize:21];
            titleLabel.backgroundColor = [UIColor clearColor];
            [myView addSubview:petphoto];
            [myView addSubview:titleLabel];
            [myView addSubview:takephotobtn];
            [titleLabel release];
            [petphoto release];
            return myView;
        }
        else {
            return nil;
        }
    }else if (tableView.tag == 2){
        UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
        UIImageView *addgalleryimage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 60, 60)];
        UIButton *addgallerybtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addgallerybtn addTarget:self action:@selector(addgalleryclick) forControlEvents:UIControlEventTouchUpInside];
        addgallerybtn.frame = CGRectMake(0, 0, 320, 70);
        
        addgalleryimage.image = [UIImage imageNamed:@"addphoto.png"];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 5, 240, 60)];
        titleLabel.text= @"新建相册";
        titleLabel.font = [UIFont systemFontOfSize:21];
        titleLabel.backgroundColor = [UIColor clearColor];
        [myView addSubview:addgalleryimage];
        [myView addSubview:titleLabel];
        [myView addSubview:addgallerybtn];
        [titleLabel release];
        return myView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (tableView.tag == 0) {
        NSDictionary *gallerydict = [[NSDictionary alloc] initWithDictionary:[_contentArray objectAtIndex:[indexPath row]]];
        // Configure the cell...
        //if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        //}
        
        UIFont *font = [UIFont systemFontOfSize:21];
        
        UILabel *timelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 60)];
        [timelabel setFont:font];
        [timelabel setBackgroundColor:[UIColor clearColor]];
        
        int seconds = [[gallerydict objectForKey:@"createtime"]intValue];
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:seconds];
        NSDateFormatter *monthoutputFormatter = [[NSDateFormatter alloc] init];
        NSDateFormatter *dayoutputFormatter = [[NSDateFormatter alloc] init];
        [monthoutputFormatter setDateFormat:@"MM"];
        [dayoutputFormatter setDateFormat:@"dd"];
        NSMutableString *monthstr = [[NSMutableString alloc]initWithString:[monthoutputFormatter stringFromDate:confromTimesp]];
        [monthstr appendString:@"月"];
        [monthstr appendString:[dayoutputFormatter stringFromDate:confromTimesp]];
        
        timelabel.text = monthstr;
        [cell addSubview:timelabel];
        [timelabel release];
        
        AsynImageView *profilepic = [[AsynImageView alloc] initWithFrame:CGRectMake(100, 5, 60, 60)];
        NSMutableString *urlstr = [[NSMutableString alloc]initWithString:@server_path_image];
        [urlstr appendString:[gallerydict objectForKey:@"cover_url"]];
        [profilepic setImageURL:urlstr];
        [cell addSubview:profilepic];
        [profilepic release];
        
        UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 5, 150, 60)];
        [titlelabel setBackgroundColor:[UIColor clearColor]];
        [titlelabel setNumberOfLines:0];
        titlelabel.text = [gallerydict objectForKey:@"title"];
        [cell addSubview:titlelabel];
        [gallerydict release];
    }else if (tableView.tag == 1){
        // Configure the cell...
        //if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        //}
        if ([indexPath section] == 0) {
            _suggestiontext = [[[UITextView alloc]initWithFrame:CGRectMake(0, 0, 300, 88)] autorelease];
            _suggestiontext.font = [UIFont systemFontOfSize:18];
            _suggestiontext.backgroundColor = [UIColor clearColor];
            
            _suggestiontext.delegate = self;
            [cell.contentView addSubview:_suggestiontext];
            _suggestionPlaceholder = [[[UILabel alloc]initWithFrame:CGRectMake(10, 4, 200, 30)]autorelease];
            _suggestionPlaceholder.backgroundColor = [UIColor clearColor];
            _suggestionPlaceholder.font = [UIFont systemFontOfSize:18];
            _suggestionPlaceholder.text = @"添加照片描述";
            _suggestionPlaceholder.textColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:_suggestionPlaceholder];
            //[_suggestiontext release];
            //[_suggestionPlaceholder release];
        }else if ([indexPath section] == 1){
           _addimage = [[[UIImageView alloc]initWithFrame:CGRectMake(100, 5, 90, 90)]autorelease];
            NSString *path = [[NSUserDefaults standardUserDefaults]objectForKey:@"imagepath"];
            [_addimage setImage:[UIImage imageWithContentsOfFile:path]];
            [cell addSubview:_addimage];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //[_addimage release];
        }else if ([indexPath section] == 2){
            [cell.textLabel setText:@"上传到"];
            _titlelabel = [[[UILabel alloc]initWithFrame:CGRectMake(80, 0, 200, 44)]autorelease];
            NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectgallery"];
            _titlelabel.text = [array objectAtIndex:1];
            _titlelabel.backgroundColor = [UIColor clearColor];
            _titlelabel.textAlignment = UITextAlignmentRight;
            [cell.contentView addSubview:_titlelabel];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
    }else{
        NSDictionary *gallerydict = [[NSDictionary alloc] initWithDictionary:[_contentArray objectAtIndex:[indexPath row]]];
        // Configure the cell...
        //if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        //}
        
        UIFont *font = [UIFont systemFontOfSize:21];
        
        AsynImageView *profilepic = [[AsynImageView alloc] initWithFrame:CGRectMake(5, 5, 60, 60)];
        NSMutableString *urlstr = [[NSMutableString alloc]initWithString:@server_path_image];
        [urlstr appendString:[gallerydict objectForKey:@"cover_url"]];
        [profilepic setImageURL:urlstr];
        //[profilepic setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlstr]]]];
        [cell addSubview:profilepic];
        [profilepic release];
        
        UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 5, 240, 60)];
        [titlelabel setBackgroundColor:[UIColor clearColor]];
        [titlelabel setNumberOfLines:0];
        titlelabel.text = [gallerydict objectForKey:@"title"];
        [titlelabel setFont:font];
        [cell addSubview:titlelabel];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 0) {
        NSDictionary *gallerydict = [[NSDictionary alloc] initWithDictionary:[_contentArray objectAtIndex:[indexPath row]]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[gallerydict objectForKey:@"id"] forKey:@"mygallery"];
        [defaults setObject:[gallerydict objectForKey:@"title"] forKey:@"mygallerytitle"];
        [defaults synchronize];
        Enhttpmanager *http = [[Enhttpmanager alloc]init];
        [http getgallery:self selector:@selector(getgallerycallback:) galleryid:[[gallerydict objectForKey:@"id"]intValue]];
        [http release];
    }else if (tableView.tag == 1){
        if ([indexPath section]==2) {
            self.hidesBottomBarWhenPushed = YES;
            _gallerytitlelist.contentSize = CGSizeMake(320, ([_contentArray count]+1)*70);
            _Gallerytitlelistctrl.title = @"选择相册";
            UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"上传照片" style:UIBarButtonItemStyleDone target:self action:@selector(backtosendphoto)];
            _Gallerytitlelistctrl.navigationItem.leftBarButtonItem = leftItem;
            [self.navigationController pushViewController:_Gallerytitlelistctrl animated:YES];
            self.hidesBottomBarWhenPushed = NO;
        }
    }else{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *galleryidandtitle = [[NSArray alloc]initWithObjects:[[_contentArray objectAtIndex:[indexPath row]] objectForKey:@"id"],[[_contentArray objectAtIndex:[indexPath row]] objectForKey:@"title"], nil];
        [defaults setObject:galleryidandtitle forKey:@"selectgallery"];
        [defaults synchronize];
        [galleryidandtitle release];
         self.hidesBottomBarWhenPushed = YES;
        [self.navigationController popViewControllerAnimated:YES];
        [_gallerybackview reloadData];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 0) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 0) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            Enhttpmanager *http = [[Enhttpmanager alloc]init];
            [http deletegallery:self selector:@selector(deletegallerycallback:) galleryid:[[[_contentArray objectAtIndex:indexPath.row] objectForKey:@"id"]intValue] username:[[NSUserDefaults standardUserDefaults]objectForKey:@"username"]];
            [http release];
            
            NSMutableArray *gallerylist = [[NSMutableArray alloc]initWithArray:_contentArray];
            [gallerylist removeObjectAtIndex:indexPath.row];
            [self setContentArray:gallerylist];
            [gallerylist release];
            // Delete the row from the data source.
            [_gallerylist deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

-(void)deletegallerycallback:(NSArray*)args
{
    
}

//从选择相册页面返回发送图片页面
-(void)backtosendphoto{
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

//访问相册详细信息接口返回的信息
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
            [defaults setInteger:_type forKey:@"wherefrom"];
            [defaults setBool:NO forKey:@"fromset"];
            [defaults synchronize];
            
            self.hidesBottomBarWhenPushed = YES;
            SDWebImageRootViewController *newController = [[SDWebImageRootViewController alloc] init];
            [[self navigationController] pushViewController:newController animated:YES];
            //self.hidesBottomBarWhenPushed = NO;
            [newController release];
        }
        
    }
}

//相册列表点击拍照按钮触发的信息
-(void)takephotoclick{
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
        [[NSFileManager defaultManager] createFileAtPath:_imagePath contents:data attributes:nil];
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (_contentArray && [_contentArray count] > 0) {
        NSArray *galleryidandtitle = [[NSArray alloc]initWithObjects:[[_contentArray objectAtIndex:0] objectForKey:@"id"],[[_contentArray objectAtIndex:0] objectForKey:@"title"], nil];
        [defaults setObject:galleryidandtitle forKey:@"selectgallery"];
        [defaults synchronize];
        [galleryidandtitle release];
    }

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(canceltakephoto)];
    _Addphotoctrl.navigationItem.leftBarButtonItem = leftItem;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(sendphoto)];
    _Addphotoctrl.navigationItem.rightBarButtonItem = rightItem;
    _Addphotoctrl.title = @"上传照片";
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:_Addphotoctrl animated:YES];
    self.hidesBottomBarWhenPushed = NO;
    [rightItem release];
    [leftItem release];
    [_gallerybackview reloadData];
    
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
    _imagePath = [imageDocPath stringByAppendingPathComponent:@"image.png"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_imagePath forKey:@"imagepath"];
    [defaults synchronize];
}

//上传图片到相册触发的操作
-(void)sendphoto{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"selectgallery"]) {
        UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还未创建属于您的相册，是否创建新相册？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        [alertview show];
        [alertview release];
    }else{
        if ([[defaults objectForKey:@"selectgallery"] count] != 0) {
            _basealert = [UIAlertView alloc];
            NSString *myMsg = @"  正在上传图片，请稍候...";
            
            [_basealert initWithTitle:@"提示" message:myMsg delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            
            UIActivityIndicatorView *actIndView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 85, 20, 20)];
            actIndView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            
            [_basealert addSubview:actIndView];
            [actIndView startAnimating];
            [actIndView release];
            
            [_basealert show];
            [_basealert release];
            
            Enhttpmanager *http = [[Enhttpmanager alloc]init];
            [http uploadgalleryimage:self selector:@selector(uploadviewcallback:) username:[defaults objectForKey:@"username"] galleryid:[[[defaults objectForKey:@"selectgallery"]objectAtIndex:0]intValue] imagepath:_imagePath name:@"" type:@"" description:_suggestiontext.text];
            [http release];
        }else{
            UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还未创建属于您的相册，是否创建新相册？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
            [alertview show];
            [alertview release];
        }
    }
}

//在选择相册页面，点击新建相册触发的事件
-(void)addgalleryclick{
    _gallerytitleinput.frame = CGRectMake(20, 70, 280, 50);
    _Creategalleryctrl.title = @"新建相册";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"选择相册" style:UIBarButtonItemStyleDone target:self action:@selector(backclick)];
    _Creategalleryctrl.navigationItem.leftBarButtonItem = leftItem;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(confirmcreategallery)];
    _Creategalleryctrl.navigationItem.rightBarButtonItem = rightItem;
     self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:_Creategalleryctrl animated:YES];
     self.hidesBottomBarWhenPushed = NO;
}

//返回按钮触发的事件
-(void)backclick{
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

//在创建相册页面，点击确定创建触发的事件
-(void)confirmcreategallery{
    if ([_gallerytitleinput.text length] == 0) {
        UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"相册名不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertview.tag = 2;
        [alertview show];
        [alertview release];
    }else{
        Enhttpmanager *http = [[Enhttpmanager alloc]init];
        [http creategallery:self selector:@selector(creategallerycallback:) username:[[NSUserDefaults standardUserDefaults]objectForKey:@"username"] title:_gallerytitleinput.text];
        [http release];
    }
}

//访问创建相册接口返回的信息
-(void)creategallerycallback:(NSArray*)args{
    if ([[args objectAtIndex:0]intValue] == PORTAL_RESULT_CREATE_GALLERY_SUCCESS) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *galleryidandtitle = [[NSArray alloc]initWithObjects:[[args objectAtIndex:2] objectForKey:@"id"],_gallerytitleinput.text, nil];
        [defaults setObject:galleryidandtitle forKey:@"selectgallery"];
        [defaults synchronize];
        [galleryidandtitle release];
        
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController popToViewController:_Addphotoctrl animated:YES];
        [_gallerybackview reloadData];
        /*Enhttpmanager *gallerylisthttp = [[Enhttpmanager alloc]init];
        [gallerylisthttp getgallerylist:self selector:@selector(getgallerylist:) username:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] petid:26];
        [gallerylisthttp release];*/
        
    }
}

//访问获取相册列表接口返回的信息
-(void)getgallerylist:(NSArray*)args{
    if ([[args objectAtIndex:0] intValue] == PORTAL_RESULT_GET_GALLERYLIST_SUCCESS) {
        NSDictionary *dict = [[NSDictionary alloc]initWithDictionary:[args objectAtIndex:2]];
        if ([[dict objectForKey:@"result"] intValue] == 0) {
            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"list"]];
            [self setContentArray:array];
            
            /*self.hidesBottomBarWhenPushed = YES;
            [self.navigationController popToViewController:_Addphotoctrl animated:YES];
            [_gallerybackview reloadData];*/
            [array release];
        }
        [dict release];
    }
}

//上传相册图片页面，取消上传触发的事件
-(void)canceltakephoto{
    UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"取消发送图片" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    alertview.tag = 0;
    [alertview show];
    [alertview release];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 0) {
        if (buttonIndex == 1) {
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController popViewControllerAnimated:YES];
            [_gallerylist reloadData];
        }
    }else if (alertView.tag == 1){
        if (buttonIndex == 0){
             self.hidesBottomBarWhenPushed = YES;
            [self.navigationController popViewControllerAnimated:YES];
            [_gallerylist reloadData];
        }
    }
}

//上传相册图片返回的信息
-(void)uploadviewcallback:(NSArray*)args{
    if (_basealert) {
        [_basealert dismissWithClickedButtonIndex:0 animated:YES];
        _basealert = nil;
    }
    NSString *msg = @"上传失败。";
    if ([[args objectAtIndex:0]intValue] == PORTAL_RESULT_UPLOAD_GALLERYIMAGE_SUCCESS) {
        if ([[[args objectAtIndex:2] objectForKey:@"result"]intValue] == 0) {
            Enhttpmanager *http = [[Enhttpmanager alloc]init];
            [http modifygalleryinfo:self selector:@selector(modifygallerycallback:) galleryid:[[[args objectAtIndex:2] objectForKey:@"galleryid"]intValue]  coverurl:[[args objectAtIndex:2] objectForKey:@"path"]];
            [http release];
            
             msg = @"上传成功";
            UIAlertView *Alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            Alertview.tag = 1;
            [Alertview show];
            [Alertview release];
            return;
        }
    }
    UIAlertView *Alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    Alertview.tag = 2;
    [Alertview show];
    [Alertview release];
}

//访问修改相册信息接口返回的结果
-(void)modifygallerycallback:(NSArray*)args{
    UserBean *user = [[UserManager shareUserManager] userBean];
    PetInfo *petInfo = [user petInfo];
    Enhttpmanager *gallerylisthttp = [[Enhttpmanager alloc]init];
    [gallerylisthttp getgallerylist:self selector:@selector(getgallerylist:) username:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] petid:[[petInfo petId] longValue]];
    [gallerylisthttp release];
}

//上传图片页面的照片描述框内容改变时触发的操作
- (void)textViewDidChange:(UITextView *)textView{
    NSString *nsTextContent = textView.text;
    int existTextNum=[nsTextContent length];
    if (existTextNum != 0) {
        _suggestionPlaceholder.hidden = YES;
    }
    else {
        _suggestionPlaceholder.hidden = NO;
    }
}

//uitextview设置收起键盘按钮
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

//uitextfiled收起键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_gallerytitleinput resignFirstResponder];
    return YES;
}

//需要section随tableview一起滚动时做的操作
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _gallerytitlelist||scrollView == _gallerylist)
    {
        CGFloat sectionHeaderHeight = 70;
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
    if (scrollView == _gallerytitlelist) {
        CGRect frame = _gallerytitlelist.frame;
        frame.size.height = 421;
        _gallerytitlelist.frame = frame;
    }
}

-(void)dealloc{
    [_gallerylist release];
    [_contentArray release];
    [_addimage release];
    [_Addphotoctrl release];
    [_suggestionPlaceholder release];
    [_suggestiontext release];
    [_imagePath release];
    [_gallerytitlelist release];
    [_Gallerytitlelistctrl release];
    [_gallerytitleinput release];
    [_Creategalleryctrl release];
    [_basealert release];
    [_gallerybackview release];
    [_titlelabel release];
    [super dealloc];
}

@end
