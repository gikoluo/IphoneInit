//
//  GikoURLConnection.m
//  Giko
//
//  Created by  on 12-06-23.
//  Copyright 2012年 Luochunhui.com. All rights reserved.
//

#import "GikoURLConnection.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "NSDictionary+Additions.h"

@interface GikoURLConnection (Private)
+ (NSURL *) getURL:(NSString *) request_method;
+ (NSMutableDictionary *) getParam: (NSString *) request_method param:(NSDictionary *) param;
@end


@implementation GikoURLConnection

- (void) setNSStringAttr:(NSArray *) key val:(NSDictionary *)val {
    NSString *tmpVal;
    for (NSString *k in key ) {
        tmpVal = [val valueForKey:[k lowercaseString]];
        if( !tmpVal || [tmpVal isKindOfClass:[NSNull class]] || [tmpVal length] == 0 ) {
            continue;
        }
        if( [self respondsToSelector:NSSelectorFromString(k)] ) {
            [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@:", [k capitalizedString]]) withObject:[NSString stringWithFormat:@"%@",tmpVal]];
        }
    }
}


- (void) setDateAttr:(NSArray *) key val:(NSDictionary *)val {
    NSDateFormatter *_dateformat = [[NSDateFormatter alloc] init];
    [_dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *tmpVal;
    for (NSString *k in key) {
        tmpVal = [val valueForKey:[k lowercaseString]];
        if( !tmpVal || [tmpVal isKindOfClass:[NSNull class]] ) {
            continue;
        }
        if( [self respondsToSelector:NSSelectorFromString(k)] ) {
            [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@:", [k capitalizedString]]) withObject:[_dateformat dateFromString:tmpVal]];
        }
    }
    [_dateformat release];
    _dateformat = nil;
}

- (void) setNSIntegerAttr:(NSArray *) key val:(NSDictionary *)val {
    NSInteger tmpVal;
    id tmpV;
    for (NSString *k in key) {
        tmpV = [val valueForKey:[k lowercaseString]];
        if( !tmpV || [tmpV isKindOfClass:[NSNull class]] ) {
            continue;
        }
        tmpVal = [tmpV intValue];
        if( [self respondsToSelector:NSSelectorFromString(k)] ) {
            [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@:", [k capitalizedString]]) withObject:[NSNumber numberWithInt:tmpVal]];
        }
    }
}

#pragma Request

- (void) get:(NSURL *)url param:(id) param, ... {
    if( [param isKindOfClass:NSClassFromString(@"NSDictionary")] ) {
        [self load:url method:@"GET" param:param];
        return;
    }
    
    va_list ap;
    va_start(ap, param);
    NSDictionary *_p = [NSDictionary dictionaryWithVaParam:param arguments:ap];
    [self load:url method:@"GET" param:_p];
}



- (void) post:(NSURL *)url param:(id) param, ... {
    if( [param isKindOfClass:NSClassFromString(@"NSDictionary")] ) {
        [self load:url method:@"POST" param:param];
        return;
    }
    
    va_list ap;
    va_start(ap, param);
    NSDictionary *_p = [NSDictionary dictionaryWithVaParam:param arguments:ap];
    [self load:url method:@"POST" param:_p];
}

+ (NSString *) get:(NSString *)request param: (id) param, ... {
    NSDictionary *_p;
    if ( [param isKindOfClass:[NSDictionary class]] ) {
        _p = param;
    } else {
        va_list ap;
        va_start(ap, param);
        _p = [NSDictionary dictionaryWithVaParam:param arguments:ap];
    }
    NSString *data;
    BOOL result = [GikoURLConnection load:[GikoURLConnection getURL:request] method:@"GET" dataJSON:_p data:&data func:nil before_func:nil];
    if( !result ) return nil;
    return data;
}


+ (NSString *) post:(NSString *)request param: (id) param, ...  {
    va_list ap;
    va_start(ap, param);
    NSDictionary *_p = [NSDictionary dictionaryWithVaParam:param arguments:ap];
    NSString *data;
    if( ![GikoURLConnection load:[GikoURLConnection getURL:request] method:@"POST" dataJSON:_p data:&data func:nil before_func:nil] ) {
        return nil;
    }
    return data;
}


- (void) load:(NSURL *)url method:(NSString *)method param:(NSDictionary *) param {
    [_request setURL:url];
    [_request setResponseEncoding:NSASCIIStringEncoding];
    [_request setRequestMethod:method];
    [self setParam:param];
    NSLog(@"%@", [_request url]);
    [_request startAsynchronous];
}




#pragma Image


+ (UIImage *) imageWithRemote:(NSString *) url pic_namespace:(NSString *) pic_namespace local_filename:(NSString *) local_filename {
    
    NSURL *_url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_URL, url]];
    
    ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:_url];
    [_request startSynchronous];
    if ( [_request responseStatusCode] != 200 ) {
        //[FileLogger log:@"request fail"];
        return nil;
    }
    
    NSData *_data = [_request responseData];
    NSString *_path = [GikoURLConnection getImagePicPath];
    if( pic_namespace ) {
        _path = [_path stringByAppendingPathComponent:pic_namespace];
    }
    
    if( local_filename ) {
        _path = [_path stringByAppendingPathComponent:local_filename];
    } else {
        _path = [_path stringByAppendingPathComponent:[url md5]];
    }
    
    [_data writeToFile:_path atomically:YES];
    return [UIImage imageWithData:_data];
}

+ (UIImage *) imageWithLocal:(NSString *) url pic_namespace:(NSString *) pic_namespace local_filename:(NSString *) local_filename {
    NSString *fileName = [url md5];
    
    if( local_filename ) {
        fileName = local_filename;
    }
    
    NSString *_path = [GikoURLConnection getImagePicPath];
    
    if( pic_namespace ) {
        _path = [_path stringByAppendingPathComponent:pic_namespace];
    }
    
    _path = [_path stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if( ![fileManager fileExistsAtPath:_path] ) {
        return nil;
    }
    
    return [UIImage imageWithContentsOfFile:fileName];
}

+ (UIImage *) imageWithRemoteAndLocal:(NSString *) url pic_namespace:(NSString *) pic_namespace local_filename:(NSString *) local_filename {
    UIImage *result = [GikoURLConnection imageWithLocal:url pic_namespace:pic_namespace local_filename: local_filename];
    if( result ) return result;
    
    return [GikoURLConnection imageWithRemote:url pic_namespace:pic_namespace local_filename: local_filename];
}

+ (NSString *) getImagePicPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	NSString *currentDirectoryPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"upload"];
    
	BOOL isDir;
	if( ![fileManager fileExistsAtPath: currentDirectoryPath isDirectory:&isDir] || !isDir) {
		//如果目录不存在，则创建一个新的目录
		[fileManager createDirectoryAtPath:currentDirectoryPath withIntermediateDirectories:NO attributes:nil error:nil];
	}
    
    return currentDirectoryPath;
}

- (void) dealloc {
    [_request release];
    _request = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _request = [[ASIFormDataRequest alloc] initWithURL:nil];
        [_request setDelegate:self];
    }
    
    return self;
}

- (void) setParam:(NSDictionary *)p {
    NSString *method = [_request requestMethod];
    
    if( [method isEqualToString:@"POST"] ) {
        for (id k in p) {
            [_request addPostValue:[p valueForKey:k] forKey:k];
        }
    } else {
        NSURL *newURL = [p getURL:[_request url]];
        [_request setURL:newURL];
    }
}



+ (NSMutableDictionary *) getParam:(NSString *)request_method param:(NSDictionary *)param {
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithDictionary:param] autorelease];
    NSLog(@"%@", dict);
    return dict;
}

+ (NSURL *) getURL:(NSString *)request_method {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", API_URL, request_method]];
}

//+ (BOOL) getJson:(NSString *)request_method param:(NSDictionary *) param data:(NSDictionary **)data error:(NSError **)error opts:(NSDictionary *)opts {
//    NSString *_method = [opts objectForKey:@"method"];
//    if( !_method ) _method = @"GET";
//    NSString *_data = nil; 
//    if( [self load:[self getURL:request_method] method:_method dataJSON:param data:&_data func:[opts objectForKey:@"func"] before_func: nil] ) {
//        CJSONDeserializer *unserializer = [CJSONDeserializer deserializer];
//        NSDictionary *_dataDict = (NSDictionary *)[unserializer deserializeAsDictionary:[_data dataUsingEncoding:NSUTF8StringEncoding] error:&*error];
//        if( error ) return NO;
//        
//        if( [[_dataDict valueForKey:@"status"] intValue] == 0 ) {
//            *data = [_dataDict valueForKey:@"data"];
//        } else {
//#ifdef DEBUG
//            NSLog(@"%@", _dataDict);
//#endif
//            error = (NSError **)[NSError errorWithDomain:uTanURLConnectionErrorDomain code:-1 userInfo:_dataDict];
//            return NO;
//        }
//        return YES;
//    } else {
//        return NO;
//    }
//}


+ (BOOL) load:(NSURL *)url method:(NSString *)method dataJSON:(NSDictionary *)dataJSON data:(NSString **)data func:(http_block_t)func  before_func:(http_block_t) before_func {    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    [request setRequestMethod:method];
    
    if( [method isEqualToString:@"POST"] ) {
        [dataJSON enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [request addPostValue:obj forKey:key];
        }];
    } else {
        url = [dataJSON getURL:url];
        [request initWithURL:url];
    }
    
    [request setTimeOutSeconds:30];
    if( before_func )
        before_func(request);
    
    /*linglinggouAppDelegate *appDelegate = (linglinggouAppDelegate *)[[UIApplication sharedApplication] delegate];
     
     if( appDelegate.isLogin && !appDelegate.oauthKey ) {
     [request addRequestHeader:@"OAUTH-KEY" value:appDelegate.oauthKey];
     }*/
    
#if defined(DP_HTTP_REQUEST_STATUS) && defined (DP_DEBUG)
    [FileLogger log:@"request url: %@", url];
#endif
    
    [request startSynchronous];
    NSError *error = [request error];
    BOOL result = YES;
    if( !error && ( *data = [request responseString] ) && [request responseStatusCode] == 200 ) {
#if defined(DP_HTTP_REQUEST_STATUS) && defined (DP_DEBUG)
        [FileLogger log:@"http_request_success: %@", *data];
#endif
        if ( func ) func(request);
    } else {
#if defined (DP_HTTP_REQUEST_STATUS) && defined (DP_DEBUG)
        if( error )  {
            NSLog(@"%@ status: %d", error, [request responseStatusCode]);
        }
#endif
        result = NO;
    }
    [request release];
    return result;
}

+ (ASIHTTPRequest *) AsyncRequest:(id<ASIHTTPRequestDelegate>) delegate get:(NSString *) url param:(id) param, ... {
    NSMutableDictionary *_param = nil;
    if( param ) {
        if( [param isKindOfClass:[NSDictionary class]] ) {
            _param = [[NSMutableDictionary alloc] initWithDictionary:param];
        }  else {
            va_list ap;
            va_start(ap, param);
            _param = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithVaParam:param arguments:ap]];
        }
    }
    
    http_block_t before_func = NULL;
    if( [_param valueForKey:@"before_func"] ) {
        before_func = (http_block_t)[_param valueForKey:@"before_func"];
        [_param removeObjectForKey:@"before_func"];
    }
    BOOL isLoadding = [_param valueForKey:@"obj_loadding"] ? YES : NO;
    if( isLoadding ) {
        if( [delegate respondsToSelector:@selector(getLoaddingView:)] ) {
            UIView *v = [delegate performSelector:NSSelectorFromString(@"view")];
            [v addSubview:[delegate performSelector:@selector(getLoaddingView:) withObject:[_param valueForKey:@"obj_loadding"]]];
        }
        
        [_param removeObjectForKey:@"obj_loadding"];
    }
    
    BOOL isAutoClear = [_param valueForKey:@"obj_isautoclear"] ? YES : NO;
    
    NSURL *_mutiUrl = [NSURL URLWithString:url];
    
    NSLog(@"%@", _param);
    ASIHTTPRequest *_request = [[ASIHTTPRequest alloc] initWithURL:[_param getURL:_mutiUrl]];
    [_request setValidatesSecureCertificate:NO];
    
    if( isAutoClear && [delegate respondsToSelector:@selector(addAutoClearDelegate:)] ) {
        [delegate performSelector:@selector(addAutoClearDelegate:) withObject:_request];
    }
    
    [_request setFailedBlock:^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        APP_DELEGATE *appDelegate = (APP_DELEGATE *)[[UIApplication sharedApplication] delegate];

        [appDelegate connectdFail: delegate];
        NSLog(@"responsor:%d", [_request responseStatusCode]);
        if( isLoadding ) {
            if( [delegate respondsToSelector:@selector(removeLoadding)] ) {
                [delegate performSelector:@selector(removeLoadding)];
            }
        }
        [delegate release];
        [pool release];
    }];
    
    [_request setCompletionBlock:^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        APP_DELEGATE *appDelegate = (APP_DELEGATE *)[[UIApplication sharedApplication] delegate];
        
        if( [_request.responseHeaders valueForKey:@"Login-Status"] ) {
            [appDelegate performSelectorOnMainThread:@selector(setMainNoLoginTabBar) withObject:nil waitUntilDone:NO];
        }
        if( isLoadding ) {
            if( [delegate respondsToSelector:@selector(removeLoadding)] ) {
                [delegate performSelector:@selector(removeLoadding)];
            }
        }
        [delegate release];
        [pool release];
    }];
    //APP_DELETAGE *appDelegate = (APP_DELETAGE *)[[UIApplication sharedApplication] delegate];

    //[_request addRequestHeader:@"DEVICE-MAC" value: appDelegate.macAddress];
    //[_request addRequestHeader:@"YR-CODE" value:YR_CODE];
    //[_request addRequestHeader:@"YR-CODE-VERSION" value:YR_CODE_VERSION];
    //[_request addRequestHeader:@"device-id" value:[[UIDevice currentDevice] uniqueIdentifier]];
    
    //if( [appDelegate.utanToken length] >= 1 ) {
    //    [_request addRequestHeader:@"YR-TOKEN" value:appDelegate.utanToken];
    //}
    
    [_request setRequestMethod:@"GET"];
    [_request autorelease];
    [_request setTimeOutSeconds:30]; //超时 30秒
    [_request setDelegate:delegate];
    
#ifdef DEBUG
    NSLog(@"delegate: %@ GET: %@", delegate, [_request url]);
#endif
    
    if( before_func ) {
        before_func(_request);
    }
    [_request startAsynchronous];
    [_param release];
    return _request;
}

- (NSString*)encodeURL:(NSString *)string
{
	NSString *newString = [NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))) autorelease];
	if (newString) {
		return newString;
	}
	return @"";
}

+ (ASIHTTPRequest *) AsyncRequest:(id<ASIHTTPRequestDelegate>) delegate post:(NSString *) url param:(id) param, ... {
    NSMutableDictionary *_param = nil;
    http_block_t before_func = nil;
    if( [param isKindOfClass:[NSDictionary class]] ) {
        _param = [[NSMutableDictionary alloc] initWithDictionary:param];
    }  else {
        va_list ap;
        va_start(ap, param);
        _param = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithVaParam:param arguments:ap]];
    }
    
    if( [delegate isKindOfClass:[ UIViewController class]] ) {
        UIView *t = [((UIViewController *)delegate) findFirstResponderUnder: ((UIViewController *)delegate).view];
        if( t != nil ) {
            [t resignFirstResponder];
        }
    }
    NSString  *osType = [NSString stringWithFormat:@"iOS%@",[[UIDevice currentDevice]systemVersion]];
    
    DDXMLElement *nsRoot = [[DDXMLElement alloc] initWithName:@"JFPay"];
    [nsRoot addAttribute:[DDXMLNode attributeWithName:@"application" stringValue:[NSString stringWithFormat:@"%@.Req", [_param objectForKey:@"application"] ] ]];
    [_param removeObjectForKey:@"application"];
        
    [nsRoot addAttribute:[DDXMLNode attributeWithName:@"version" stringValue: CLIENTVERSION]];
    [nsRoot addAttribute:[DDXMLNode attributeWithName:@"osType" stringValue:osType]];
    [nsRoot addAttribute:[DDXMLNode attributeWithName:@"userIP" stringValue:@"192.168.0.1"]];
    [nsRoot addAttribute:[DDXMLNode attributeWithName:@"mobileSerialNum" stringValue:[USER_DEFAULT objectForKey:MAC_ADDRESS]]];
    
//    if( [[_param objectForKey:@"application"] rangeOfString:@"Mall"].location == 0 ) {
//        NSUInteger i=0;
//        
//        NSMutableDictionary *tmpParams = [NSMutableDictionary dictionaryWithDictionary:_param];
//        [tmpParams setObject:@"" forKey:@""];
//        
//        NSUInteger count = [[self postData] count]-1;
//        for (NSDictionary *val in tmpParams) {
//            NSString *data = [NSString stringWithFormat:@"%@=%@%@", [self encodeURL:[val objectForKey:@"key"]], [self encodeURL:[val objectForKey:@"value"]],(i<count ?  @"&" : @"")];
//        }
//
//        
//        
//    }
    
    
    NSString *phone, *token;
    [nsRoot addAttribute:[DDXMLNode attributeWithName:@"token" stringValue:@"0001"]];
    
    if([_param objectForKey:@"token"]) {
        token = [_param objectForKey:@"token"];
        phone = [_param objectForKey:@"phone"];
        [_param removeObjectForKey:@"token"];
        [_param removeObjectForKey:@"phone"];
    }
    else {
        phone = @"0000";
        token = @"0000";
    }
    
    [nsRoot addAttribute:[DDXMLNode attributeWithName:@"phone" stringValue:phone]];
    [nsRoot addAttribute:[DDXMLNode attributeWithName:@"token" stringValue:token]];
    DDXMLElement *paramElement;
    
    
//    交易日期		n8	M	R	YYYYMMDD
//    交易时间	transTime	n6	M	R	hhmmss
//    流水号	transLogNo	n6	M	R	
    NSDateFormatter* dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    
    [_param setObject:[dateFormatter stringFromDate: [NSDate date]] forKey:@"transDate"];
     
    [dateFormatter setDateFormat:@"HHmmss"];
    [_param setObject:[dateFormatter stringFromDate: [NSDate date]] forKey:@"transTime"];
    
    NSString *transLogNo;
    transLogNo = [_param objectForKey:@"transLogNo"];
    if( transLogNo == nil ) {
        transLogNo = (NSString *) [USER_DEFAULT objectForKey:@"transLogNo"];
        if(transLogNo == @"") {
            transLogNo = @"0";
        }
        transLogNo = [NSString stringWithFormat:@"%d", [transLogNo intValue] + 1];
        [USER_DEFAULT setObject:transLogNo forKey:@"transLogNo"];
        transLogNo = [NSString stringWithFormat:@"%06d", [transLogNo intValue]];
    }
    
    [_param setObject:transLogNo forKey:@"transLogNo"];

    
    BOOL isLoadding = [_param valueForKey:OBJ_LOADING] ? YES : NO;
    if( isLoadding ) {
        if( [delegate respondsToSelector:@selector(getLoaddingView:)] ) {
            UIView *v = [delegate performSelector:NSSelectorFromString(@"view")];
            [v addSubview:[delegate performSelector:@selector(getLoaddingView:) withObject:[_param valueForKey:OBJ_LOADING]]];
        }
        [_param removeObjectForKey:OBJ_LOADING];
    }
    
    for (NSString* key in _param) {
        paramElement = [[DDXMLElement alloc] initWithName:key];
        [paramElement setStringValue:[_param objectForKey:key]];
        [nsRoot addChild:paramElement];
        [paramElement release];
    }
    
    
    
    NSURL *_mutiUrl = [NSURL URLWithString:url];
    BOOL isAutoClear = [_param valueForKey:@"obj_isautoclear"] ? YES : NO;
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:_mutiUrl];
    [_request setValidatesSecureCertificate:NO];
    
    if( isAutoClear && [delegate respondsToSelector:@selector(addAutoClearDelegate:)] ) {
        [delegate performSelector:@selector(addAutoClearDelegate:) withObject:_request];
    }
    
    [_request addPostValue:[nsRoot XMLString] forKey:@"requestXml"];
    
    NSLog(@"%@", [nsRoot XMLString]);
    
    [_request setCompletionBlock:^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        APP_DELEGATE *appDelegate = (APP_DELEGATE *)[[UIApplication sharedApplication] delegate];
        
        NSLog(@"%@", _request.responseString);
        
        NSRange range1 = [_request.responseString rangeOfString: @"UnifiedAction.Rsp"];
        NSRange range2 = [_request.responseString rangeOfString: @"<respCode>0001</respCode>"];
        NSRange range3 = [_request.responseString rangeOfString: @"<respCode>0002</respCode>"];
        if( range1.location != NSNotFound && ( range2.location != NSNotFound || range3.location != NSNotFound) ) {
            [appDelegate performSelectorOnMainThread:@selector(showLoginPanel:) withObject:delegate waitUntilDone:NO];
        }
        if( isLoadding ) {
            if( [delegate respondsToSelector:@selector(removeLoadding)] ) {
                [delegate performSelector:@selector(removeLoadding)];
            }
        }
        [delegate release];
        [pool release];
    }];

    [_request setFailedBlock:^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        APP_DELEGATE *appDelegate = (APP_DELEGATE *)[[UIApplication sharedApplication] delegate];
        
        NSLog(@"%@", _request.responseString);
        [appDelegate connectdFail: delegate];
        
        if( isLoadding ) {
            if( [delegate respondsToSelector:@selector(removeLoadding)] ) {
                [delegate performSelector:@selector(removeLoadding)];
            }
        }
        [delegate release];
        [pool release];
    }];
    
    
    [_request setRequestMethod:@"POST"];
    [_request autorelease];
    [_request setTimeOutSeconds:60]; //超时 30秒
    [_request setDelegate:delegate];
    
    if( before_func ) {
        before_func(_request);
    }
//#ifdef DEBUG
    NSLog(@"delegate: %@ POST: %@, data: %@", delegate, _request.url, [_request postBody]);
//#endif
    [_request startAsynchronous];
    return _request;
}


//+ (BOOL) getText:(NSString *)request_method param:(NSDictionary *)param data:(NSString **)data {
//    return YES;
//}

+ (id) decodeDictionary:(NSDictionary *)_param {
    NSString *requestMethod = [_param valueForKey:@"undefined"];
    
    if( [requestMethod isEmptyOrWhitespace] ) {
        return nil;
    }
    
    NSRange range = [requestMethod rangeOfString:@"."];
    
    if( range.length == 0 ) return nil;
    NSString *className = nil;
    NSString *methodName = nil;
    @try {
        className = [requestMethod substringWithRange:NSMakeRange(0, range.location)];
        methodName = [requestMethod substringWithRange:NSMakeRange(range.location+1, [requestMethod length] - (range.location+1))];
    }
    @catch (NSException *exception) {
        className = nil;
        methodName = nil;
        return nil;
    }
    @finally {
        
    }

    id class = NSClassFromString([NSString stringWithFormat:@"Giko%@", className]);
    
    if( !class ) return nil;
    
    if( ![class respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"%@Action:", methodName])] ) {
        return nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:requestMethod object:nil userInfo:[_param valueForKey:@"data"]];
    return [class performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@Action:", methodName]) withObject:[_param valueForKey:@"data"]];
}
@end
