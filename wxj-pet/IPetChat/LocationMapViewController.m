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
#import "UrlConfig.h"
#import "DeviceManager.h"
#import "Constant.h"

static int TOTAL = 3; // total count for retry order
static int TOTAL_REPEAT = 60 / 5; // total repeat count for query location
static long long COORDINATE_TRANSFORM_RATE = 1000000;

@interface LocationMapViewController () {
    MAPointAnnotation *_petLoc;
    int _retryCount;
    NSTimer *_timer;
    int _repeatCount;
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
            _petLoc.subtitle = [NSString stringWithFormat:@"%@/%@", IMAGE_GET_ADDR, petInfo.avatar];
        }
    }
    return self;
}

- (void)refreshLocation {
    NSLog(@"refresh location");
//    CLLocationCoordinate2D old = _petLoc.coordinate;
//    CLLocationCoordinate2D newCoor = CLLocationCoordinate2DMake(old.latitude, old.longitude + 0.0001);
//    _petLoc.coordinate = newCoor;
//    [self centerPetLocation];
    
    _retryCount = 0;
    [self orderDeviceServer];
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
//    [self centerPetLocation];
    
    [self startQueryLocationTimer];
    [self refreshLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stopQueryLocationTimer];
    [super viewDidDisappear:animated];
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
        annotationView.avatarUrl = [annotation subtitle];
        return annotationView;
    }
    
    return nil;
}

- (void)centerPetLocation {
    NSLog(@"locate: latitude: %f, longitude: %f", _petLoc.coordinate.latitude, _petLoc.coordinate.longitude);
    
    [self.mapView removeAnnotation:_petLoc];
    [self.mapView addAnnotation:_petLoc];
    
    [self.mapView setCenterCoordinate:_petLoc.coordinate animated:NO];
}

- (void)orderDeviceServer {
    [[DeviceManager shareDeviceManager] orderDeviceServerWithProcessor:self andFinishedRespSelector:@selector(onFinishedOrderDeviceServer:) andFailedRespSelector:@selector(onOrderFailed:)];
}


- (void)onFinishedOrderDeviceServer:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedOrderDeviceServer - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
            
        case 200: {
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            NSLog(@"response data: %@", jsonData);
            if (jsonData) {
                NSString *status = [jsonData objectForKey:STATUS];
                if ([SUCCESS isEqualToString:status]) {
                    // order success query location
                    [self startQueryLocationTimer];
                }
                
            } else {
            }
            
            break;
        }
        default: {
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            NSLog(@"response data: %@", jsonData);
            if (jsonData) {
                NSString *status = [jsonData objectForKey:STATUS];
                NSString *cmdType = [jsonData objectForKey:CMD_TYPE];
                if ([FAILED isEqualToString:status] && [ERROR_MESSAGE isEqualToString:cmdType]) {
                    // order failed
                    NSDictionary *errorMsg = [jsonData objectForKey:@"error_message"];
                    if (errorMsg) {
                        NSString *desc = [errorMsg objectForKey:@"description"];
                        NSString *errtype = [errorMsg objectForKey:@"errtype"];
                        if ([@"terminal is offline" isEqualToString:desc]) {
                            [[iToast makeText:@"设备不在线"] show];
                        } else if ([@"TIMEOUT" isEqualToString: errtype]) {
                            _retryCount++;
                            if (_retryCount < TOTAL) {
                                [self orderDeviceServer];
                            } else {
                                [[iToast makeText:@"服务器连接失败！"]show];
                            }
                        }
                      
                    }
                }
                
            }
        }
            break;
    
    }
    
}

- (void)onOrderFailed:(ASIHTTPRequest *)pRequest {
    NSLog(@"onOrderFailed - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
    NSLog(@"response data: %@", jsonData);
    _retryCount++;
    if (_retryCount < TOTAL) {
        [self orderDeviceServer];
    } else {
        [[iToast makeText:@"服务器连接失败！"]show];
    }
}

- (void)queryLatestPetDeviceInfo {
    NSLog(@"queryLatestPetDeviceInfo - repeat count: %d", _repeatCount);
    [[DeviceManager shareDeviceManager] queryLastestInfoWithProcessor:self andFinishedRespSelector:@selector(onQueryFinished:) andFailedRespSelector:nil];
}

- (void)onQueryFinished:(ASIHTTPRequest *)pRequest {
    NSLog(@"onQueryFinished - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
            
        case 200: {
            // create group and invite ok
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            NSLog(@"response data: %@", jsonData);
            if (jsonData) {
                NSString *status = [jsonData objectForKey:STATUS];
                if ([SUCCESS isEqualToString:status]) {
                    NSDictionary *archOp = [jsonData objectForKey:ArchOperation];
                    NSArray *trackSdata = [archOp objectForKey:TRACK_SDATE];
                    if (trackSdata && [trackSdata count] > 0) {
                        NSDictionary *data = [trackSdata objectAtIndex:0];
                        // locate in the map
                        NSNumber *x = [data objectForKey:X];
                        NSNumber *y = [data objectForKey:Y];
                        double latitude = [y longLongValue] * 1.0f / COORDINATE_TRANSFORM_RATE;
                        double longitude = [x longLongValue] * 1.0f / COORDINATE_TRANSFORM_RATE;
                        
                        _petLoc.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                        [self centerPetLocation];
                    }
                }
            } else {
            }
            
            break;
        }
        default:
            break;
    }
    
}

- (void)queryLocation {
 
    if (_repeatCount < TOTAL_REPEAT) {
        [self queryLatestPetDeviceInfo];
        _repeatCount++;
    } else {
        [self stopQueryLocationTimer];
    }
  
}

- (void)startQueryLocationTimer {
    [self stopQueryLocationTimer];
    
    _repeatCount = 0;
    [self queryLocation];
    _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(queryLocation) userInfo:nil repeats:YES];
}

- (void)stopQueryLocationTimer {
    NSLog(@"stopQueryLocationTimer");
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

@end
