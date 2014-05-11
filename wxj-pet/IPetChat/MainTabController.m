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
#import "TestApiViewController.h"
#import "MainPageViewController.h"
#import "PetMotionStatViewController.h"

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
        UIViewController *tab0 = [[TestApiViewController alloc] initWithNibName:@"TestApiViewController" bundle:nil];
        
        UIViewController *tab1 = [[MainPageViewController alloc] initWithNibName:@"MainPageViewController" bundle:nil];
        
        UIViewController *tab2 = [[PetMotionStatViewController alloc] initWithNibName:@"PetMotionStatViewController" bundle:nil];
        
        UIViewController *tab3 = [[CommunityViewController alloc] initWithNibName:@"CommunityViewController" bundle:nil];
        UIViewController *tab4 = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
        
        
        self.viewControllers = [NSArray arrayWithObjects: tab1, tab2, tab3, tab4, nil];
        self.selectedViewController = tab1;
                
//        self.delegate = self;
  
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
//
//- (BOOL)mh_tabBarController:(MHTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
//{
//	NSLog(@"mh_tabBarController %@ shouldSelectViewController %@ at index %u", tabBarController, viewController, index);
//    
//	// Uncomment this to prevent "Tab 3" from being selected.
//	//return (index != 2);
//    
//	return YES;
//}
//
//- (void)mh_tabBarController:(MHTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
//{
//	NSLog(@"mh_tabBarController %@ didSelectViewController %@ at index %u", tabBarController, viewController, index);
//}



@end
