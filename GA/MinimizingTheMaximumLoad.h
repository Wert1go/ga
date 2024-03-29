//
//  Scheduler.h
//  GA
//
//  Created by Yuri Ageev on 14.01.14.
//  Copyright (c) 2014 ItDoesNotMatter Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MinimizingTheMaximumLoad : NSObject

@property (nonatomic, strong) NSMutableArray *taskQueue;

- (void)run;
- (void)runWithoutGA;

@end
