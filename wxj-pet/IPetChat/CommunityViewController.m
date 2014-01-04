//
//  CommunityViewController.m
//  IPetChat
//
//  Created by XF on 13-11-7.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "CommunityViewController.h"

@interface CommunityViewController ()

@end

@implementation CommunityViewController
@synthesize listViewController = _listViewController;
@synthesize contentArray = _contentArray;

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
        self.title = @"社区";
        
//        if ([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending) {
//            [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ic_tab_community_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"ic_tab_community_unselected.png"]];
//            [self.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -3.0)];
//        }
//        else {
//            [self.tabBarItem setImage:[UIImage imageNamed:@"ic_tab_community_unselected.png"]];
//        }
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Community", @"社区") image:[UIImage imageNamed:@"ic_tab_community_unselected"] tag:2];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.scrollEnabled = FALSE;
    NSArray *arr1 = [[NSArray alloc] initWithObjects:@"宠物之星推荐", @"img_petstar.png", nil];
    NSArray *arr2 = [[NSArray alloc] initWithObjects:@"附近的宠物", @"img_petnearby.png", nil];
    NSArray *arr3 = [[NSArray alloc] initWithObjects:@"我的关注", @"img_concern.png", nil];
    NSArray *arr4 = [[NSArray alloc] initWithObjects:@"留言箱", @"img_messagebox.png", nil];
    self.contentArray = [NSArray arrayWithObjects:arr1, arr2, arr3, arr4, nil];
    [arr1 release];
    [arr2 release];
    [arr3 release];
    [arr4 release];
    //_contentArray = [NSArray arrayWithObjects:@"宠物之星推荐", @"附件的宠物", @"我的关注", @"留言箱", nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (self.tabBarController.tabBar.hidden == TRUE) {
        self.tabBarController.tabBar.hidden = FALSE;
    }
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
    return [self.contentArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    [[cell textLabel] setText:[[self.contentArray objectAtIndex:[indexPath section]] objectAtIndex:0]];
    [[cell imageView] setImage:[UIImage imageNamed:[[self.contentArray objectAtIndex:[indexPath section]] objectAtIndex:1]]];
    return cell;
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
    [self makeTabBarHidden:YES];
    
    [self.listViewController setStylenum:[indexPath section]];
    [self.listViewController.tableView reloadData];
    self.listViewController.title = [[self.contentArray objectAtIndex:[indexPath section]] objectAtIndex:0];
    [self.navigationController pushViewController:self.listViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//隐藏tab
- (void)makeTabBarHidden:(BOOL)hide {
    UIView *contentView;
    if ([[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]]) {
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    }
    else contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    
    if (hide) {
        contentView.frame = CGRectMake(self.tabBarController.view.bounds.origin.x, self.tabBarController.view.bounds.origin.y, self.tabBarController.view.bounds.size.width, self.tabBarController.view.bounds.size.height);
    }
    self.tabBarController.tabBar.hidden = hide;
}

- (void)dealloc {
    [_listViewController release];
    [_contentArray release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setListViewController:nil];
    [super viewDidUnload];
}
@end
