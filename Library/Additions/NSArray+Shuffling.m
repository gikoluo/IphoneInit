#import "NSArray+Shuffling.h"

@implementation NSArray (Shuffling)

- (NSArray *)shuffledArray {
    NSMutableArray *newArray = [[self mutableCopy] autorelease];
    [newArray shuffle];
    return newArray;
}
@end


@implementation NSMutableArray (Shuffling)
- (void)shuffle {
    @synchronized(self) {
        NSUInteger count = [self count];
        
        if (count == 0) {
            return;
        }
        
        for (NSUInteger i = 0; i < count; i++) {
            NSUInteger j = arc4random() % (count - 1);
            
            if (j != i) {
                [self exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
}

@end