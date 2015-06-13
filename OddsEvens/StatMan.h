//
//  StatMan.h
//  OddsEvens
//
//  Created by Douglas Ellis on 6/12/15.
//  Copyright (c) 2015 Doug Ellis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatMan : NSObject

@property NSMutableArray *history;

- (void)resetStats;
- (void)addWin;
- (void)addLoss;

- (NSString *)streakString;
- (NSString *)statString;

@end
