//
//  NSDictionaryAdditions.m
//  WeiboPad
//
//  Created by junmin liu on 10-10-6.
//  Copyright 2010 Openlab. All rights reserved.
//

#import "NSDictionary+Additions.h"

@implementation NSDictionary (Additions)


+ (id) dictionaryWithVaParam:(id) param arguments:(va_list) argList {
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    if( [param isKindOfClass:[NSDictionary class]] ) {
        va_end(argList);
        return param;
    }
    
    int i=0;
    id tmp;
    id tmpKey;
    while (1) {
        tmp = va_arg(argList, id);
        if( !tmp ) break;
        
        if(0 != i%2 ) {
            tmpKey = tmp;
            i++; continue;
        }
        
        if( i == 0 ) {
            [dict setValue:param forKey:tmp];
            i++;
            continue;
        }
        
        [dict setValue:tmpKey forKey:tmp];
        i++;
    }
    va_end(argList);
    
    return dict;
}

- (BOOL)getBoolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    return [self objectForKey:key] == [NSNull null] ? defaultValue 
						: [[self objectForKey:key] boolValue];
}

- (int)getIntValueForKey:(NSString *)key defaultValue:(int)defaultValue {
	return [self objectForKey:key] == [NSNull null] 
				? defaultValue : [[self objectForKey:key] intValue];
}

- (time_t)getTimeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue {
	NSString *stringTime   = [self objectForKey:key];
    if ((id)stringTime == [NSNull null]) {
        stringTime = @"";
    }
	struct tm created;
    time_t now;
    time(&now);
    
	if (stringTime) {
		if (strptime([stringTime UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
			strptime([stringTime UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
		}
		return mktime(&created);
	}
	return defaultValue;
}

- (long long)getLongLongValueValueForKey:(NSString *)key defaultValue:(long long)defaultValue {
	return [self objectForKey:key] == [NSNull null] 
		? defaultValue : [[self objectForKey:key] longLongValue];
}

- (NSString *)getStringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
	return [self valueForKey:key] == nil || [self valueForKey:key] == [NSNull null] 
				? defaultValue : [self valueForKey:key];
}


- (NSURL *) getURL:(id) url {
    NSMutableString *uri = [[[NSMutableString alloc] init] autorelease];
    if( [url isKindOfClass:NSClassFromString(@"NSURL")] ) { //NSURL
        [uri appendString:[url absoluteString]];
    } else {
        [uri appendString:url];
    }
    
    for (id key in self ) {
        if( [uri rangeOfString:@"?"].length > 0 ) {
            [uri appendString:@"&"];
        } else {
            [uri appendString:@"?"];
        }
        
        if( [[self valueForKey:key] isKindOfClass:[NSString class]] ) {
            [uri appendFormat:@"%@=%@", key, [[self valueForKey:key] URLEncodedString]];
        } else {
            [uri appendFormat:@"%@=%@", key, [self valueForKey:key]];
        }
    }
    
    return [NSURL URLWithString:uri];
}


@end
