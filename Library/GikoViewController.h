//
//  GikoViewController.h
//  hnaHotal
//
//  Created by Luo Chunhui on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "DDXML.h"

@protocol GikoUIViewControllerDelegate

@optional 
- (void) addAutoClearDelegate:(id) t;
- (UIView*) getLoaddingView:(NSString *)title;
- (void) removeLoadding;
@end


@protocol GikoUIViewDonepadDelegate

@optional 
- (void) addAutoClearDelegate:(id) t;
- (UIView*) getLoaddingView:(NSString *)title;
- (void) removeLoadding;
@end


@interface GikoViewController : UIViewController {
    BOOL keyboardVisible;
    BOOL _isLoad;
}

@property (nonatomic, retain) NSMutableDictionary *responserData;
@property (assign, nonatomic) BOOL keyboardVisible;
@property (retain, nonatomic) UIView *loaddingView;

- (void) removeLoadding;
- (UIView*) getLoaddingView:(NSString *)title;

- (NSDictionary *) parseRequest:(ASIHTTPRequest *)request;

- (void) networkError;
- (void) showErrorMsg:(NSString *) msg;
- (void) showInfo:(NSString *) msg;

- (void) goHome;
@end
