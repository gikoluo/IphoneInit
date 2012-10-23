//
//  DZNumberpadDoneHelper.m
//  dz-numberpad-done-helper
//
//  Modified by dazuiba on 12/03/01.
//  Created by paraches on 11/12/01.
//  Copyright (c) 2011年 paraches. All rights reserved.
//

#import "DZNumberpadDoneHelper.h"

@interface DZNumberpadDoneHelper(){
    UIButton *doneButton;
    UIView *btnWrapper;
}
@property(nonatomic,assign)id target;
@property(nonatomic,assign)SEL doneAction;
@end

@implementation DZNumberpadDoneHelper
@synthesize target,doneAction;

- (id)initWithTarget:(id)theTarget doneAction:(SEL)theDoneAction{
    self = [super init];
    if (self) {
        self.target = theTarget;
        self.doneAction = theDoneAction;
        btnWrapper = [[UIView alloc] init];
    }
    return self;
}

- (void) dealloc {
    [btnWrapper release];
    [super dealloc];
}


- (void)registerObservers{
	//	Notification 登録
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)unRegisterObservers{
	// Notification を全部削除
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchDoneButton:(UIButton*)sender
{
	// 標準キーボードを非表示にします。
    if([self.target respondsToSelector:@selector(doneAction)]) {
        [self.target performSelector:@selector(doneAction) withObject:sender];
    }
    else {
        if( [self.target respondsToSelector:@selector(findFirstResponderTextField)]) {
            UITextField *textField = [self.target performSelector:@selector(findFirstResponderTextField)];
            [textField resignFirstResponder];
        }
    }
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification*)note
{
    //[target keyboardVisible];
	// ボタン作成
	doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	
	// ボタンのタイトル設定
	[doneButton setTitle:@"完成" forState:UIControlStateNormal];
    
    // ボタンをスタート位置に配置
	doneButton.frame = CGRectMake(230, 4, 80.0f, 32.0f);
    
    
	// ボタンが押されたら doneButton を呼ぶ
	[doneButton addTarget:self action:@selector(touchDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    
	
	// キーボードの最終表示位置と、アニメーション時間を NSNotification の userInfo から取得
	CGRect keyboardFrame = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGFloat duration = [[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
	// ボタンもキーボードに合わせてアニメーションさせるために、最終表示位置とキーボードの高さ分だけ下のスタート位置を用意
	CGRect startFrame = CGRectMake(0, 440, 320.0f, 40.0f);
    //NSLog(@"%.2f", 480 - 40 - CGRectGetHeight(keyboardFrame));
	//CGRect fixedFrame = CGRectMake(0, 224.0f, 320.0f, 40.0f);
    
    
    CGRect fixedFrame = CGRectMake(0, 480.0 - CGRectGetHeight(keyboardFrame) - 40, 320.0f, 40.0f);
    
    //CGRectMake(-3.0f, 427.0f + CGRectGetHeight(keyboardFrame), 108.0f, 53.0f)
    
	
    [btnWrapper setFrame:startFrame];
    [btnWrapper setBackgroundColor: [UIColor colorWithRed:0.67f green:0.64f blue:0.64f alpha:0.5f]];
    [btnWrapper addSubview:doneButton];
    
		
	// ボタンを張り付けるウィンドウはアプリケーションの 2 番目のウィンドウで、index=0 のサブビューにしないと角が丸くならない
	UIWindow* window = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
	[window insertSubview:btnWrapper atIndex:0];
	
	// アニメーションスタート
	[UIView animateWithDuration:duration
					 animations:^{
						 btnWrapper.frame = fixedFrame;
					 }
	 ];
}

- (void)keyboardWillHide:(NSNotification*)note {
	// ボタンを消すアニメーションの為にキーボードの最初と最後の位置、そして時間を NSNotification の userInfo から取得
	//CGRect keyboardBeginFrame = [[note.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	CGRect keyboardEndFrame = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	//CGFloat duration = [[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
	// キーボードの移動距離（newCenter）を計算
	//CGFloat dx = keyboardEndFrame.origin.x - keyboardBeginFrame.origin.x;
	//CGFloat dy = keyboardEndFrame.origin.y - keyboardBeginFrame.origin.y;
	//CGPoint newCenter = CGPointMake(btnWrapper.center.x+dx, btnWrapper.center.y+dy);
    
    [btnWrapper setFrame:keyboardEndFrame];
    [btnWrapper removeFromSuperview];
    if([self.target respondsToSelector:@selector(keyboardVisible)]) {
        if ([self.target performSelector:@selector(keyboardVisible)]) {
            return;
        }
        [btnWrapper removeFromSuperview];
    }
	
	// キーボードの移動距離分だけボタンもアニメーションして移動後、Superview から外す
//	[UIView animateWithDuration:duration
//					 animations:^{
//                         btnWrapper.center = newCenter;
//					 }
//					 completion:^(BOOL finished){
//                         //NSLog(@"target: %@", self.target);
//                         if([self.target respondsToSelector:@selector(keyboardVisible)]) {
//                             if ([self.target performSelector:@selector(keyboardVisible)]) {
//                                 return;
//                             }
//                         }
//						 [btnWrapper removeFromSuperview];
//					 }
//	 ];
}

@end
