//
//  ConcernPetViewController.m
//  IPetChat
//
//  Created by orangeskiller on 13-11-20.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "ConcernPetViewController.h"
#import "Enhttpmanager.h"

@interface ConcernPetViewController ()

@end

@implementation ConcernPetViewController
@synthesize phonenumTextField = _phonenumTextField;
@synthesize petInfoAndConernViewController = _petInfoAndConernViewController;

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
    self.phonenumTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"查找" style:UIBarButtonItemStyleDone target:self action:@selector(searchpetsclick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.phonenumTextField.text = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//在我的关注点击添加关注按钮，进入搜索页面，点击查找按钮触发的操作
- (void)searchpetsclick {
    [self.phonenumTextField resignFirstResponder];
    
    if (![self.phonenumTextField.text isEqualToString:@""]) {
        Enhttpmanager *httpmanager = [[Enhttpmanager alloc] init];
        [httpmanager searchpets:self selector:@selector(searchpetsCallback:) phone:self.phonenumTextField.text];
        [httpmanager release];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"赛果号/手机号不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
}

//访问搜索宠物接口返回的信息
- (void)searchpetsCallback:(NSArray*)args {
    if ([[args objectAtIndex:0] integerValue] == PORTAL_RESULT_SEARCH_PETS_SUCCESS) {
        if ([[[args objectAtIndex:2] objectForKey:@"result"] integerValue] == 0) {
            if ([[args objectAtIndex:2] objectForKey:@"list"] != nil) {
                [self.petInfoAndConernViewController setType:2];
                [self.petInfoAndConernViewController setContentDic:[[[args objectAtIndex:2] objectForKey:@"list"] objectAtIndex:0]];
                self.petInfoAndConernViewController.title = @"详细资料";
                [self.navigationController pushViewController:self.petInfoAndConernViewController animated:YES];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有找到此帐号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                [alertView release];
            }
        }
        else {
            //////
        }
    }
    else {
        //////
    }
}
     
- (void)dealloc {
    [_phonenumTextField release];
    [_petInfoAndConernViewController release];
    [super dealloc];
}
@end
