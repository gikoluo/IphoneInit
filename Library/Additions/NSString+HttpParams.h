//
//  NSString+HttpParams.h
//  Weibo
//
//  Created by  on 11-7-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTTPParams)
- (NSDictionary *) parse_dictionary;

- (NSString *)pinyin_yuanyin;

- (NSDictionary *) dictionaryToJson;
@end
