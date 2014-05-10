//
//  NSMutableArray+Shuffling.m
//  GA
//
//  Created by Yuri Ageev on 10.05.14.
//  Copyright (c) 2014 ItDoesNotMatter Inc. All rights reserved.
//

#import "NSMutableArray+Shuffling.h"

@implementation NSMutableArray (Shuffling)

- (void)shuffle {
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSUInteger nElements = count - i;
        NSInteger n = arc4random_uniform((unsigned int)nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
