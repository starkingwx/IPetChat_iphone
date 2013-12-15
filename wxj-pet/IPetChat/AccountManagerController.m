//
//  AccountManagerController.m
//  IPetChat
//
//  Created by WXJ on 13-11-25.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "AccountManagerController.h"
#import "Enhttpmanager.h"

@interface AccountManagerController ()

@end

@implementation AccountManagerController
@synthesize accountshow = _accountshow;
@synthesize username = _username;
@synthesize backview = _backview;
@synthesize oldpwd = _oldpwd;
@synthesize newpwd = _newpwd;
@synthesize confirmpwd = _confirmpwd;
@synthesize modifyctrl = _modifyctrl;

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
    _accountshow.scrollEnabled = NO;
    _confirmpwd.text = @"";
    _newpwd.text = @"";
    _oldpwd.text = @"";
    self.view.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(239/255.0) blue:(240/255.0) alpha:1];
    _modifyctrl.view.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(239/255.0) blue:(240/255.0) alpha:1];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    UIFont *font = [UIFont systemFontOfSize:20];
    [[cell textLabel] setFont:font];
    if ([indexPath section] == 0) {
        [[cell textLabel] setText:@"赛果号"];
        CGSize size = [cell.textLabel.text sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT,44)lineBreakMode:UILineBreakModeWordWrap];
        _username = [[UILabel alloc]initWithFrame:CGRectMake(size.width, 0, 280-size.width, 44)];
        _username.backgroundColor = [UIColor clearColor];
        _username.textAlignment = UITextAlignmentRight;
        _username.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"username"];
        [cell.contentView addSubview:_username];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }else{
        [[cell textLabel] setText:@"修改密码"];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    _accountshow.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(239/255.0) blue:(240/255.0) alpha:1];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIColor *color =  [UIColor colorWithRed:(255/255.0) green:(252/255.0) blue:(252/255.0) alpha:1];
    cell.backgroundColor = color;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 1) {
        _modifyctrl.title = @"修改密码";
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:_modifyctrl animated:YES];
        self.hidesBottomBarWhenPushed = YES;
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(savenewpwdclick)];
        _modifyctrl.navigationItem.rightBarButtonItem = rightItem;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

//点击修改密码触发的事件
-(void)savenewpwdclick
{
    NSString *msg = [[NSString alloc]init];
    if ([_oldpwd.text isEqualToString:@""]) {
        msg = @"旧密码不能为空";
    }else if ([_newpwd.text isEqualToString:@""]) {
        msg = @"新密码不能为空";
    }else if ([_confirmpwd.text isEqualToString:@""]) {
        msg = @"确认密码不能为空";
    }else if (![_newpwd.text isEqualToString:_confirmpwd.text]) {
        msg = @"新密码和确认密码不一致";
    }else{
        Enhttpmanager *modifymanager = [[Enhttpmanager alloc]init];
        [modifymanager modifypwd:self selector:@selector(modifypwdcallback:) username:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] oldpwd:_oldpwd.text newpwd:_newpwd.text confirmpwd:_confirmpwd.text];
        return;
    }
    UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertview show];
    [alertview release];
    [msg release];
    
}

//访问修改密码接口返回的信息
-(void)modifypwdcallback:(NSArray*)args{
    NSDictionary *dict = [args objectAtIndex:2];
    NSString *msg = [[NSString alloc]init];
    if ([[args objectAtIndex:0]intValue] == PORTAL_RESULT_MODIFY_PWD_SUCCESS) {
        int result = [[dict objectForKey:@"result"] intValue];
        if (result == 0) {
            [self.navigationController popViewControllerAnimated:YES];
            msg = @"修改密码成功";
        }else if (result == 3){
            msg = @"修改密码失败";
        }else if (result == 4){
            msg = @"旧密码不正确";
        }
    }else{
        msg = @"网络有问题，请稍后再试";
    }
    UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertview show];
    [alertview release];
    [msg release];
}

//收回键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_oldpwd resignFirstResponder];
    [_newpwd resignFirstResponder];
    [_confirmpwd resignFirstResponder];
    return YES;
}

- (void)dealloc{
    [_accountshow release];
    [_username release];
    [_backview release];
    [_oldpwd release];
    [_modifyctrl release];
    [_newpwd release];
    [_confirmpwd release];
    [super dealloc];
}

@end
