//
//  BoxView.h
//  OddsEvens
//
//  Created by Douglas Ellis on 6/12/15.
//  Copyright (c) 2015 Doug Ellis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoxView : UIView

enum OEBoxState : NSUInteger {
    OEBoxNone = 1,
    OEBoxWin = 2,
    OEBoxLose = 3
};

@property enum OEBoxState boxState;


@end
