//
//  GikoURLConnection.h
//  linglinggou
//
//  Created by  on 11-10-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "DDXML.h"

@protocol GikoURLConncetionDelegate <NSObject>
- (void)connectdFail:(id<ASIHTTPRequestDelegate>) delegate;

@end


#define GikoURLConnectionErrorDomain @"GikoURLConnectionJsonMsgDomain"
typedef void (^http_block_t)(ASIHTTPRequest *);

#define GIKO_OBJ_LOADDING @"obj_loadding"
#define GIKO_OBJ_AUTOCLEAR @"obj_isautoclear"

@interface GikoURLConnection : NSObject<ASIHTTPRequestDelegate> {
    ASIFormDataRequest *_request;
}

- (void) setNSStringAttr:(NSArray *) key val:(NSDictionary *)val;

- (void) setDateAttr:(NSArray *) key val:(NSDictionary *)val;

- (void) setNSIntegerAttr:(NSArray *) key val:(NSDictionary *)val;

- (void) get:(NSURL *)url param:(id) param, ... NS_REQUIRES_NIL_TERMINATION;
//- (void) get:(NSURL *)url param: (NSDictionary *) param;
- (void) post:(NSURL *)url param:(id) param, ... NS_REQUIRES_NIL_TERMINATION;
//- (void) post:(NSURL *)url param:(NSDictionary *) param;
- (void) load:(NSURL *)url method:(NSString *)method param:(NSDictionary *) param;

+ (BOOL) load: (NSURL *) url method: (NSString *) method dataJSON: (NSDictionary *) dataJSON data: (NSString **)data func: (http_block_t) func before_func:(http_block_t) before_func;

+ (NSString *) post:(NSString *)request param: (id) param, ... NS_REQUIRES_NIL_TERMINATION;

+ (NSString *) get:(NSString *)request  param: (id) param, ... NS_REQUIRES_NIL_TERMINATION;

+ (ASIHTTPRequest *) AsyncRequest:(id<ASIHTTPRequestDelegate>) delegate get:(NSString *) url param:(id) param, ...;
+ (ASIHTTPRequest *) AsyncRequest:(id<ASIHTTPRequestDelegate>) delegate post:(NSString *) url param:(id) param, ...;

+ (UIImage *) imageWithRemote:(NSString *) url pic_namespace:(NSString *) pic_namespace local_filename:(NSString *) local_filename;
+ (UIImage *) imageWithLocal:(NSString *) url pic_namespace:(NSString *) pic_namespace local_filename:(NSString *) local_filename;
+ (UIImage *) imageWithRemoteAndLocal:(NSString *) url pic_namespace:(NSString *) pic_namespace local_filename:(NSString *) local_filename;

+ (id) decodeDictionary:(NSDictionary *)_param;

@end
