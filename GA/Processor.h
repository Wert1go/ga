//
//  Processor.h
//  GA
//
//  Created by Yuri Ageev on 14.01.14.
//  Copyright (c) 2014 ItDoesNotMatter Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Task;

@protocol TaskManagmentProtocol <NSObject>

@optional
- (void) didCompliteTask: (Task *)task;

@end

@interface Processor : NSObject

@property (nonatomic, assign) NSUInteger totalResourceSize;
@property (nonatomic, assign) NSUInteger freeResourceSize;

@property (nonatomic, readonly) NSUInteger loadedBy;

@property (nonatomic, strong) NSMutableArray *taskQueue;

@property (nonatomic, assign) id<TaskManagmentProtocol> taskScheduler;

- (void) postTask: (Task *) task;
- (void) flush;

@end
