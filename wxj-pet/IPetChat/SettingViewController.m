//
//  SettingViewController.m
//  IPetChat
//
//  Created by XF on 13-11-7.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "SettingViewController.h"
#import "Enhttpmanager.h"
#import "AccountManagerController.h"
#import "PetBlackListController.h"
#import "GalleryViewController.h"
#import "CommonToolkit/CommonToolkit.h"
#import "UserBean+Device.h"
#import "Constant.h"
#import "PetInfoUtil.h"
#import "DeviceBindViewController.h"

#define DEVICE_HEIGHT_DIFF [UIScreen mainScreen].bounds.size.height-480 

@interface SettingViewController () {
}

@end

@implementation SettingViewController
@synthesize contentArray = _contentArray;
@synthesize Petdocumentlist = _Petdocumentlist;
@synthesize contentdict = _contentdict;
@synthesize contentArray1 = _contentArray1;
@synthesize takephotobtn = _takephotobtn;
@synthesize petphoto = _petphoto;
@synthesize nameinput = _nameinput;
@synthesize petinfo = _petinfo;
@synthesize Pettypelist = _Pettypelist;
@synthesize lastIndexPath = _lastIndexPath;
@synthesize sextype = _sextype;
@synthesize lastIndexPath1 = _lastIndexPath1;
@synthesize petinfotableview = _petinfotableview;
@synthesize backviewctrl = _backviewctrl;
@synthesize gallerylistctrl = _gallerylistctrl;
@synthesize unitlabel = _unitlabel;
@synthesize datePicker = _datePicker;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"设置";
//        if ([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending) {
//            [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ic_tab_settings_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"ic_tab_settings_unselected.png"]];
//            [self.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -3.0)];
//        }
//        else {
//            [self.tabBarItem setImage:[UIImage imageNamed:@"ic_tab_settings_unselected.png"]];
//        }
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Setting", @"设置") image:[UIImage imageNamed:@"ic_tab_settings_unselected.png"] tag:2];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.scrollEnabled = FALSE;
    self.contentArray = [NSArray arrayWithObjects:@"宠物档案", @"相册", @"账号", @"黑名单管理",@"设备绑定", nil];
    
    NSArray *Arr0 = [[NSArray alloc] initWithObjects:@"昵称",@"性别",   nil];
    NSArray *Arr1 = [[NSArray alloc] initWithObjects:@"品种", @"生日",@"身高", @"体重", nil];
    NSArray *Arr2 = [[NSArray alloc] initWithObjects:@"城市", @"常去玩的地方", nil];
    
    NSDictionary *stTableInfo = [[NSDictionary alloc] initWithObjectsAndKeys:Arr0, @"0", Arr1, @"1", Arr2, @"2", nil];
    
    [Arr0 release];
    [Arr1 release];
    [Arr2 release];
    
    
    self.contentdict =stTableInfo;
    self.contentArray1 =[self.contentdict allKeys];
    _Petdocumentlist.scrollEnabled = YES;
    
    UIView *myview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, DEVICE_HEIGHT_DIFF+92)];
    //myview.backgroundColor = [UIColor orangeColor];
    UIButton *logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(10, DEVICE_HEIGHT_DIFF, 300, 40)];
    [logoutButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [logoutButton setBackgroundImage:[[UIImage imageNamed:@"img_red_btn_normal_bg.ios.png"] stretchableImageWithLeftCapWidth:76 topCapHeight:20] forState:UIControlStateNormal];
    [logoutButton setBackgroundImage:[[UIImage imageNamed:@"img_red_btn_pressed_bg.ios.png"] stretchableImageWithLeftCapWidth:76 topCapHeight:20] forState:UIControlStateHighlighted];
    [logoutButton addTarget:self action:@selector(logoutButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [myview addSubview:logoutButton];
    
    self.tableView.tableFooterView = myview;
    [logoutButton release];
    [myview release];
    
    self.view.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(239/255.0) blue:(240/255.0) alpha:1];
    
//    petdatadic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"",@"昵称",@"",@"性别",@"",@"品种",nil,@"生日",@"",@"身高",@"",@"体重",@"",@"城市",@"",@"常去玩的地方",@"nothing",@"headphoto",nil];

    petdatadic = [[NSMutableDictionary alloc] init];
    
    pettypes = [[NSArray alloc]initWithObjects:@"黄金猎犬",@"哈士奇",@"贵宾（泰迪）",@"赛摩耶",@"博美",@"雪纳瑞",@"苏格兰牧羊犬",@"松狮",@"京巴",@"其他犬种", nil];
    petsexs = [[NSArray alloc]initWithObjects:@"帅哥",@"美女", nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self tabbarappear];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (tableView.tag == 0) {
        return [self.contentArray count];
    }else if (tableView.tag == 1){
        return [self.contentArray1 count];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView.tag == 0) {
        return 1;
    }else if (tableView.tag == 1){
        if (section == 0) {
            return [[_contentdict objectForKey:@"0"] count];
        }else if (section == 1){
            return [[_contentdict objectForKey:@"1"] count];;
        }else{
            return [[_contentdict objectForKey:@"2"] count];;
        }
    }else if (tableView.tag == 2){
        return [pettypes count];
    }else if (tableView.tag == 3){
        return [petsexs count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 0) {
        return 10;
    }else if (tableView.tag == 1) {
        if (section == 0) {
            return 112;
        }else{
            return 5;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 0) {
        return 40;
    }else if (tableView.tag == 1) {
        return 44;
    }if (tableView.tag == 2) {
        return 44;
    }if (tableView.tag == 3) {
        return 44;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView.tag == 0) {
        
    }else if (tableView.tag == 1) {
        if (section == 0) {
            UIView *myView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 112)]autorelease];
            _petphoto = [[AsynImageView alloc]initWithFrame:CGRectMake(213, 5, 98, 102)];
            _takephotobtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_takephotobtn addTarget:self action:@selector(takephotoclick:) forControlEvents:UIControlEventTouchUpInside];
            _takephotobtn.frame = CGRectMake(213, 5, 98, 102);
            if (![petdatadic objectForKey:@"headphoto"]||[[petdatadic objectForKey:@"headphoto"] isEqualToString:@"nothing"]) {
            _petphoto.image = [UIImage imageNamed:@"petphoto"];
            }else{
                NSMutableString *photostring = [[NSMutableString alloc]initWithString:@server_path_image];
                [photostring appendString:[petdatadic objectForKey:@"headphoto"]];
                [_petphoto setImageURL:photostring];
                //_petphoto.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photostring]]];
            }
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 36, 80, 30)];
            titleLabel.text= @"头像";
            titleLabel.font = [UIFont systemFontOfSize:21];
            titleLabel.backgroundColor = [UIColor clearColor];
            [myView addSubview:_petphoto];
            [myView addSubview:titleLabel];
            [myView addSubview:_takephotobtn];
            [titleLabel release];
            return myView;
        }else{
            UIView *View = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 112)]autorelease];
            View.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(239/255.0) blue:(240/255.0) alpha:1];
            return View;
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 0) {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        [[cell textLabel] setText:[self.contentArray objectAtIndex:[indexPath section]]];
        
        return cell;
    }else if (tableView.tag == 1){
        NSArray *listData =[self.contentdict objectForKey:
                            [self.contentArray1 objectAtIndex:[indexPath section]]];
        NSString *rowvalue = [listData objectAtIndex:[indexPath row]];
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;

        UIFont *font = [UIFont systemFontOfSize:20];
        [[cell textLabel] setText:[listData objectAtIndex:[indexPath row]]];
        [[cell textLabel] setFont:font];
        CGSize size = [cell.textLabel.text sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT,44)lineBreakMode:UILineBreakModeWordWrap];
        _petinfo = [[UILabel alloc]initWithFrame:CGRectMake(size.width, 0, 270-size.width, 44)];
        _petinfo.backgroundColor = [UIColor clearColor];
        _petinfo.textAlignment = UITextAlignmentRight;
       
        if ([rowvalue isEqualToString:@"生日"]) {
            NSString *string;
            NSNumber *birthday = [petdatadic objectForKey:@"生日"];
            if ([birthday longLongValue] > 0) {
                NSDate *birthDate = [NSDate dateWithTimeIntervalSince1970:[birthday longLongValue] / 1000];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
                string = [dateFormatter stringFromDate:birthDate];
            } else {
                string = @"";
            }
            
            _petinfo.text = string;
        }else if ([rowvalue isEqualToString:@"身高"]) {
            NSMutableString *string;
            NSString *heightstr = [petdatadic objectForKey:@"身高"];
            if (heightstr != nil) {
                string = [[NSMutableString alloc]initWithString:heightstr];
                [string appendString:@"厘米"];
            } else {
                string = [[NSMutableString alloc] initWithString:@""];
            }
           
            _petinfo.text = string;
            [string release];
        }else if ([rowvalue isEqualToString:@"体重"]) {
            NSMutableString *string;
            NSString *weight = [petdatadic objectForKey:@"体重"];
            if (weight) {
                string = [[NSMutableString alloc]initWithString:weight];
                [string appendString:@"公斤"];
            } else {
                string = [[NSMutableString alloc] initWithString:@""];
            }
            _petinfo.text = string;
            [string release];
        }else{
            NSString *text = [petdatadic objectForKey:rowvalue];
            if (text == nil) {
                text = @"";
            }
            _petinfo.text = text;
        }
        [cell.contentView addSubview:_petinfo];
        
        
        return cell;
    }else if (tableView.tag == 2){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }

        
        UIFont *font = [UIFont systemFontOfSize:20];
        [[cell textLabel] setText:[pettypes objectAtIndex:[indexPath row]]];
        [[cell textLabel] setFont:font];
        if ([cell.textLabel.text isEqualToString:[petdatadic objectForKey:@"品种"]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.lastIndexPath = indexPath;
        }
        return cell;
    }else if (tableView.tag == 3){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        UIFont *font = [UIFont systemFontOfSize:20];
        [[cell textLabel] setText:[petsexs objectAtIndex:[indexPath row]]];
        [[cell textLabel] setFont:font];
        if ([cell.textLabel.text isEqualToString:[petdatadic objectForKey:@"性别"]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.lastIndexPath1 = indexPath;
        }
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        UIColor *color =  [UIColor colorWithRed:(255/255.0) green:(252/255.0) blue:(252/255.0) alpha:1];
        cell.backgroundColor = color;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserBean *user = [[UserManager shareUserManager] userBean];
    PetInfo *petinfo = user.petInfo;

    if (tableView.tag == 0) {
        if ([indexPath section] == 0) {
            whichback = false;
            
            if (petinfo && petinfo.petId) {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                Enhttpmanager *http = [[Enhttpmanager alloc]init];
                [http getpetdetail:self selector:@selector(getpetuserlistcallback:) petid:[petinfo.petId longValue]];
                [http release];
                
            } else {
                // jump to detail directly cause there is no petinfo
                [self jumpToPetInfoDetailView];
            }
          
            
        }else if ([indexPath section] == 1){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"fromset"];
            [defaults synchronize];
            if (petinfo && petinfo.petId) {
                Enhttpmanager *gallerylisthttp = [[Enhttpmanager alloc]init];
                [gallerylisthttp getgallerylist:self selector:@selector(getgallerylist:) username:user.name petid:[petinfo.petId longValue]];
                [gallerylisthttp release];
            } else {
                [[iToast makeText:@"请先设置宠物资料！"] show];
            }
        }else if ([indexPath section] == 2){
            [self makeTabBarHidden:YES];
//            [self.navigationController setNavigationBarHidden:NO animated:NO];
            AccountManagerController *accountctrl = [[AccountManagerController alloc]init];
            accountctrl.title = @"账号";
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:accountctrl animated:YES];
            self.hidesBottomBarWhenPushed = NO;
        }else if ([indexPath section] == 3){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            Enhttpmanager *blacklisthttp = [[Enhttpmanager alloc]init];
            [blacklisthttp getblacklist:self selector:@selector(getblacklistcallback:) username:[defaults objectForKey:@"username"]];
            [blacklisthttp release];
        } else if ([indexPath section] == 4) {
            // bind device
            if ([PetInfoUtil isPetInfoSet]) {
                [self.navigationController pushViewController:[[DeviceBindViewController alloc] initWithNibName:@"DeviceBindViewController" bundle:nil] animated:YES];
            } else {
                [[iToast makeText:@"请先设置宠物资料！"] show];
            }
        }
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }else if (tableView.tag == 1){
        whichback = true;
        NSArray *listdata = [_contentdict objectForKey:[_contentArray1 objectAtIndex:[indexPath section]]];
        NSString *rowvalue = [listdata objectAtIndex:[indexPath row]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:rowvalue forKey:@"whichsave"];
        [defaults synchronize];
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:_backviewctrl animated:YES];
        self.hidesBottomBarWhenPushed = NO;
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"宠物档案" style:UIBarButtonItemStyleDone target:self action:@selector(backaction)];
        _backviewctrl.navigationItem.leftBarButtonItem = leftItem;
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveinfo)];
        _backviewctrl.navigationItem.rightBarButtonItem = rightItem;
        
        if ([rowvalue isEqualToString:@"昵称"]) {
            [self addbackviewandsavebtn];
            _nameinput.text = [petdatadic objectForKey:rowvalue];
            [_backviewctrl.view addSubview:_nameinput];
        }else if ([rowvalue isEqualToString:@"品种"]){
            [self addbackviewandsavebtn];
            _Pettypelist.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(239/255.0) blue:(240/255.0) alpha:1];
            _Pettypelist.scrollEnabled = TRUE;
            _Pettypelist.bounces = TRUE;
            [_backviewctrl.view addSubview:_Pettypelist];
            
        }else if ([rowvalue isEqualToString:@"性别"]){
            [self addbackviewandsavebtn];
            _sextype = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 88) style:UITableViewStylePlain];
            _sextype.delegate = self;
            _sextype.dataSource = self;
            _sextype.tag = 3;
            _sextype.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(239/255.0) blue:(240/255.0) alpha:1];
            [_backviewctrl.view addSubview:_sextype];
        }else if ([rowvalue isEqualToString:@"生日"]) {
            [self addbackviewandsavebtn];
            NSNumber *birthday = [petdatadic objectForKey:@"生日"];
            NSDate *date = [NSDate date];
            if (birthday) {
                date = [NSDate dateWithTimeIntervalSince1970:[birthday doubleValue] / 1000];
            }
            _datePicker.date = date;
            [_backviewctrl.view addSubview:_datePicker];
            
            
        }else if ([rowvalue isEqualToString:@"身高"]) {
            [self addbackviewandsavebtn];
            _nameinput.text = [petdatadic objectForKey:@"身高"];
            [_backviewctrl.view addSubview:_nameinput];
        }else if ([rowvalue isEqualToString:@"体重"]) {
            [self addbackviewandsavebtn];
            _nameinput.text = [petdatadic objectForKey:@"体重"];
            [_backviewctrl.view addSubview:_nameinput];
        }else if ([rowvalue isEqualToString:@"城市"]) {
            [self addbackviewandsavebtn];
            _nameinput.text = [petdatadic objectForKey:@"城市"];
            [_backviewctrl.view addSubview:_nameinput];
        }else if ([rowvalue isEqualToString:@"常去玩的地方"]) {
            [self addbackviewandsavebtn];
            _nameinput.text = [petdatadic objectForKey:@"常去玩的地方"];
            [_backviewctrl.view addSubview:_nameinput];
        }


        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }else if (tableView.tag == 2){
        whichback = true;
        int newRow = [indexPath row];
        int oldRow;
        if (self.lastIndexPath != nil) {
            oldRow = [self.lastIndexPath row];
        }else{
            oldRow = -1;
        }
    
        if(newRow != oldRow)
        {
            UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.lastIndexPath];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            [self setLastIndexPath:indexPath];
            //self.lastIndexPath = indexPath;
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else if (tableView.tag == 3){
        whichback = true;
        int newRow = [indexPath row];
        int oldRow;
        if (self.lastIndexPath1 != nil) {
            oldRow = [self.lastIndexPath1 row];
        }else{
            oldRow = -1;
        }
        
        if(newRow != oldRow)
        {
            UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.lastIndexPath1];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            self.lastIndexPath1 = indexPath;
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

//宠物档案编辑宠物信息完成后，点击保存触发的事件
-(void)saveinfo{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    whichback = false;
    if ([[defaults objectForKey:@"whichsave"] isEqualToString:@"昵称"]) {
        [petdatadic setObject:_nameinput.text  forKey:@"昵称"];
        [_nameinput removeFromSuperview];
    }else if ([[defaults objectForKey:@"whichsave"] isEqualToString:@"品种"]){
        [petdatadic setObject:[pettypes objectAtIndex:[self.lastIndexPath row]] forKey:@"品种"];
        [_Pettypelist removeFromSuperview];
    }else if ([[defaults objectForKey:@"whichsave"] isEqualToString:@"生日"]){
        NSDate *birthday = [_datePicker date];
        long long msTime =  (long long)([birthday timeIntervalSince1970] * 1000);
        NSNumber *birthdayMs = [NSNumber numberWithLongLong:msTime];
        [petdatadic setObject:birthdayMs forKey:@"生日"];
        [_datePicker removeFromSuperview];
    }else if ([[defaults objectForKey:@"whichsave"] isEqualToString:@"身高"]){
        [petdatadic setObject:_nameinput.text forKey:@"身高"];
        [_nameinput removeFromSuperview];
    }else if ([[defaults objectForKey:@"whichsave"] isEqualToString:@"体重"]){
        [petdatadic setObject:_nameinput.text forKey:@"体重"];
        [_nameinput removeFromSuperview];
    }else if ([[defaults objectForKey:@"whichsave"] isEqualToString:@"城市"]){
        [petdatadic setObject:_nameinput.text forKey:@"城市"];
        [_nameinput removeFromSuperview];
    }else if ([[defaults objectForKey:@"whichsave"] isEqualToString:@"常去玩的地方"]){
        [petdatadic setObject:_nameinput.text forKey:@"常去玩的地方"];
        [_nameinput removeFromSuperview];
    }else{
        [petdatadic setObject:[petsexs objectAtIndex:[self.lastIndexPath1 row]] forKey:@"性别"];
        [_sextype removeFromSuperview];
    }
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController popViewControllerAnimated:YES];
    self.hidesBottomBarWhenPushed = NO;
    [_Petdocumentlist reloadData];
}

//访问获取宠物详细信息接口，返回的结果
-(void)getpetuserlistcallback:(NSArray*)args{
    NSLog(@"getpetuserlistcallback: %@", args);
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if ([[args objectAtIndex:0]intValue] == PORTAL_RESULT_GET_PETDETAIL_SUCCESS) {
        NSDictionary *dict = [[NSDictionary alloc]initWithDictionary:[args objectAtIndex:2]];
        NSString *string1 = [[NSString alloc]init];
        NSString *nickname = [dict objectForKey:@"nickname"];
        if (nickname == nil) {
            nickname = @"";
        }
        [petdatadic setObject:nickname forKey:@"昵称"];
        if ([[dict objectForKey:@"sex"]intValue]==0) {
            [petdatadic setObject:@"帅哥" forKey:@"性别"];
        }else{
            [petdatadic setObject:@"美女" forKey:@"性别"];
        }
        string1 = [pettypes objectAtIndex:[[dict objectForKey:@"breed"]intValue]];
        [petdatadic setObject:string1 forKey:@"品种"];
        
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        [petdatadic setObject:[dict objectForKey:@"birthday"] forKey:@"生日"];
        [petdatadic setObject:[numberFormatter stringFromNumber:[dict objectForKey:@"height"]] forKey:@"身高"];
        [petdatadic setObject:[numberFormatter stringFromNumber:[dict objectForKey:@"weight"]] forKey:@"体重"];
        
        NSString *district = [dict objectForKey:DISTRICT];
        if (district == nil) {
            district = @"";
        }
        [petdatadic setObject:district forKey:@"城市"];
        
        NSString *place = [dict objectForKey:PLACEOFTENGO];
        if (place == nil) {
            place = @"";
        }
        [petdatadic setObject:place forKey:@"常去玩的地方"];
        if ([dict objectForKey:@"avatar"]) {
            [petdatadic setObject:[dict objectForKey:@"avatar"] forKey:@"headphoto"];
     
        }
        [dict release];
        
    }
    [self jumpToPetInfoDetailView];
    
}

- (void)jumpToPetInfoDetailView {
    _Petdocumentlist.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(239/255.0) blue:(240/255.0) alpha:1];
    _petinfotableview.title = @"宠物档案";
    [self makeTabBarHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:_petinfotableview animated:YES];
    self.hidesBottomBarWhenPushed = NO;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStyleDone target:self action:@selector(backaction)];
    _petinfotableview.navigationItem.leftBarButtonItem = leftItem;
}

//宠物档案点击头像触发的事件
-(void)takephotoclick:(id)sender{
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
        [_petphoto setImage:image];
        
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
        [[NSFileManager defaultManager] createFileAtPath:imagePath contents:data attributes:nil];
        
    }
    UserBean *user = [[UserManager shareUserManager] userBean];
    PetInfo *petInfo = [user petInfo];
    long petid = petInfo == nil ? 0 : [petInfo.petId longValue];
    Enhttpmanager *http = [[Enhttpmanager alloc]init];
    [http uploadimage:self selector:@selector(uploadImgCallback:) username:user.name petid:petid imagepath:imagePath];
    [http release];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    return;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_nameinput resignFirstResponder];
    return YES;
}

//设置图片本地存储地址
-(void)setimagepath{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    //指定新建文件夹路径
    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:@"ImageFile"];
    //创建ImageFile文件夹
    [[NSFileManager defaultManager] createDirectoryAtPath:imageDocPath withIntermediateDirectories:YES attributes:nil error:nil];
    //保存图片的路径
    imagePath = [imageDocPath stringByAppendingPathComponent:@"image.png"];
}

//宠物档案中的返回按钮触发的事件
- (void)backaction{
    if (whichback) {
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (![[defaults objectForKey:@"whichsave"]isEqualToString:@"品种"]&&![[defaults objectForKey:@"whichsave"]isEqualToString:@"性别"] &&
            ![[defaults objectForKey:@"whichsave"] isEqualToString:@"生日"]){
            if ([_nameinput superview]) {
                [_nameinput removeFromSuperview];
            }
            if ([_unitlabel superview]) {
                [_unitlabel removeFromSuperview];
            }
        }else if ([[defaults objectForKey:@"whichsave"]isEqualToString:@"品种"]){
            [_Pettypelist removeFromSuperview];
        } else if ([[defaults objectForKey:@"whichsave"] isEqualToString:@"生日"]) {
            [_datePicker removeFromSuperview];
        } else{
            [_sextype removeFromSuperview];
        }
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController popViewControllerAnimated:YES];
        self.hidesBottomBarWhenPushed = NO;
        whichback = false;
    }else{
        //[self tabbarappear];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.navigationItem.title = @"设置";
        [self.navigationController popViewControllerAnimated:YES];
        
        UserBean *user = [[UserManager shareUserManager] userBean];
        PetInfo *petInfo = user.petInfo;
        
        NSString *breedStr = [petdatadic objectForKey:@"品种"];
        NSInteger breed = 0;
        if (breedStr) {
            breed = [pettypes indexOfObject:breedStr];
        }
        NSString *sexStr = [petdatadic objectForKey:@"性别"];
        NSInteger petsex = 0;
        if (sexStr) {
            petsex = [petsexs indexOfObject:sexStr];
        }
        
        
        long petId = 0;
        if (petInfo != nil && petInfo.petId != nil) {
            petId = [[petInfo petId] longValue];
        }
        
        Enhttpmanager *modifyhttpmanager = [[Enhttpmanager alloc]init];
        [modifyhttpmanager ModifyPetinfo:self selector:@selector(modifycallback:) username:[defaults objectForKey:@"username"] petid:petId nickname:[petdatadic objectForKey:@"昵称"] sex:petsex breed:breed age:[petdatadic objectForKey:@"生日"] height:[petdatadic objectForKey:@"身高"] weight:[petdatadic objectForKey:@"体重"] district:[petdatadic objectForKey:@"城市"] placeoftengo:[petdatadic objectForKey:@"常去玩的地方"]];
        [modifyhttpmanager release];
    }
}

//点击退出按钮触发的事件
- (void)logoutButtonClick {
    UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否退出客户端？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertview.tag = 0;
    
    
    [alertview show];
    [alertview release];
}

-(void)modifycallback:(NSArray*)args{
    NSLog(@"modifycallback: %@", args);
    
}

- (void)uploadImgCallback:(NSArray *)args {
    NSLog(@"upload image call back: %@", args);
}

//访问黑名单列表接口，返回的信息
-(void)getblacklistcallback:(NSArray*)args{
    if ([[args objectAtIndex:0] intValue] == PORTAL_RESULT_GET_BLACKLIST_SUCCESS) {
        NSDictionary *dict = [[NSDictionary alloc]initWithDictionary:[args objectAtIndex:2]];
        if ([[dict objectForKey:@"result"] intValue] == 0) {
            NSArray *array = [[NSArray alloc] initWithArray:[dict objectForKey:@"list"]];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:array forKey:@"blacklist"];
            [defaults synchronize];
            [self makeTabBarHidden:YES];
//             [self.navigationController setNavigationBarHidden:NO animated:NO];
            self.hidesBottomBarWhenPushed = YES;
            PetBlackListController *blacklistctrl = [[PetBlackListController alloc]init];
            blacklistctrl.title = @"黑名单管理";
            [self.navigationController pushViewController:blacklistctrl animated:YES];
            self.hidesBottomBarWhenPushed = NO;
        }
    }
}

//访问相册列表接口返回的信息
-(void)getgallerylist:(NSArray*)args{
    if ([[args objectAtIndex:0] intValue] == PORTAL_RESULT_GET_GALLERYLIST_SUCCESS) {
        NSDictionary *dict = [[NSDictionary alloc]initWithDictionary:[args objectAtIndex:2]];
        if ([[dict objectForKey:@"result"] intValue] == 0) {
            NSArray *array = [[NSArray alloc] initWithArray:[dict objectForKey:@"list"]];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:array forKey:@"gallerylist"];
            [array release];
            [defaults synchronize];
            
            self.hidesBottomBarWhenPushed = YES;
            [self makeTabBarHidden:YES];
//            [self.navigationController setNavigationBarHidden:NO animated:NO];
            _gallerylistctrl = [[GalleryViewController alloc]init];
            [_gallerylistctrl setType:0];
            [_gallerylistctrl setContentArray:[dict objectForKey:@"list"]];
            _gallerylistctrl.title = @"相册";
            [self.navigationController pushViewController:_gallerylistctrl animated:YES];
            self.hidesBottomBarWhenPushed = NO;
            [self tabbarappear];
            //[_gallerylistctrl release];
        }
        [dict release];
    }
}

- (void)addbackviewandsavebtn{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![[defaults objectForKey:@"whichsave"]isEqualToString:@"品种"]&&![[defaults objectForKey:@"whichsave"]isEqualToString:@"性别"]) {
        _nameinput = [[[UITextField alloc]initWithFrame:CGRectMake(20, 18, 280, 36)]autorelease];
        if ([[defaults objectForKey:@"whichsave"]isEqualToString:@"生日"]) {
//            _nameinput = [[[UITextField alloc]initWithFrame:CGRectMake(20, 18, 240, 36)]autorelease];
//            _unitlabel = [[[UILabel alloc]initWithFrame:CGRectMake(265, 18, 40, 36)]autorelease];
//            _unitlabel.text = @"月";
//            [_unitlabel setBackgroundColor:[UIColor clearColor]];
//            [_backviewctrl.view addSubview:_unitlabel];
            
            _datePicker = [[[UIDatePicker alloc] initWithFrame:CGRectMake(0, 18, 325, 300)] autorelease];
//            [_datePicker addTarget:self action:@selector(birthdateChanged:) forControlEvents:UIControlEventValueChanged];
            [_datePicker setDatePickerMode:UIDatePickerModeDate];
        }
        if ([[defaults objectForKey:@"whichsave"]isEqualToString:@"身高"]) {
            _nameinput = [[[UITextField alloc]initWithFrame:CGRectMake(20, 18, 240, 36)]autorelease];
            _unitlabel = [[[UILabel alloc]initWithFrame:CGRectMake(265, 18, 40, 36)]autorelease];
            _unitlabel.text = @"厘米";
            [_unitlabel setBackgroundColor:[UIColor clearColor]];
            [_backviewctrl.view addSubview:_unitlabel];
        }
        if ([[defaults objectForKey:@"whichsave"]isEqualToString:@"体重"]) {
            _nameinput = [[[UITextField alloc]initWithFrame:CGRectMake(20, 18, 240, 36)]autorelease];
            _unitlabel = [[[UILabel alloc]initWithFrame:CGRectMake(265, 18, 40, 36)]autorelease];
            _unitlabel.text = @"公斤";
            [_unitlabel setBackgroundColor:[UIColor clearColor]];
            [_backviewctrl.view addSubview:_unitlabel];
        }
        [_nameinput setBorderStyle:UITextBorderStyleRoundedRect];
        [_nameinput setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_nameinput setKeyboardType:UIKeyboardTypeDefault];
        [_nameinput setReturnKeyType:UIReturnKeyDone];
        _nameinput.delegate = self;
    }
    _backviewctrl.view.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(239/255.0) blue:(240/255.0) alpha:1];
    _backviewctrl.title = [defaults objectForKey:@"whichsave"];;
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

//显示tabbar
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

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 0) {
        if (buttonIndex == 1) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:@"" forKey:USERNAME];
            [userDefaults setObject:@"" forKey:USERKEY];
            [userDefaults setObject:@"" forKey:PETINFO];
            BOOL ret = [userDefaults synchronize];
            NSLog(@"save before exit: %d", ret);
            exit(0);
        }
    }
    
}


- (void)dealloc {
    [_Petdocumentlist release];
    [_contentArray release];
    [_contentdict release];
    [_contentArray1 release];
    [_takephotobtn release];
    [_petphoto release];
    [_nameinput release];
    [_petinfo release];
    [_Pettypelist release];
    [_lastIndexPath release];
    [_sextype release];
    [_lastIndexPath1 release];
    [_petinfotableview release];
    [_backviewctrl release];
    [_gallerylistctrl release];
    [_unitlabel release];
    [super dealloc];
}

@end
