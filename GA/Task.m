//
//  Task.m
//  GA
//
//  Created by Yuri Ageev on 14.01.14.
//  Copyright (c) 2014 ItDoesNotMatter Inc. All rights reserved.
//

#import "Task.h"

@implementation Task

- (id)init
{
    self = [super init];
    if (self) {
        self.requeredProcessResource = arc4random_uniform(100);
        self.executionTime = self.requeredProcessResource % 10 * 5;
    }
    return self;
}

@end
