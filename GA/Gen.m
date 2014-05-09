//
//  Gen.m
//  GA
//
//  Created by Yuri Ageev on 15.01.14.
//  Copyright (c) 2014 ItDoesNotMatter Inc. All rights reserved.
//

#import "Gen.h"
#import "Processor.h"

@implementation Gen

- (id)init
{
    self = [super init];
    if (self) {
        Processor *pro1 = [[Processor alloc] init];
        Processor *pro2 = [[Processor alloc] init];
        Processor *pro3 = [[Processor alloc] init];
        Processor *pro4 = [[Processor alloc] init];
        
        self.processors = @[pro1, pro2, pro3, pro4];
    }
    return self;
}

- (NSString *)description {
    NSMutableString *descr = [[NSMutableString alloc] init];
    
    Processor *pro = self.processors[self.fitProIndex];
    
    [descr appendFormat:@"\nfit %ld: %ld <---------\n\n", self.fitProIndex, pro.loadedBy];
    
    [self.processors enumerateObjectsUsingBlock:^(Processor *pro, NSUInteger idx, BOOL *stop) {
        [descr appendFormat:@"pro %ld: %ld \n", idx, pro.loadedBy];
    }];
    [descr appendString:@"--------------------------+\n"];
    
    return descr;
}

@end
