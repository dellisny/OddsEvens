//
//  OEViewController.h
//  
//
//  Created by Douglas Ellis on 6/12/15.
//
//

#import <UIKit/UIKit.h>
#import "BoxView.h"

@interface OEViewController : UIViewController

- (IBAction)pushOne;
- (IBAction)pushTwo;
- (IBAction)resetStats;
- (IBAction)toggleOE;

@property (weak, nonatomic) IBOutlet UILabel *userPick;
@property (weak, nonatomic) IBOutlet UILabel *gamePick;
@property (weak, nonatomic) IBOutlet UILabel *streakLine;
@property (weak, nonatomic) IBOutlet UILabel *statLine;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet BoxView *statusBox;

@end
