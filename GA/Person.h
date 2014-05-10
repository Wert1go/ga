//
//  Gen.h
//  GA
//
//  Created by Yuri Ageev on 15.01.14.
//  Copyright (c) 2014 ItDoesNotMatter Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, strong) NSArray *processors;

@property (nonatomic, assign) NSUInteger fitProIndex;

@property (nonatomic, strong) NSMutableDictionary *hash;

+ (Person *)createWithTaskArray:(NSArray *)tasks;

- (NSInteger)optimalValue;

@end
