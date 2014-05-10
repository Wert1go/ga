//
//  Scheduler.m
//  GA
//
//  Created by Yuri Ageev on 14.01.14.
//  Copyright (c) 2014 ItDoesNotMatter Inc. All rights reserved.
//

#import "Scheduler.h"
#import "Task.h"
#import "Processor.h"
#import "Person.h"

#import "NSMutableArray+Shuffling.h"

#define POPULATION_SIZE     20

#define GENERATION_LIMIT    100

#define REFERENCE           @[@10, @20, @10, @30, @20, @40, @30, @10, @30, @20]

#define MAX_CAPACITY        210

@interface Scheduler ()

@property (nonatomic, assign) NSUInteger generationNumber;
@property (nonatomic, strong) NSMutableArray *population;
@property (nonatomic, strong) NSMutableArray *selected;
@property (nonatomic, strong) NSMutableDictionary *fitnessHash;

@end

@implementation Scheduler

- (id)init
{
    self = [super init];
    if (self) {
        [self createTastQueueFromArray:[self generateRandomTaskQueue]];
    }
    
    return self;
}

- (void)run {

    [self createFirstGeneration];

    [self optimize];
    [self printResult];
    NSLog(@"END");
}

- (void)optimize {
    NSAssert(self.taskQueue.count > 0, @"LOL");
    
    __block BOOL isRunning = YES;
    
    while (self.generationNumber < GENERATION_LIMIT && isRunning) {
        
        [self crossover];

        [self selection];

        [self createNewGeneration];
        
        __block NSUInteger counter = 0;
        [self.population enumerateObjectsUsingBlock:^(Person *person, NSUInteger idx, BOOL *stop) {
            Processor *processor = person.processors[person.fitProIndex];
            if (processor.loadedBy <= 60) {
                counter++;
            }
        }];
        
        if (counter >= (POPULATION_SIZE * 80)/100) {
            isRunning = NO;
        } else {
            [self printResult];
            self.generationNumber++;
        }
    }
}

- (void)createFirstGeneration {
    self.population = [[NSMutableArray alloc] init];
    self.generationNumber = 1;
    [self populate];
}

- (void)populate {
    for (int index = 0; index < POPULATION_SIZE; index++) {
        Person *person = [self create];
        [self fitness:person];
        [self.population addObject:person];
    }
}

- (Person *)create {
    /*
     
     Ген представляет собой экзепляр системы с 4 процессорами.
     Ниже имеющиеся задачи случайным образом распределяются между имеющимися процессорами.
     
     Алгоритм:
     1. из списка процессоров выбирается случайный процессор
     2. из очереди берется случайная задача
     3. если у процессора достаточно ресурсов для исполнения задачи, она ставится в его очередь и удаляется из общего списка
     иначе возвращение к п. 1
     
     
     */
    
    Person *gen = [[Person alloc] init];

    NSMutableArray *tasks = self.taskQueue.mutableCopy;
    NSInteger taskCount = tasks.count;
    while (taskCount != 0) {
        NSInteger proIndex = arc4random_uniform((unsigned int)gen.processors.count);
        Processor *pro = gen.processors[proIndex];
        
        NSInteger taskIndex = arc4random_uniform((unsigned int)taskCount);
        Task *task = tasks[taskIndex];
        
        if (pro.freeResourceSize >= task.requeredProcessResource) {
            [pro postTask:task];
            --taskCount;
            [tasks removeObject:task];
        }
    }
    
    return gen;
}

- (void)crossover {
    [self.population shuffle];
    
    for (int index = 0; index < POPULATION_SIZE; index += 2) {
        Person *parent1 = self.population[index];
        Person *parent2 = self.population[index + 1];
        
        Person *child = [self crossingParent1:parent1 parent2:parent2];
        [self.population addObject:child];
    }
}

- (Person *)crossingParent1:(Person *) parent1 parent2:(Person *) parent2 {
    
    Processor *pro1 = parent1.processors[parent1.fitProIndex];
    Processor *pro2 = parent2.processors[parent2.fitProIndex];
    
    NSLog(@"CROSSING");
    
    NSLog(@"parent 1: %@", parent1);
    NSLog(@"parent 2: %@", parent2);
    
    Person *dominatedParent;
    Person *secondParent;
    
    Processor *dominatedGen;
    Processor *secondGen;
    
    if (pro1.loadedBy > pro2.loadedBy) {
        dominatedGen = pro2;
        dominatedParent = parent2;
        secondParent = parent1;
        secondGen = pro1;
    } else {
        dominatedGen = pro1;
        dominatedParent = parent1;
        secondParent = parent2;
        secondGen = pro2;
    }
    
    Person *tempSecondParent = [[Person alloc] init];
    
    [secondParent.processors enumerateObjectsUsingBlock:^(Processor *parentGenes, NSUInteger idx, BOOL *stop) {
        Processor *childGenes = tempSecondParent.processors[idx];
        [parentGenes.taskQueue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [childGenes postTask:obj];
        }];
    }];
    
    secondParent = tempSecondParent;
    
    Person *child = [[Person alloc] init];
    
    [dominatedParent.processors enumerateObjectsUsingBlock:^(Processor *parentGenes, NSUInteger idx, BOOL *stop) {
        Processor *childGenes = child.processors[idx];
        [parentGenes.taskQueue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [childGenes postTask:obj];
        }];
    }];
    
    [child.processors enumerateObjectsUsingBlock:^(Processor *childGenes, NSUInteger index, BOOL *stop) {
        for (NSInteger secondIndex = 0; secondIndex < secondParent.processors.count; secondIndex++) {
            Processor *secondParentGenes = secondParent.processors[secondIndex];
            
            NSMutableArray *toRemove = [NSMutableArray array];
            [secondParentGenes.taskQueue enumerateObjectsUsingBlock:^(Task *task, NSUInteger idx, BOOL *stop) {
                
                if (![childGenes.taskQueue containsObject:task]) {
                    
                    if (childGenes.loadedBy + task.requeredProcessResource < dominatedGen.loadedBy) {
                        [childGenes postTask:task];
                        [toRemove addObject:task];
                    }
                }
            }];

            [toRemove enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [secondParentGenes removeTask:obj];
            }];
            
            [child.processors enumerateObjectsUsingBlock:^(Processor *processor, NSUInteger idx, BOOL *stop) {
                if (idx != index) {
                    [toRemove enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if ([processor.taskQueue containsObject:obj]) {
                            [processor removeTask:obj];
                        }
                    }];
                }
            }];
            
        }
    }];
    
    [self fitness:child];
    NSLog(@"Child: %@", child);
    
    return child;
}

- (void)selection {
    self.selected = [NSMutableArray array];
    self.fitnessHash = [NSMutableDictionary dictionary];
    
    NSMutableArray *fintessResults = [NSMutableArray array];
    
    for (int index = 0; index < self.population.count; index++) {
        NSUInteger fitness = [self fitness:self.population[index]];
        NSNumber *fitnessKey = [NSNumber numberWithInteger:fitness];
        
        self.fitnessHash[fitnessKey] = self.population[index];
        [fintessResults addObject:fitnessKey];
    }
    
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [fintessResults sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    
    for (int index = 0; index < POPULATION_SIZE; index++) {
        [self.selected addObject:self.fitnessHash[fintessResults[index]]];
    }
}

- (void)createNewGeneration {
    self.population = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < POPULATION_SIZE; index++) {
        if (index < self.selected.count) {
            [self.population addObject:self.selected[index]];
        } else {
            Person *gen = [self create];
            [self fitness:gen];
            [self.population addObject:gen];
        }
    }
}

- (NSInteger)fitness: (Person *)gen{
    
    __block NSUInteger loadedBy = 0;
    [gen.processors enumerateObjectsUsingBlock:^(Processor *pro, NSUInteger idx, BOOL *stop) {
        if (loadedBy < pro.loadedBy) {
            loadedBy = pro.loadedBy;
            gen.fitProIndex = idx;
        }
    }];
    
    return loadedBy;
}

#pragma mark - Utils

- (void)createTaskQueue {
    [self createTastQueueFromArray:REFERENCE];
}

- (void)createTastQueueFromArray:(NSArray *)taskArray {
    self.taskQueue = [NSMutableArray array];
    
    [taskArray enumerateObjectsUsingBlock:^(NSNumber *taskRequeredResources, NSUInteger idx, BOOL *stop) {
        Task *task = [[Task alloc] init];
        task.requeredProcessResource = taskRequeredResources.integerValue;
        [self.taskQueue addObject:task];
    }];
}

- (NSArray *)generateRandomTaskQueue {
    NSInteger maxCapacity = MAX_CAPACITY;
    NSMutableArray *tasks = [NSMutableArray array];
    
    while ([self sumCapacity:tasks] < maxCapacity) {
        NSInteger taskCapacity = (arc4random_uniform(4) + 1) * 10;
        if ([self sumCapacity:tasks] + taskCapacity <= maxCapacity) {
            [tasks addObject:@(taskCapacity)];
        }
    }

    NSLog(@"tasks: %@", tasks);
    
    return tasks;
}

- (NSInteger)sumCapacity:(NSArray *)tasks {
    __block NSInteger sum = 0;
    [tasks enumerateObjectsUsingBlock:^(NSNumber *taskRequeredResources, NSUInteger idx, BOOL *stop) {
        sum += taskRequeredResources.integerValue;
    }];
    
    return sum;
}

- (void)printResult {
    NSLog(@"******************************");
    NSLog(@"GENERATION: #%ld", self.generationNumber);
    NSMutableString *resultString = [[NSMutableString alloc] init];
    
    for (int index = 0; index < self.population.count; index++) {
        [resultString appendFormat:@"%ld \n", (long)[self fitness:self.population[index]]];
    }
    
    NSLog(@"\nfitness\n%@", resultString);
}

@end
