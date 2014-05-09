//
//  Scheduler.h
//  GA
//
//  Created by Yuri Ageev on 14.01.14.
//  Copyright (c) 2014 ItDoesNotMatter Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Scheduler : NSObject

@property (nonatomic, strong) NSMutableArray *taskQueue;
@property (nonatomic, strong) NSMutableArray *taskIndexes;

- (void) run;

- (void) optimize;

@end
