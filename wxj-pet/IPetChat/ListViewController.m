//
//  ListViewController.m
//  IPetChat
//
//  Created by XF on 13-11-7.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "ListViewController.h"
#import "QuartzCore/CALayer.h"
#import "pinyin.h"
#import "Enhttpmanager.h"
#import "AsynImageView.h"

#define IMGPATH @"http://www.segopet.com/segoimg/"

@interface ListViewController ()

@end

@implementation ListViewController
@synthesize stylenum;
@synthesize petInfoViewController = _petInfoViewController;
@synthesize concernPetViewController = _concernPetViewController;
@synthesize leaveMsgViewController = _leaveMsgViewController;
@synthesize indexedArray = _indexedArray;
@synthesize sortedDictionary = _sortedDictionary;
@synthesize contentArray1 = _contentArray1;
@synthesize contentArray2 = _contentArray2;
@synthesize contentArray3 = _contentArray3;
@synthesize originArray = _originArray;

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
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    Enhttpmanager *httpmanager = [[Enhttpmanager alloc] init];
    if (stylenum == 0) {
        [httpmanager getrecommendpets:self selector:@selector(getrecommendpetsCallback:) username:@"18652970720"];
    }
    else if (stylenum == 1) {
      //[httpmanager getnearbypets:self selector:@selector(getnearbypetsCallback:) longitude:1.0f latitude:1.0f];
    }
    else if (stylenum == 2) {
        [httpmanager getconcernpets:self selector:@selector(getconcernpetsCallback:) username:@"18652970720"];
    }
    else {
        [httpmanager getleavemsg:self selector:@selector(getleavemsgCallback:) username:@"18652970720" petid:26];
    }
    [httpmanager release];
    
    
    
    if (stylenum == 0) {
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        //[self.tableView setBackgroundColor:[UIColor whiteColor]];
    }
    else {
        [self.tableView setSeparatorColor:[UIColor colorWithWhite:224/255.0 alpha:1]];
        //[self.tableView setBackgroundColor:[UIColor colorWithWhite:202/255.0 alpha:1]];
    }
    
    if (stylenum == 0) {
        UIView *whiteview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 14)];
        self.tableView.tableHeaderView = whiteview;
        self.tableView.tableFooterView = whiteview;
        [whiteview release];
        
        self.navigationItem.rightBarButtonItem = nil;
    }
    else if (stylenum == 2) {
        UISearchBar *bar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        bar.placeholder = @"查找";
        [bar setTintColor:[UIColor colorWithWhite:202/255.0 alpha:1]];
        bar.delegate = self;
        self.tableView.tableHeaderView = bar;
        self.tableView.tableFooterView = nil;
        [bar release];
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(concernpetclick)];
        self.navigationItem.rightBarButtonItem = rightItem;
        [rightItem release];
    }
    else if (stylenum == 3) {
        UISearchBar *bar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        bar.placeholder = @"查找";
        [bar setTintColor:[UIColor colorWithWhite:202/255.0 alpha:1]];
        bar.delegate = self;
        self.tableView.tableHeaderView = bar;
        self.tableView.tableFooterView = nil;
        [bar release];
        
        self.navigationItem.rightBarButtonItem = nil;
    }
    else {
        self.tableView.tableHeaderView = nil;
        self.tableView.tableFooterView = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.hidesBottomBarWhenPushed = YES;
    if (self.tabBarController.tabBar.hidden == FALSE) {
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

#pragma mark - sorting an array

- (NSMutableDictionary *)sortingarray:(NSArray *)unsortedArray {
    NSMutableArray *indexedMutableArray = [NSMutableArray array];
    for (int i = 0; i < [unsortedArray count]; i++) {
        int f = [[[unsortedArray objectAtIndex:i] objectForKey:@"nickname"] characterAtIndex:0];
        if (f > 0x4e00 && f < 0x9fff) {
            //[[unsortedArray objectAtIndex:i] setObject:[[NSString stringWithFormat:@"%c",pinyinFirstLetter(f)] uppercaseString] forKey:@"FirstLetter"];
            [indexedMutableArray addObject:[[NSString stringWithFormat:@"%c",pinyinFirstLetter(f)] uppercaseString]];
        }
        else {
            //[[unsortedArray objectAtIndex:i] setObject:[[[[unsortedArray objectAtIndex:i] objectForKey:@"nickname"] substringToIndex:1] uppercaseString] forKey:@"FirstLetter"];
            [indexedMutableArray addObject:[[[[unsortedArray objectAtIndex:i] objectForKey:@"nickname"] substringToIndex:1] uppercaseString]];
        }
        //[indexedMutableArray addObject:[[unsortedArray objectAtIndex:i] objectForKey:@"FirstLetter"]];
    }
    self.indexedArray =[NSMutableArray arrayWithArray:[[[NSSet setWithArray:indexedMutableArray] allObjects] sortedArrayUsingComparator:^(NSString *a, NSString *b) {
        return [a compare:b];
    }]];
    [self.indexedArray insertObject:UITableViewIndexSearch atIndex:0];
    
    NSMutableDictionary *sortedDic = [NSMutableDictionary dictionary];
    for (int i = 0; i < [self.indexedArray count]; i++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int j = 0; j < [unsortedArray count]; j++) {
            //[[unsortedArray objectAtIndex:j] objectForKey:@"FirstLetter"]
            if ([[indexedMutableArray objectAtIndex:j] isEqualToString:[self.indexedArray objectAtIndex:i]]) {
                [array addObject:[unsortedArray objectAtIndex:j]];
            }
        }
        [sortedDic setObject:array forKey:[self.indexedArray objectAtIndex:i]];
        [array release];
    }
    
    return sortedDic;
}

#pragma mark - Table view data source

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (stylenum == 2) {
        //self.tableView.sectionIndexColor = [UIColor blueColor];
        //self.tableView.sectionIndexTrackingBackgroundColor = [UIColor orangeColor];

        return self.indexedArray;
    }
    else {
        return nil;
    }
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    /*
    NSInteger count = 0;
    for(NSString *character in self.indexedArray)
    {
        if([character isEqualToString:title])
        {
            return count;
        }
        count ++;
    }
    return 0;*/
    
    NSString *key=[self.indexedArray objectAtIndex:index];
    if (key == UITableViewIndexSearch) {
        [self.tableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    }
    return index;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (stylenum == 2) {
        return [self.indexedArray count];
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (stylenum == 0) {
        return [self.contentArray1 count];
    }
    else if (stylenum == 1) {
        return [self.contentArray2 count];
    }
    else if (stylenum == 2) {
        return [[self.sortedDictionary objectForKey:[self.indexedArray objectAtIndex:section]] count];
    }
    else {
        return [self.contentArray3 count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (stylenum == 0) {
        return 116;
    }
    else {
        return 60;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (stylenum == 0) {
        //[self.tableView setBackgroundColor:[UIColor whiteColor]];
        static NSString *CellIdentifier = @"Cell0";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            UIView *backview = [[UIView alloc] initWithFrame:CGRectMake(24, 2, 272, 112)];
            [backview setBackgroundColor:[UIColor colorWithWhite:202/255.0 alpha:1]];
            backview.layer.cornerRadius = 10.0;
            [cell addSubview:backview];
            [backview release];
            
            UILabel *profiletxt = [[UILabel alloc] initWithFrame:CGRectMake(156, 48, 120, 20)];
            profiletxt.tag = 101;
            [profiletxt setBackgroundColor:[UIColor clearColor]];
            [cell addSubview:profiletxt];
            [profiletxt release];
            
            AsynImageView *profilepic = [[AsynImageView alloc] initWithFrame:CGRectMake(44, 12, 92, 92)];
            profilepic.tag = 102;
            [cell addSubview:profilepic];
            [profilepic release];
        }
        
        for (UIView *view in cell.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                [view removeFromSuperview];
            }
        }
        UIButton *morebutton = [[UIButton alloc] initWithFrame:CGRectMake(216, 80, 80, 30)];
        [morebutton setTitle:@"了解更多" forState:UIControlStateNormal];
        [morebutton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        morebutton.tag = [indexPath row];
        [morebutton addTarget:self action:@selector(lookfordetailclick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:morebutton];
        [morebutton release];
        
        UILabel *label = (UILabel *)[cell viewWithTag:101];
        label.text = [[self.contentArray1 objectAtIndex:[indexPath row]] objectForKey:@"nickname"];
        AsynImageView *imageview = (AsynImageView *)[cell viewWithTag:102];
        //[imageview setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[IMGPATH stringByAppendingString:[[self.contentArray1 objectAtIndex:[indexPath row]] objectForKey:@"avatar"]]]]]];
        imageview.imageURL = [IMGPATH stringByAppendingString:[[self.contentArray1 objectAtIndex:[indexPath row]] objectForKey:@"avatar"]];
        
        return cell;
    }
    else if (stylenum == 1) {
        //[self.tableView setBackgroundColor:[UIColor colorWithWhite:202/255.0 alpha:1]];
        static NSString *CellIdentifier = @"Cell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            
            UILabel *nickname = [[UILabel alloc] initWithFrame:CGRectMake(72, 4, 210, 20)];
            [nickname setBackgroundColor:[UIColor clearColor]];
            nickname.tag = 1;
            [cell addSubview:nickname];
            [nickname release];
            
            AsynImageView *profilepic = [[AsynImageView alloc] initWithFrame:CGRectMake(12, 6, 48, 48)];
            profilepic.tag = 2;
            [cell addSubview:profilepic];
            [profilepic release];
            
            UILabel *distance = [[UILabel alloc] initWithFrame:CGRectMake(72, 34, 210, 20)];
            [distance setBackgroundColor:[UIColor clearColor]];
            [distance setTextAlignment:NSTextAlignmentRight];
            distance.tag = 3;
            [cell addSubview:distance];
            [distance release];
        }
        UILabel *label1 = (UILabel *)[cell viewWithTag:1];
        label1.text = [NSString stringWithFormat:@"%d",stylenum];
        AsynImageView *imageview = (AsynImageView *)[cell viewWithTag:2];
        [imageview setImage:[UIImage imageNamed:@"image.png"]];
        UILabel *label2 = (UILabel *)[cell viewWithTag:3];
        label2.text = [NSString stringWithFormat:@"距您的位置大约%d米",stylenum];
        
        return cell;
    }
    else if (stylenum == 2) {
        //[self.tableView setBackgroundColor:[UIColor colorWithWhite:202/255.0 alpha:1]];
        static NSString *CellIdentifier = @"Cell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            
            UILabel *nickname = [[UILabel alloc] initWithFrame:CGRectMake(72, 20, 100, 20)];
            [nickname setBackgroundColor:[UIColor clearColor]];
            nickname.tag = 1;
            [cell addSubview:nickname];
            [nickname release];
            
            AsynImageView *profilepic = [[AsynImageView alloc] initWithFrame:CGRectMake(12, 6, 48, 48)];
            profilepic.tag = 2;
            [cell addSubview:profilepic];
            [profilepic release];
        }
        NSDictionary *infoDic = [[self.sortedDictionary objectForKey:[self.indexedArray objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
        UILabel *label1 = (UILabel *)[cell viewWithTag:1];
        label1.text = [infoDic objectForKey:@"nickname"];
        AsynImageView *imageview = (AsynImageView *)[cell viewWithTag:2];
        //[imageview setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[IMGPATH stringByAppendingString:[infoDic objectForKey:@"avatar"]]]]]];
        imageview.imageURL = [IMGPATH stringByAppendingString:[infoDic objectForKey:@"avatar"]];
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Cell3";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            
            UILabel *nickname = [[UILabel alloc] initWithFrame:CGRectMake(72, 10, 200, 20)];
            [nickname setBackgroundColor:[UIColor clearColor]];
            nickname.tag = 1;
            [cell addSubview:nickname];
            [nickname release];
            
            AsynImageView *profilepic = [[AsynImageView alloc] initWithFrame:CGRectMake(12, 6, 48, 48)];
            profilepic.tag = 2;
            [cell addSubview:profilepic];
            [profilepic release];
            
            UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(72, 40, 200, 10)];
            [content setBackgroundColor:[UIColor clearColor]];
            [content setFont:[UIFont systemFontOfSize:10]];
            content.tag = 3;
            [cell addSubview:content];
            [content release];
            
            UILabel *timelabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 10, 50, 40)];
            [timelabel setBackgroundColor:[UIColor clearColor]];
            [timelabel setFont:[UIFont systemFontOfSize:12]];
            [timelabel setNumberOfLines:2];
            [timelabel setTextAlignment:NSTextAlignmentRight];
            timelabel.tag = 4;
            [cell addSubview:timelabel];
            [timelabel release];
        }
        UILabel *label1 = (UILabel *)[cell viewWithTag:1];
        label1.text = [[self.contentArray3 objectAtIndex:[indexPath row]] objectForKey:@"leaver_nickname"];
        AsynImageView *imageview = (AsynImageView *)[cell viewWithTag:2];
        //[imageview setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[IMGPATH stringByAppendingString:[[self.contentArray3 objectAtIndex:[indexPath row]] objectForKey:@"leaver_avatar"]]]]]];
        imageview.imageURL = [IMGPATH stringByAppendingString:[[self.contentArray3 objectAtIndex:[indexPath row]] objectForKey:@"leaver_avatar"]];
        UILabel *label2 = (UILabel *)[cell viewWithTag:3];
        label2.text = [[self.contentArray3 objectAtIndex:[indexPath row]] objectForKey:@"content"];
        UILabel *label3 = (UILabel *)[cell viewWithTag:4];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yy-MM-dd hh:mm"];
        label3.text =[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[[self.contentArray3 objectAtIndex:[indexPath row]] objectForKey:@"leave_timestamp"] intValue]]];
        [formatter release];
        
        return cell;
    }
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
    if (stylenum == 0) {
        
    }
    else if (stylenum == 1) {
        [self.petInfoViewController setPetId:[[[self.contentArray2 objectAtIndex:[indexPath row]] objectForKey:@"petid"] longValue]];
        [self.petInfoViewController setType:0];
        self.petInfoViewController.title = @"详细资料";
        [self.navigationController pushViewController:self.petInfoViewController animated:YES];
    }
    else if (stylenum == 2) {
        [self.petInfoViewController setPetId:[[[[self.sortedDictionary objectForKey:[self.indexedArray objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]] objectForKey:@"petid"] longValue]];
        [self.petInfoViewController setType:0];
        self.petInfoViewController.title = @"详细资料";
        [self.navigationController pushViewController:self.petInfoViewController animated:YES];
    }
    else {
        [self.leaveMsgViewController setType:0];
        [self.leaveMsgViewController setMsgID:[[[self.contentArray3 objectAtIndex:[indexPath row]] objectForKey:@"msgid"] longValue]];
        self.leaveMsgViewController.title = @"留言箱";
        [self.navigationController pushViewController:self.leaveMsgViewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - searchBar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchBar.text isEqualToString:@""]) {
        if (stylenum == 2) {
            self.sortedDictionary = [self sortingarray:self.originArray];
        }
        if (stylenum == 3) {
            self.contentArray3 = self.originArray;
        }
        [self.tableView reloadData];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = TRUE;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.location == 0 && range.length == 0) {
        //search text
    }
    return TRUE;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (stylenum == 2) {
        for (int i = 0; i < [self.originArray count]; i++) {
            if ([[[self.originArray objectAtIndex:i] objectForKey:@"nickname"] isEqualToString:searchBar.text]) {
                NSArray *array = [NSArray arrayWithObject:[self.originArray objectAtIndex:i]];
                self.sortedDictionary = [self sortingarray:array];
                [self.tableView reloadData];
            }
        }
    }
    if (stylenum == 3) {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < [self.originArray count]; i++) {
            if ([[[self.originArray objectAtIndex:i] objectForKey:@"leaver_nickname"] isEqualToString:searchBar.text]) {
                [array addObject:[self.originArray objectAtIndex:i]];
            }
        }
        self.contentArray3 = array;
        [self.tableView reloadData];
    }
    
    searchBar.showsCancelButton = FALSE;
    [searchBar resignFirstResponder];
    
}

//搜索框点击取消触发的操作
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = FALSE;
    [searchBar resignFirstResponder];
}

#pragma mark - callback
//访问获取推荐宠物信息接口返回的信息
- (void)getrecommendpetsCallback:(NSArray*)args {
    if ([[args objectAtIndex:0] integerValue] == PORTAL_RESULT_GET_RECOMMENDPETS_SUCCESS) {
        if ([[[args objectAtIndex:2] objectForKey:@"result"] integerValue] == 0) {
            self.contentArray1 = [[args objectAtIndex:2] objectForKey:@"list"];
            [self.tableView reloadData];
        }
    }
    else {
        //////
    }
}

//访问附近宠物接口返回的信息
- (void)getnearbypetsCallback:(NSArray*)args {
    if ([[args objectAtIndex:0] integerValue] == PORTAL_RESULT_GET_NEARBYPETS_SUCCESS) {
        if ([[[args objectAtIndex:2] objectForKey:@"result"] integerValue] == 0) {
            self.contentArray2 = [[args objectAtIndex:2] objectForKey:@"list"];
            [self.tableView reloadData];
        }
    }
    else {
        //////
    }
}

//访问获取关注宠物信息接口返回的信息
- (void)getconcernpetsCallback:(NSArray*)args {
    if ([[args objectAtIndex:0] integerValue] == PORTAL_RESULT_GET_CONCERNPETS_SUCCESS) {
        if ([[[args objectAtIndex:2] objectForKey:@"result"] integerValue] == 0) {
            NSArray *unsortedArray = [[args objectAtIndex:2] objectForKey:@"list"];
            self.originArray = unsortedArray;
            self.sortedDictionary = [self sortingarray:unsortedArray];
            [self.tableView reloadData];
        }
    }
    else {
        //////
    }
}

//访问获取留言信息接口返回的信息
- (void)getleavemsgCallback:(NSArray*)args {
    if ([[args objectAtIndex:0] integerValue] == PORTAL_RESULT_GET_LEAVEMSG_SUCCESS) {
        if ([[[args objectAtIndex:2] objectForKey:@"result"] integerValue] == 0) {
            self.contentArray3 = [[args objectAtIndex:2] objectForKey:@"list"];
            self.originArray = [[args objectAtIndex:2] objectForKey:@"list"];
            [self.tableView reloadData];
        }
    }
    else {
        //////
    }
}

#pragma mark - Action

//查看宠物的详细信息
- (void)lookfordetailclick:(id)sender {
    UIButton *button = sender;
    [self.petInfoViewController setPetId:[[[self.contentArray1 objectAtIndex:button.tag] objectForKey:@"petid"] longValue]];
    [self.petInfoViewController setType:1];
    self.petInfoViewController.title = @"详细资料";
    [self.navigationController pushViewController:self.petInfoViewController animated:YES];
}

//我的关注中点击添加按钮触发的操作
- (void)concernpetclick {
    self.concernPetViewController.title = @"搜号码";
    [self.navigationController pushViewController:self.concernPetViewController animated:YES];
}

- (void)dealloc {
    [_petInfoViewController release];
    [_concernPetViewController release];
    [_indexedArray release];
    [_sortedDictionary release];
    [_contentArray1 release];
    [_contentArray2 release];
    [_contentArray3 release];
    [_concernPetViewController release];
    [_leaveMsgViewController release];
    [super dealloc];
}
@end
