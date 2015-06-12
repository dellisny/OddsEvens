//
//  OEViewController.m
//  
//
//  Created by Douglas Ellis on 6/12/15.
//
//

#import "OEViewController.h"
#import "StatMan.h"

@interface OEViewController ()

@property StatMan *stats;
@property BOOL odds;

@end

@implementation OEViewController

- (void) cleanUI {
    _gamePick.text=@"";
    _userPick.text=@"";
    _statusBox.boxState=OEBoxNone;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"I'm here");
    _stats=[[StatMan alloc] init];
    _odds=FALSE;
    [self toggleOE];
    [self cleanUI];
    [self redraw];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Game Actions

- (void) redraw {
    [_statusBox setNeedsDisplay];
    _statLine.text=[_stats statString];
    _streakLine.text=[_stats streakString];
}

- (int) pick {
    // Get random value between 0 and 1
    int x = arc4random() % 2;
    x+=1;
    _gamePick.text = [NSString stringWithFormat:@"%d",x];
    return x;
}

- (void)push:(int)val {
    int pick = [self pick];
    _userPick.text = [NSString stringWithFormat:@"%d",val];
    
    if (_odds) {
        if (pick!=val) {
            _statusBox.boxState=OEBoxWin;
            [_stats addWin];
        } else {
            _statusBox.boxState=OEBoxLose;
            [_stats addLoss];
        }
    } else {
        if (pick==val) {
            [_stats addWin];
            _statusBox.boxState=OEBoxWin;
        } else {
            _statusBox.boxState=OEBoxLose;
            [_stats addLoss];
        }
    }
    [self redraw];
}

- (IBAction)pushOne {
    [self push:1];
}

- (IBAction)pushTwo {
    [self push:2];
}

- (IBAction)resetStats {
    [_stats resetStats];
    [self cleanUI];
    [self redraw];
}

- (IBAction)toggleOE {
    _odds=!_odds;
    [_stats resetStats];
    NSString *titleForButton=(_odds)?@"Odds":@"Evens";
    [_toggleButton setTitle:titleForButton forState: UIControlStateNormal];
    [self cleanUI];
    [self redraw];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
