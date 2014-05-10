//
//  Processor.m
//  GA
//
//  Created by Yuri Ageev on 14.01.14.
//  Copyright (c) 2014 ItDoesNotMatter Inc. All rights reserved.
//

#import "Processor.h"

#import "Task.h"

@implementation Processor

- (id)init
{
    self = [super init];
    
    if (self) {
        self.taskQueue = [NSMutableArray array];
        self.totalResourceSize = 100;
        self.freeResourceSize = self.totalResourceSize;
    }
    
    return self;
}

- (void) postTask:(Task *)task {
    [self.taskQueue addObject:task];
    self.freeResourceSize = self.freeResourceSize - task.requeredProcessResource;
}

- (void) flush {
    [self.taskQueue removeAllObjects];
    self.freeResourceSize = self.totalResourceSize;
}

- (NSUInteger)loadedBy {
    return self.totalResourceSize - self.freeResourceSize;
}

@end
