//
//  LeaveMsgViewController.m
//  IPetChat
//
//  Created by orangeskiller on 13-11-27.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "LeaveMsgViewController.h"
#import "Enhttpmanager.h"
#import "UIBubbleTableView.h"
#import "NSBubbleData.h"

#define IMGPATH @"http://www.segopet.com/segoimg/"
#define DEVICE_HEIGHT_DIFF [UIScreen mainScreen].bounds.size.height-480

@interface LeaveMsgViewController ()

@end

@implementation LeaveMsgViewController
@synthesize type = _type;
@synthesize bubbleTable = _bubbleTable;
@synthesize bubbleData = _bubbleData;
@synthesize msgID = _msgID;
@synthesize backimg1 = _backimg1;
@synthesize backimg2 = _backimg2;
@synthesize sendbutton = _sendbutton;
@synthesize inputandsendView = _inputandsendView;
@synthesize textfield = _textfield;
@synthesize petID = _petID;

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
    
    self.backimg1.image = [[UIImage imageNamed:@"input-bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(19.0f, 3.0f, 19.0f, 3.0f)];
    self.backimg2.image = [[UIImage imageNamed:@"input-field"] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 12.0f, 18.0f, 18.0f)];
    [self.sendbutton setBackgroundImage:[[UIImage imageNamed:@"send"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f)] forState:UIControlStateNormal];
    [self.sendbutton setBackgroundImage:[[UIImage imageNamed:@"send-highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f)] forState:UIControlStateHighlighted];
    
    self.bubbleTable.bubbleDataSource = self;
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //reply msg
    if (self.type == 0) {
        Enhttpmanager *httpmanager = [[Enhttpmanager alloc] init];
        [httpmanager getleavemsgdetail:self selector:@selector(getleavemsgdetailCallback:) msgid:self.msgID];
        [httpmanager release];
    }
    //leave msg
    else {
        [self.bubbleData removeAllObjects];
        [self.bubbleTable reloadData];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound)
    {
        [self.textfield resignFirstResponder];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//访问获取留言详情接口返回的信息
- (void)getleavemsgdetailCallback:(NSArray*)args {
    if ([[args objectAtIndex:0] integerValue] == PORTAL_RESULT_GET_LEAVEMSG_DETAIL_SUCCESS) {
        if ([[[args objectAtIndex:2] objectForKey:@"result"] integerValue] == 0) {
            NSArray *array = [[args objectAtIndex:2] objectForKey:@"list"];
            NSMutableArray *bubblearray = [NSMutableArray array];
            for (int i = 0; i < [array count]; i++) {
                NSDictionary *dic = [array objectAtIndex:i];
                [bubblearray addObject:[NSBubbleData dataWithText:[dic objectForKey:@"content"] andDate:[NSDate dateWithTimeIntervalSince1970:[[dic objectForKey:@"leave_timestamp"] integerValue]] andType:([[dic objectForKey:@"author"] isEqualToString:@"18652970720"])?BubbleTypeMine:BubbleTypeSomeoneElse andAvatar:[IMGPATH stringByAppendingString:[dic objectForKey:@"leaver_avatar"]]]];
                
            }
            self.bubbleData = bubblearray;
            [self.bubbleTable reloadData];
        }
    }
    else {
        //////
    }
}

//访问回复留言接口返回的信息
- (void)replymsgCallback:(NSArray*)args {
    if ([[args objectAtIndex:0] integerValue] == PORTAL_RESULT_REPLY_MSG_SUCCESS) {
        if ([[[args objectAtIndex:2] objectForKey:@"result"] integerValue] == 0) {
            [self.bubbleData addObject:[NSBubbleData dataWithText:self.textfield.text andDate:[NSDate dateWithTimeIntervalSinceNow:0] andType:BubbleTypeMine andAvatar:[IMGPATH stringByAppendingString:@"c2cea737-da41-4694-8a0d-7b1416fa5467"]]];
            [self.bubbleTable reloadData];
        }
        else {
            NSString *text = @"";
            switch ([[[args objectAtIndex:2] objectForKey:@"result"] integerValue]) {
                case 1:
                    text = @"留言不存在";
                    break;
                case 2:
                    text = @"msgid为空";
                    break;
                case 3:
                    text = @"回复失败";
                    break;
                default:
                    break;
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:text delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
        }
        self.textfield.text = @"";
        [self.textfield resignFirstResponder];
    }
}

//访问留言接口返回的信息
- (void)leavemsgCallback:(NSArray*)args {
    if ([[args objectAtIndex:0] integerValue] == PORTAL_RESULT_LEAVE_MSG_SUCCESS) {
        if ([[[args objectAtIndex:2] objectForKey:@"result"] integerValue] == 0) {
            if (!self.bubbleData) {
                NSMutableArray *bubblearray = [NSMutableArray array];
                [bubblearray addObject:[NSBubbleData dataWithText:self.textfield.text andDate:[NSDate dateWithTimeIntervalSinceNow:0] andType:BubbleTypeMine andAvatar:[IMGPATH stringByAppendingString:@"c2cea737-da41-4694-8a0d-7b1416fa5467"]]];
                self.bubbleData = bubblearray;
                [self.bubbleTable reloadData];
            }
            else {
                [self.bubbleData addObject:[NSBubbleData dataWithText:self.textfield.text andDate:[NSDate dateWithTimeIntervalSinceNow:0] andType:BubbleTypeMine andAvatar:[IMGPATH stringByAppendingString:@"c2cea737-da41-4694-8a0d-7b1416fa5467"]]];
                [self.bubbleTable reloadData];
            }
        }
        else {
            NSString *text = @"";
            switch ([[[args objectAtIndex:2] objectForKey:@"result"] integerValue]) {
                case 1:
                    text = @"宠物不存在";
                    break;
                case 2:
                    text = @"petid为空";
                    break;
                case 3:
                    text = @"留言失败";
                    break;
                default:
                    break;
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:text delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
        }
        self.textfield.text = @"";
        [self.textfield resignFirstResponder];
    }
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [self.bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [self.bubbleData objectAtIndex:row];
}

#pragma mark Responding to keyboard events

- (void)keyboardWillChange:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    CGRect mframe = self.inputandsendView.frame;
    mframe.origin.y = DEVICE_HEIGHT_DIFF+keyboardRect.origin.y-104;
    self.inputandsendView.frame =mframe;
    
    if ([UIScreen mainScreen].bounds.size.height == keyboardRect.origin.y) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f);
        self.bubbleTable.scrollIndicatorInsets = insets;
        self.bubbleTable.contentInset = insets;
        if (self.bubbleTable.contentSize.height > self.bubbleTable.frame.size.height) {
            [self.bubbleTable setContentOffset:CGPointMake(0, self.bubbleTable.contentSize.height-self.bubbleTable.frame.size.height) animated:YES];
        }
        else {
            self.bubbleTable.scrollsToTop = TRUE;
        }
    }
    else {
        if (self.bubbleTable.contentSize.height > self.bubbleTable.frame.size.height-keyboardRect.size.height) {
            UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,0.0f,keyboardRect.size.height,0.0f);
            self.bubbleTable.scrollIndicatorInsets = insets;
            self.bubbleTable.contentInset = insets;
            [self.bubbleTable setContentOffset:CGPointMake(0, self.bubbleTable.contentSize.height-self.bubbleTable.frame.size.height+keyboardRect.size.height) animated:YES];
        }
    }
    
    [UIView commitAnimations];
}

- (void)dealloc {
    [_bubbleTable release];
    [_backimg1 release];
    [_backimg2 release];
    [_sendbutton release];
    [_inputandsendView release];
    [_textfield release];
    [super dealloc];
}

//点击发送留言按钮触发的操作
- (IBAction)sendtext:(id)sender {
    Enhttpmanager *httpmanager = [[Enhttpmanager alloc] init];
    // reply msg
    if (self.type == 0) {
        [httpmanager replymsg:self selector:@selector(replymsgCallback:) username:@"18652970720" content:self.textfield.text msgid:self.msgID];
    }
    // leave msg
    else {
        [httpmanager leavemsg:self selector:@selector(leavemsgCallback:) username:@"18652970720" petid:self.petID content:self.textfield.text];
    }
    [httpmanager release];
}
@end
