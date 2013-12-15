//
//  PetBlackListController.m
//  IPetChat
//
//  Created by WXJ on 13-11-26.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "PetBlackListController.h"

#define server_path_image   "http://www.segopet.com/segoimg/"

@interface PetBlackListController ()

@end

@implementation PetBlackListController
@synthesize petblacklist = _petblacklist;
@synthesize contentArray = _contentArray;

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
    _contentArray = [defaults objectForKey:@"blacklist"];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_contentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary *petdict = [[NSDictionary alloc] initWithDictionary:[_contentArray objectAtIndex:[indexPath row]]];
    // Configure the cell...
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    UIFont *font = [UIFont systemFontOfSize:20];
    [[cell textLabel] setFont:font];
    
    UILabel *nickname = [[UILabel alloc] initWithFrame:CGRectMake(90, 4, 210, 20)];
    [nickname setBackgroundColor:[UIColor clearColor]];
    nickname.text = [petdict objectForKey:@"nickname"];
    [cell addSubview:nickname];
    [nickname release];
    
    UIImageView *profilepic = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 72, 54)];
    NSMutableString *urlstr = [[NSMutableString alloc]initWithString:@server_path_image];
    [urlstr appendString:[petdict objectForKey:@"avatar"]];
    [profilepic setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlstr]]]];
    [cell addSubview:profilepic];
    [profilepic release];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIColor *color =  [UIColor colorWithRed:(255/255.0) green:(252/255.0) blue:(252/255.0) alpha:1];
    cell.backgroundColor = color;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (void)dealloc{
    [_petblacklist release];
    [_contentArray release];
    [super dealloc];
}

@end
