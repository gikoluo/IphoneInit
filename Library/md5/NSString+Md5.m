//
//  NSString+Helper.m
//  YurongCorp
//
//  Created by 李 博 on 11-4-8.
//  Copyright 2011 yurongbobo. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSString+Md5.h"


@implementation NSString (Md5)

//md5
- (NSString *) md5 {
    const char *cStr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result );
    return [[NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ] lowercaseString];
}

@end
