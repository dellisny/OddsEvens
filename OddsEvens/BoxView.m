//
//  BoxView.m
//  OddsEvens
//
//  Created by Douglas Ellis on 6/12/15.
//  Copyright (c) 2015 Doug Ellis. All rights reserved.
//

#import "BoxView.h"



@implementation BoxView



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing Rect
    if (_boxState == OEBoxNone) {
        [[UIColor whiteColor] setFill];  // clear

    } else if (_boxState == OEBoxWin) {
        [[UIColor greenColor] setFill];  // green

    } else {
        [[UIColor redColor] setFill];  // red
    }

    UIRectFill(CGRectInset(self.bounds, 0, 0));
}



@end
