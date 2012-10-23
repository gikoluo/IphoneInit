//
//  NSString+HttpParams.m
//  Weibo
//
//  Created by  on 11-7-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSString+HttpParams.h"
#import "NSString+URLEncoding.h"
#import "CJSONDeserializer.h"

@implementation NSString (HTTPParams)

static NSString *_dict = nil;

- (NSDictionary *) dictionaryToJson {
    CJSONDeserializer *unserializer = [CJSONDeserializer deserializer];
    return  (NSDictionary *)[unserializer deserializeAsDictionary:[self dataUsingEncoding:NSUTF8StringEncoding] error:nil];
}

- (NSDictionary *) parse_dictionary {
    NSString *_str_params = self;
    if( !_str_params || [_str_params length] <= 0 ) return nil;
    
    NSMutableDictionary *_dict = [NSMutableDictionary dictionary];
    NSArray *_arr = [_str_params componentsSeparatedByString:@"&"];
    [_arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *_tmp = (NSString *)obj;
        NSArray *_par = [_tmp componentsSeparatedByString:@"="];
        if( !_par || [_par count] != 2 ) return;
        [_dict setObject:[[_par objectAtIndex:1] URLDecodedString] forKey:[_par objectAtIndex:0]];
    }];
    
    return _dict;
}

+ (NSString *) getDict {
    if( _dict != nil ) return _dict;
    
    NSString *_dictPath = [[NSBundle mainBundle] pathForResource:@"dict" ofType:@"txt"];
    NSLog(@"%@", _dictPath);
    _dict = [NSString stringWithContentsOfFile:_dictPath encoding:NSUTF8StringEncoding error:nil];
    return _dict;
}

- (NSString *)pinyin_yuanyin {
    NSString *_dct = [NSString getDict];
    int lLen = [self length];
    NSMutableString *_pinyin = [[[NSMutableString alloc] init] autorelease];
    for (int i=0;i<lLen; i++) {
        NSLog(@"%@", [self substringWithRange:NSMakeRange(i, 1)]);
        NSRange startRange = [_dct rangeOfString:[self substringWithRange:NSMakeRange(i, 1)]];
        startRange.length = [_dct length] - startRange.location;
        
        NSRange a1 = [_dct rangeOfString:@"[" options:NSCaseInsensitiveSearch range:startRange];
        NSRange a2 = [_dct rangeOfString:@"]" options:NSCaseInsensitiveSearch range:startRange];
        NSRange r;
        r.location = a1.location + 1;
        r.length = a2.location - a1.location - 1;
        a1.length = a2.location - a1.location;
        
        [_pinyin appendString:[_dct substringWithRange:r]];
    }
    return _pinyin;
}
@end
