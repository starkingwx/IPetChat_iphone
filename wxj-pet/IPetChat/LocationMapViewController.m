//
//  LocationMapViewController.m
//  IPetChat
//
//  Created by king star on 14-1-19.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import "LocationMapViewController.h"
#import "UserBean+Device.h"
#import "CustomAnnotationView.h"

@interface LocationMapViewController () {
    MAPointAnnotation *_petLoc;
}
- (void)refreshLocation;
- (void)centerPetLocation;
@end

@implementation LocationMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"当前位置";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStyleDone target:self action:@selector(refreshLocation)];
        
        UserBean *user = [[UserManager shareUserManager] userBean];
        PetInfo *petInfo = user.petInfo;
        
        _petLoc = [[MAPointAnnotation alloc] init];
        _petLoc.coordinate = CLLocationCoordinate2DMake(32.0586, 118.7490);
        if (petInfo && petInfo.nickname) {
            _petLoc.title = petInfo.nickname;
        }
    }
    return self;
}

- (void)refreshLocation {
    NSLog(@"refresh location");
    CLLocationCoordinate2D old = _petLoc.coordinate;
    CLLocationCoordinate2D newCoor = CLLocationCoordinate2DMake(old.latitude, old.longitude + 0.0001);
    _petLoc.coordinate = newCoor;
    [self centerPetLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.mapView.showsUserLocation = NO;
//    [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    
    [self.mapView setZoomEnabled:YES];
    [self.mapView setZoomLevel:16 animated:NO];
    [self centerPetLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *customReuseIndetifier = @"CustomReuseIndetifier";
        CustomAnnotationView *annotationView = (CustomAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
            // must set to NO, so we can show the custom callout view.
            annotationView.canShowCallout = NO;
            annotationView.draggable = YES;
            annotationView.calloutOffset = CGPointMake(0, -5);
        }
        
        annotationView.portrait = [UIImage imageNamed:@"ic_dog_annotation"];
        annotationView.name     = annotation.title;
        return annotationView;
    }
    
    return nil;
}

- (void)centerPetLocation {
    [self.mapView removeAnnotation:_petLoc];
    [self.mapView addAnnotation:_petLoc];
    
    [self.mapView setCenterCoordinate:_petLoc.coordinate animated:NO];
}
@end
