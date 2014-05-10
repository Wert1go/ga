//
//  Gen.m
//  GA
//
//  Created by Yuri Ageev on 15.01.14.
//  Copyright (c) 2014 ItDoesNotMatter Inc. All rights reserved.
//

#import "Person.h"
#import "Processor.h"

@implementation Person

- (id)init
{
    self = [super init];
    if (self) {
        Processor *pro1 = [[Processor alloc] init];
        Processor *pro2 = [[Processor alloc] init];
        Processor *pro3 = [[Processor alloc] init];
        Processor *pro4 = [[Processor alloc] init];
        
        self.processors = @[pro1, pro2, pro3, pro4];
        self.hash = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (NSString *)description {
    NSMutableString *descr = [[NSMutableString alloc] init];
    
    Processor *pro = self.processors[self.fitProIndex];
    
    [descr appendFormat:@"\nfit %ld: %ld <---------\n\n", self.fitProIndex, pro.loadedBy];
    
    __block NSInteger sum = 0;
    [self.processors enumerateObjectsUsingBlock:^(Processor *pro, NSUInteger idx, BOOL *stop) {
        sum += pro.loadedBy;
        [descr appendFormat:@"pro %ld: %ld \n", idx, pro.loadedBy];
    }];
    
    [descr appendFormat:@"sum = %ld \n", sum];
    [descr appendString:@"--------------------------+\n"];
    
    return descr;
}

@end
