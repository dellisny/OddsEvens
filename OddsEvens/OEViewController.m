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
    
    [self setUpConnection];
    [self setUpUi];
    [self setUpConnection];
    
    _stats=[[StatMan alloc] init];
    _odds=FALSE;
    [self toggleOE];
    [self cleanUI];
    [self redraw];
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
    [_historyView scrollRectToVisible:CGRectMake(0, _historyView.contentSize.height - _historyView.bounds.size.height, _historyView.bounds.size.width, _historyView.bounds.size.height) animated:YES];
}

- (int) pick {
    // Get random value between 0 and 1
    int x = arc4random() % 2;
    x+=1;
    _gamePick.text = [NSString stringWithFormat:@"%d",x];
    return x;
}

- (void)push:(int)val {
    
    NSString *message = [NSString stringWithFormat:@"%d",val];
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    if (![self.session sendData:data
                        toPeers:_session.connectedPeers
                       withMode:MCSessionSendDataReliable
                          error:&error]) {
        NSLog(@"[Data Send Error] %@", error);
    }
    
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
    //NSLog(@"Number of rows in TableView is %d", (unsigned int)[_stats.history count]);
    //NSLog(@"The view is %@",tableView);
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

#pragma mark Connections

-(void) setUpUi
{
    //Set the text on the navigation bar
    //self.title = @"OddsEvens";
    
    //Create a bar button item with Apples default search icon
    //UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchForPeers)];
    
    //Add the search button to the nav bar.
    //self.navigationItem.rightBarButtonItem = searchButton;
}

-(void) setUpConnection {
    //Set our display name to be the name of the device
    self.peerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    
    //Create a new session with our peerID
    self.session = [[MCSession alloc] initWithPeer:self.peerID];
    self.session.delegate = self;
    
    //Create a browser view with our service type and session
    self.browserViewController = [[MCBrowserViewController alloc] initWithServiceType:@"OddsEvens" session:self.session];
    self.browserViewController.maximumNumberOfPeers = 2;
    
    self.browserViewController.delegate = self;
    
    //Create an advertiser assistant to make our device discoverable
    self.advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:@"OddsEvens" discoveryInfo:Nil session:self.session];
    
    //Start advertising!
    [self.advertiserAssistant start];
}

-(void) searchForPeers
{
    [self presentViewController:self.browserViewController animated:YES completion:nil];
}

#pragma mark Session Delegate Methods

//Called when a peer connects to the user, or the users device connects to a peer.
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    NSLog(@"Got Peer info %@ %d", peerID, (int) state);
}

// Called when the users device recieves data from a peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Got Peer data %@ %@", peerID, newStr);
}

// Called when the users device recieves a byte stream from a peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}

// Called when the users device recieves a resource from a peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}

// Called when the users device has finished recieving data from a peer.
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}

#pragma BrowserView Delegate Methods

//Called when the user has selected a peer to connect to
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [self.browserViewController dismissViewControllerAnimated:YES completion:nil];
}

// Called when the user has tapped the Cancel button the peer selection screen.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self.browserViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
