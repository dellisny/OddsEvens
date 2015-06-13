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
    [_historyView reloadData];
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
            _statusBox.boxState=OEBoxWin;
            [_stats addWin];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSLog(@"Number of rows is %d", (unsigned int)[_stats.history count]);
    return [_stats.history count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    //NSLog(@"I'm viewing...");
    NSString *item = [_stats.history objectAtIndex:indexPath.row];
    cell.textLabel.text = item;
    if ([item isEqualToString:@"W"]) {
        cell.backgroundColor=[UIColor greenColor];
        cell.textLabel.textColor=[UIColor greenColor];
    } else {
        cell.backgroundColor=[UIColor redColor];
        cell.textLabel.textColor=[UIColor redColor];
    }
    cell.layer.borderColor = [UIColor blackColor].CGColor;
    cell.layer.borderWidth = 1.0f;
    return cell;
}

@end
