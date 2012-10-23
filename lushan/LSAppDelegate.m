//
//  LSAppDelegate.m
//  lushan
//
//  Created by Chunhui Luo on 10/23/12.
//  Copyright (c) 2012 Chunhui Luo. All rights reserved.
//

#import "LSAppDelegate.h"
#import "LSHomeViewController.h"
#import "QuartzCore/QuartzCore.h"

@implementation LSAppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}



- (void) startMainWindow {
    //PRINT_CMD
    self.window.backgroundColor = [UIColor clearColor];
    UIViewController *homeController = [[LSHomeViewController alloc] init ] ;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:homeController];
    UIImage *barImage = [UIImage imageNamed:@"navigation_bar.png"];
    
    if( [nav.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        [nav.navigationBar setBackgroundImage:barImage forBarMetrics:UIBarMetricsDefault];
    } else {
        nav.navigationBar.layer.contents = (id) barImage.CGImage;
    }
    
    nav.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.navigationController = nav;
    
    [homeController release];
    [nav release];
    
    [self.window setRootViewController:self.navigationController];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    [self startMainWindow];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



#pragma mark -
#pragma GikoURLConnection connection fail
- (void) showMessage:(id) view message:(NSString *) message {
    if( !view ) {
        return;
    }
    UIView *tmpView = nil;
    if ( [view isKindOfClass:[UIView class]] ) {
        tmpView = view;
    }
    
    if( [view isKindOfClass:[UIViewController class]] ){
        tmpView = ((UIViewController*)view).view;
    }
    
    if( !tmpView ) {
        return;
    }
    
    MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:tmpView animated:YES];
    [progress setLabelText:message];
    progress.mode= MBProgressHUDModeCustomView;
    progress.layer.masksToBounds = YES;
    progress.layer.cornerRadius = 5.0f;
    [progress hide:YES afterDelay:2];
}
- (void)connectdFail:(id<ASIHTTPRequestDelegate>) delegate {
    [self showMessage:delegate message:@"网络连接失败"];
}
@end
