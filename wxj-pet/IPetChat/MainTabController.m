//
//  MainTabController.m
//  IPetChat
//
//  Created by king star on 13-12-15.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "MainTabController.h"
#import "CommunityViewController.h"
#import "SettingViewController.h"
#import "CommonToolkit/CommonToolkit.h"

@interface MainTabController ()

@end

@implementation MainTabController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //    CommunityViewController *ctrl3 = [[[CommunityViewController alloc] initWithNibName:@"CommunityViewController" bundle:nil] autorelease];
        //    UINavigationController *nav3 = [[[UINavigationController alloc] initWithRootViewController:ctrl3] autorelease];
        //    nav3.navigationBar.tintColor = [UIColor colorWithRed:(77/255.0) green:(78/255.0) blue:(78/255.0) alpha:1];
        //    SettingViewController *ctrl4 = [[[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil] autorelease];
        //    UINavigationController *nav4 = [[[UINavigationController alloc] initWithRootViewController:ctrl4] autorelease];
        //    nav4.navigationBar.tintColor = [UIColor colorWithRed:(77/255.0) green:(78/255.0) blue:(78/255.0) alpha:1];
        
        //    UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
        //    tabBarController.viewControllers = [NSArray arrayWithObjects:nav3, nav4, nil];
        UIViewController *tab3 = [[UINavigationController alloc] initWithRootViewController:[[CommunityViewController alloc] initWithNibName:@"CommunityViewController" bundle:nil] andBarStyle:UIBarStyleBlack];
    
        UIViewController *tab4 = [[UINavigationController alloc] initWithRootViewController:[[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil] andBarStyle:UIBarStyleBlack];
        
        self.viewControllers = [NSArray arrayWithObjects:tab3, tab4, nil];
        self.selectedViewController = tab3;
  
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
