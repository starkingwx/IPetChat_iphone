//
//  PetInfoViewController.m
//  IPetChat
//
//  Created by XF on 13-11-8.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "PetInfoViewController.h"
#import "Enhttpmanager.h"
#import "QuartzCore/CALayer.h"
#import "GalleryViewController.h"

#define IMGPATH @"http://www.segopet.com/segoimg/"

@interface PetInfoViewController ()

@end

@implementation PetInfoViewController
@synthesize type = _type;
@synthesize contentDic = _contentDic;
@synthesize petId = _petId;
@synthesize avatar = _avatar;
@synthesize nickname = _nickname;
@synthesize sex = _sex;
@synthesize detail = _detail;
@synthesize leavemsgButton = _leavemsgButton;
@synthesize concernpetButton = _concernpetButton;
@synthesize moreactionView = _moreactionView;
@synthesize picsScrollView = _picsScrollView;
@synthesize leavemsgViewController = _leavemsgViewController;

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
    [super viewDidLoad];
    
    UIView *backview = [[UIView alloc] initWithFrame:CGRectMake(218, 10, 100, 80.5)];
    [backview setBackgroundColor:[UIColor darkGrayColor]];
    backview.layer.cornerRadius = 6;
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    [button1 setTitle:@"取消关注" forState:UIControlStateNormal];
    [button1 setBackgroundColor:[UIColor clearColor]];
    [button1 addTarget:self action:@selector(unconcernpetclick) forControlEvents:UIControlEventTouchUpInside];
    [backview addSubview:button1];
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 40.5, 100, 40)];
    [button2 setTitle:@"拉黑" forState:UIControlStateNormal];
    [button2 setBackgroundColor:[UIColor clearColor]];
    [button2 addTarget:self action:@selector(addblacklistclick) forControlEvents:UIControlEventTouchUpInside];
    [backview addSubview:button2];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 100, 0.5)];
    [line setBackgroundColor:[UIColor whiteColor]];
    [backview addSubview:line];
    
    self.moreactionView = backview;
    self.moreactionView.tag = 101;
    [backview release];
    [button1 release];
    [button2 release];
    [line release];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushtoGalleryController)];
    [self.picsScrollView addGestureRecognizer:tap];
    [tap release];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.avatar setImage:nil];
    [self.sex setImage:nil];
    [self.nickname setText:@"昵称"];
    self.detail.text = @"品种 ：\n年龄 ：\n身高 ：\n体重 ：\n城市 ：\n常去玩的地方 ：";
    for (UIView *subView in self.picsScrollView.subviews)
    {
        [subView removeFromSuperview];
    }
    //没有关注按钮，需要getpetdetail
    if (self.type == 0) {
        self.concernpetButton.hidden = TRUE;
        CGRect mframe = self.leavemsgButton.frame;
        mframe.size.width = 280;
        self.leavemsgButton.frame = mframe;
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"more" style:UIBarButtonItemStyleDone target:self action:@selector(moreaction)];
        self.navigationItem.rightBarButtonItem = rightItem;
        [rightItem release];
        
        Enhttpmanager *httpmanager = [[Enhttpmanager alloc] init];
        [httpmanager getpetdetail:self selector:@selector(getpetdetailCallback:) petid:self.petId];
        [httpmanager release];
    }
    //有关注按钮，需要getpetdetail
    else if (self.type == 1) {
        self.concernpetButton.hidden = FALSE;
        CGRect mframe = self.leavemsgButton.frame;
        mframe.size.width = 120;
        self.leavemsgButton.frame = mframe;
        
        self.navigationItem.rightBarButtonItem = nil;
        
        Enhttpmanager *httpmanager = [[Enhttpmanager alloc] init];
        [httpmanager getpetdetail:self selector:@selector(getpetdetailCallback:) petid:self.petId];
        [httpmanager release];
    }
    //有关注按钮，不需要getpetdetail
    else {
        self.concernpetButton.hidden = FALSE;
        CGRect mframe = self.leavemsgButton.frame;
        mframe.size.width = 120;
        self.leavemsgButton.frame = mframe;
        
        self.navigationItem.rightBarButtonItem = nil;
        
        [self showpetinfo];
    }
    
    self.hidesBottomBarWhenPushed = YES;
    if (self.tabBarController.tabBar.hidden == TRUE) {
        UIView *contentView;
        if ([[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]]) {
            contentView = [self.tabBarController.view.subviews objectAtIndex:1];
        }
        else contentView = [self.tabBarController.view.subviews objectAtIndex:0];
        
        contentView.frame = CGRectMake(self.tabBarController.view.bounds.origin.x, self.tabBarController.view.bounds.origin.y, self.tabBarController.view.bounds.size.width, self.tabBarController.view.bounds.size.height);
        
        self.tabBarController.tabBar.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - callback

//访问获取宠物详细信息接口返回的信息
- (void)getpetdetailCallback:(NSArray*)args {
    if ([[args objectAtIndex:0] integerValue] == PORTAL_RESULT_GET_PETDETAIL_SUCCESS) {
        self.contentDic  = [args objectAtIndex:2];
        [self showpetinfo];
    }
    else {
        //////
    }
}

//访问获取关注宠物接口返回的信息
- (void)concernpetsCallback:(NSArray*)args {
    if ([[args objectAtIndex:0] integerValue] == PORTAL_RESULT_CONCERN_PETS_SUCCESS) {
        NSString *text = @"";
        switch ([[[args objectAtIndex:2] objectForKey:@"result"] integerValue]) {
            case 0:
                text = @"宠物关注成功";
                break;
            case 1:
                text = @"宠物不存在";
                break;
            case 2:
                text = @"petid为空";
                break;
            case 3:
                text = @"宠物已经被关注过了";
                break;
            case 4:
                text = @"宠物关注失败";
                break;
            default:
                break;
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:text delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        //////
    }
}

//访问取消关注宠物接口返回的信息
- (void)unconcernpetsCallback:(NSArray*)args {
    if ([[args objectAtIndex:0] integerValue] == PORTAL_RESULT_UNCONCERN_PETS_SUCCESS) {
        NSString *text = @"";
        switch ([[[args objectAtIndex:2] objectForKey:@"result"] integerValue]) {
            case 0:
                text = @"宠物取消关注成功";
                break;
            case 1:
                text = @"宠物不存在";
                break;
            case 2:
                text = @"petid为空";
                break;
            case 3:
                text = @"未关注此宠物";
                break;
            default:
                break;
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:text delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        //////
    }
}

//访问添加为黑名单接口返回的信息
- (void)addblacklistCallback:(NSArray*)args {
    if ([[args objectAtIndex:0] integerValue] == PORTAL_RESULT_ADD_BLACKLIST_SUCCESS) {
        NSString *text = @"";
        switch ([[[args objectAtIndex:2] objectForKey:@"result"] integerValue]) {
            case 0:
                text = @"宠物添加黑名单成功";
                break;
            case 1:
                text = @"宠物不存在";
                break;
            case 2:
                text = @"petid为空";
                break;
            case 3:
                text = @"宠物已经在黑名单中";
                break;
            case 4:
                text = @"宠物添加黑名单失败";
                break;
            default:
                break;
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:text delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        //////
    }
}

#pragma mark - Action

//显示关注宠物的详细信息
- (void)showpetinfo {
    //[self.avatar setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[IMGPATH stringByAppendingString:[self.contentDic objectForKey:@"avatar"]]]]]];
    self.avatar.imageURL = [IMGPATH stringByAppendingString:[self.contentDic objectForKey:@"avatar"]];
    [self.nickname setText:[self.contentDic objectForKey:@"nickname"]];
    
    CGSize nicknameSize = [self.nickname.text sizeWithFont:[UIFont systemFontOfSize:20] constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
    CGRect aframe = self.sex.frame;
    aframe.origin.x = 130+nicknameSize.width;
    self.sex.frame = aframe;
    if ([[self.contentDic objectForKey:@"sex"] integerValue] == 0) {
        [self.sex setImage:[UIImage imageNamed:@"img_male.png"]];
    }
    else {
        [self.sex setImage:[UIImage imageNamed:@"img_female.png"]];
    }
    
    NSArray *arr = [NSArray arrayWithObjects:@"黄金猎犬", @"哈士奇", @"贵宾（泰迪）", @"萨摩耶", @"博美", @"雪纳瑞", @"苏格兰牧羊犬", @"松狮", @"京巴", @"其它", nil];
    self.detail.text = [NSString stringWithFormat:@"品种 ：%@\n年龄 ：%@个月\n身高 ：%@厘米\n体重 ：%@公斤\n城市 ：%@\n常去玩的地方 ：%@",[arr objectAtIndex:[[self.contentDic objectForKey:@"breed"] integerValue]],[self.contentDic objectForKey:@"age"],[self.contentDic objectForKey:@"height"],[self.contentDic objectForKey:@"weight"],[self.contentDic objectForKey:@"district"],[self.contentDic objectForKey:@"placeoftengo"]];
    
    self.picsScrollView.contentSize = CGSizeMake(85*[[self.contentDic objectForKey:@"galleries"] count]+8, 120);
    for (int i = 0; i < [[self.contentDic objectForKey:@"galleries"] count]; i++) {
        AsynImageView *imageview = [[AsynImageView alloc] initWithFrame:CGRectMake(8+85*i, 2, 77, 116)];
        imageview.imageURL = [IMGPATH stringByAppendingString:[[[self.contentDic objectForKey:@"galleries"] objectAtIndex:i] objectForKey:@"cover_url"]];
        [imageview setContentMode:UIViewContentModeScaleAspectFit];
        [self.picsScrollView addSubview:imageview];
        [imageview release];
    }
    //[tap release];
}

//点击关注宠物详细信息页面中的more按钮触发的操作
- (void)moreaction {
    if (self.moreactionView.tag == 101) {
        [self.view addSubview:self.moreactionView];
        self.moreactionView.tag = 102;
    }
    else {
        [self.moreactionView removeFromSuperview];
        self.moreactionView.tag = 101;
    }
}


//点击关注宠物详细信息页面中的取消关注按钮触发的操作
- (void)unconcernpetclick {
    Enhttpmanager *httpmanager = [[Enhttpmanager alloc] init];
    [httpmanager unconcernpets:self selector:@selector(unconcernpetsCallback:) username:@"18652970720" petid:[[self.contentDic objectForKey:@"petid"] longValue]];
    [httpmanager release];
    
    [self.moreactionView removeFromSuperview];
    self.moreactionView.tag = 101;
}

//点击关注宠物详细信息页面中的加入黑名单按钮触发的操作
- (void)addblacklistclick {
    Enhttpmanager *httpmanager = [[Enhttpmanager alloc] init];
    [httpmanager addblacklist:self selector:@selector(concernpetsCallback:) username:@"18652970720" petid:[[self.contentDic objectForKey:@"petid"] longValue]];
    [httpmanager release];
    
    [self.moreactionView removeFromSuperview];
    self.moreactionView.tag = 101;
}

//进入相册列表
- (void)pushtoGalleryController {
    GalleryViewController *gallerylistctrl = [[GalleryViewController alloc] initWithNibName:@"GalleryViewController" bundle:nil];
    [gallerylistctrl setType:1];
    [gallerylistctrl setContentArray:[self.contentDic objectForKey:@"galleries"]];
    gallerylistctrl.title = @"相册";
    [self.navigationController pushViewController:gallerylistctrl animated:YES];
    [gallerylistctrl release];
}


- (IBAction)leavemsgButtonClick:(id)sender {
    [self.leavemsgViewController setType:1];
    [self.leavemsgViewController setPetID:self.petId];
    self.leavemsgViewController.title = @"留言箱";
    [self.navigationController pushViewController:self.leavemsgViewController animated:YES];
}

- (IBAction)concernpetButtonClick:(id)sender {
    Enhttpmanager *httpmanager = [[Enhttpmanager alloc] init];
    [httpmanager concernpets:self selector:@selector(concernpetsCallback:) username:@"18652970720" petid:[[self.contentDic objectForKey:@"petid"] longValue]];
    [httpmanager release];
}

- (void)dealloc {
    [_avatar release];
    [_nickname release];
    [_sex release];
    [_detail release];
    [_leavemsgButton release];
    [_concernpetButton release];
    [_picsScrollView release];
    [_leavemsgViewController release];
    [super dealloc];
}

@end
