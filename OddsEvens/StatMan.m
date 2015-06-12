//
//  StatMan.m
//  OddsEvens
//
//  Created by Douglas Ellis on 6/12/15.
//  Copyright (c) 2015 Doug Ellis. All rights reserved.
//

#import "StatMan.h"

@interface StatMan ()

@property int wins;
@property int losses;
@property int streak;
@property  BOOL winning;

@end

@implementation StatMan


- (instancetype)init {
    self = [super init];
    [self resetStats];
    return self;
}

- (void)resetStats {
    
    _wins=0;
    _losses=0;
    _streak=0;
    _winning=FALSE;
    
}

- (void)addWin {
    _wins+=1;
    if (_winning) {
        _streak+=1;
    } else {
        _winning=TRUE;
        _streak=1;
    }
}
- (void)addLoss {
    _losses+=1;
    if (!_winning) {
        _streak+=1;
    } else {
        _winning=FALSE;
        _streak=1;
    }
}

- (NSString *)streakString {
    return [NSString stringWithFormat:@"%s: %d", (_winning)?"W":"L", _streak];
}
- (NSString *)statString {
    return [NSString stringWithFormat:@"W: %3d  L: %3d", _wins, _losses];
}


@end
