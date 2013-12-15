//
//  sendphotoController.m
//  IPetChat
//
//  Created by WXJ on 13-12-2.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "sendphotoController.h"
#import "Enhttpmanager.h"

#define server_path_image   "http://www.segopet.com/segoimg/"

@interface sendphotoController ()

@end

@implementation sendphotoController
@synthesize photodescribefield = _photodescribefield;
@synthesize contentArray = _contentArray;
@synthesize sendphotoimage = _sendphotoimage;
@synthesize basealert = _basealert;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(sendphotoclick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.view.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(239/255.0) blue:(240/255.0) alpha:1];
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    // Return the number of rows in the section.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath section] == 0) {
        return 44;
    }else if ([indexPath section] == 1){
        return 150;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if ([indexPath section] == 0) {
        cell.textLabel.text = [_contentArray objectAtIndex:1];
    }else{
        //cell.backgroundColor = [UIColor grayColor];
        _sendphotoimage = [[UIImageView alloc]initWithFrame:CGRectMake(130, 5, 90, 90)];
        _sendphotoimage.image = [UIImage imageWithContentsOfFile:[_contentArray objectAtIndex:0]];
        _photodescribefield = [[UITextField alloc]initWithFrame:CGRectMake(30, 104, 260, 40)];
        _photodescribefield.borderStyle = UITextBorderStyleRoundedRect;
        _photodescribefield.placeholder = @"这一刻的想法";
        [_photodescribefield setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        _photodescribefield.delegate = self;
        [cell addSubview:_sendphotoimage];
        [cell addSubview:_photodescribefield];
    }
    
    return cell;
}

-(void)sendphotoclick{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
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
    [http uploadgalleryimage:self selector:@selector(uploadviewcallback:) username:[defaults objectForKey:@"username"] galleryid:[[defaults objectForKey:@"mygallery"]intValue] imagepath:[_contentArray objectAtIndex:0] name:@"" type:@"" description:_photodescribefield.text];
    [http release];
    
    //self.hidesBottomBarWhenPushed = YES;
    //[self.navigationController popToRootViewControllerAnimated:YES];
    
}

-(void)uploadviewcallback:(NSArray*)args{
    if (_basealert) {
        [_basealert dismissWithClickedButtonIndex:0 animated:YES];
        _basealert = nil;
    }

    NSString *msg = @"上传失败";
    if ([[args objectAtIndex:0]intValue] == PORTAL_RESULT_UPLOAD_GALLERYIMAGE_SUCCESS) {
        if ([[[args objectAtIndex:2] objectForKey:@"result"]intValue] == 0) {
            msg = @"上传成功";
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:TRUE forKey:@"addphotoornot"];
            [defaults synchronize];
        }
    }
    UIAlertView *Alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [Alertview show];
    [Alertview release];
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_photodescribefield resignFirstResponder];
    return YES;
}

-(void)dealloc{
    [_sendphotoimage release];
    [_photodescribefield release];
    [_contentArray release];
    [_basealert release];
    [super dealloc];
}

@end
