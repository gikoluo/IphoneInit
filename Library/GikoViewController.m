//
//  GikoViewController.m
//  hnaHotal
//
//  Created by Luo Chunhui on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GikoViewController.h"
#import "SCNavigationBar.h"
#import "MBProgressHUD.h"
#import "DDXML.h"

@interface GikoViewController ()

@end

@implementation GikoViewController

@synthesize keyboardVisible;
@synthesize loaddingView;
@synthesize responserData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        responserData = [[NSMutableDictionary alloc] init];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setLoaddingView:nil];
    [self setResponserData:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    //[self customizedNavigationController];
    [super viewDidAppear:animated];
}



- (void) dealloc {
    if( self.loaddingView ) {
        [loaddingView release];
        loaddingView = nil;
    }
    [responserData release];
    [super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//- (UINavigationController *)customizedNavigationController
//{
//    UINavigationController *navController = [[UINavigationController alloc] initWithNibName:nil bundle:nil];
//    
//    // Ensure the UINavigationBar is created so that it can be archived. If we do not access the
//    // navigation bar then it will not be allocated, and thus, it will not be archived by the
//    // NSKeyedArchvier.
//    [navController navigationBar];
//    
//    // Archive the navigation controller.
//    NSMutableData *data = [NSMutableData data];
//    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//    [archiver encodeObject:navController forKey:@"root"];
//    [archiver finishEncoding];
//    [archiver release];
//    [navController release];
//    
//    // Unarchive the navigation controller and ensure that our UINavigationBar subclass is used.
//    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//    [unarchiver setClass:[SCNavigationBar class] forClassName:@"UINavigationBar"];
//    UINavigationController *customizedNavController = [unarchiver decodeObjectForKey:@"root"];
//    [unarchiver finishDecoding];
//    [unarchiver release];
//    
//    // Modify the navigation bar to have a background image.
//    SCNavigationBar *navBar = (SCNavigationBar *)[customizedNavController navigationBar];
//    [navBar setTintColor:[UIColor colorWithRed:0.39 green:0.72 blue:0.62 alpha:1.0]];
//    [navBar setBackgroundImage:[UIImage imageNamed:@"navigation-bar-bg.png"] forBarMetrics:UIBarMetricsDefault];
//    [navBar setBackgroundImage:[UIImage imageNamed:@"navigation-bar-bg-landscape.png"] forBarMetrics:UIBarMetricsLandscapePhone];
//    
//    return customizedNavController;
//}

#pragma Loading
//show the loading
- (UIView*) getLoaddingView:(NSString *)title {
    
    if( !self.loaddingView ) {
        MBProgressHUD *_hud = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
        [_hud setLabelText:title];
        [_hud show:YES];
        self.loaddingView = _hud;
    }
    
    return self.loaddingView;
}

//remove loading
- (void) removeLoadding {
    if( self.loaddingView ) {
        [((MBProgressHUD*)self.loaddingView) hide:YES];
        [self.loaddingView removeFromSuperview];
        self.loaddingView = nil;
    }
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    UITextField *textField = [self performSelector:@selector(findFirstResponderTextField)];
    [textField resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void) showInfo:(NSString *)msg 
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:msg];
    hud.mode = MBProgressHUDModeCustomView;
    hud.userInteractionEnabled = NO;
    [hud hide:YES afterDelay:2];
}

- (void) showErrorMsg:(NSString *)msg 
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:msg];
    hud.mode = MBProgressHUDModeCustomView;
    hud.userInteractionEnabled = NO;
    [hud hide:YES afterDelay:2];
}

- (void) networkError {
    APP_DELEGATE *appDelegate = (APP_DELEGATE *)[[UIApplication sharedApplication] delegate];
    [appDelegate connectdFail: self];
}

- (NSDictionary *) parseRequest:(ASIHTTPRequest *)request {
    if( [request responseStatusCode] != 200 ) {
        [self networkError];
        return false;
    }
   
    NSMutableDictionary *respData = [NSMutableDictionary dictionary];
    NSData *data = request.responseData;    
    NSError* error = nil;
    
    DDXMLDocument *xmlDoc;
    xmlDoc = [[[DDXMLDocument alloc] initWithData:data options:0 error:&error] autorelease];
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        [self networkError];
        return nil;  
    }
    
    for(id attribute in xmlDoc.rootElement.attributes) {
        [respData setObject:[attribute stringValue] forKey:[attribute name]];
    }
    
    NSString *applicationStr = [respData objectForKey:@"application"];
    [respData setObject:[applicationStr stringByReplacingOccurrencesOfString:@".Rsp"
                                                        withString:@""] forKey:@"application"];
    
    
    NSArray* resultNodes = nil;
    resultNodes = [xmlDoc nodesForXPath:@"/JFPay/*" error:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);  
        return nil;  
    }
    for(DDXMLElement* resultElement in resultNodes)  
    {
        [respData setObject:[resultElement stringValue] forKey:[resultElement name]];
    }
    
    return respData;
}

- (void) showLogin {
    
}

- (void) goHome {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
