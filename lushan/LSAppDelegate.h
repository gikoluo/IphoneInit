//
//  LSAppDelegate.h
//  lushan
//
//  Created by Chunhui Luo on 10/23/12.
//  Copyright (c) 2012 Chunhui Luo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSAppDelegate : UIResponder <UIApplicationDelegate, GikoURLConncetionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain,nonatomic) UINavigationController *navigationController;

@end


#define APP_DELEGATE LSAppDelegate