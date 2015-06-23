//
//  OEViewController.m
//  
//
//  Created by Douglas Ellis on 6/12/15.
//
//

#import "OEViewController.h"
#import "StatMan.h"
#import "DELog.h"

@interface OEViewController ()

@property StatMan *stats;
@property BOOL oddsP;

// Game is local or remote?
@property BOOL isGameLocal;

@property NSNumber *remotePick;
@property NSNumber *localPick;
@property DELog *theLog;

@property BOOL needLocal;
@property BOOL needRemote;

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
    _theLog=[DELog sharedInstance];
    [_theLog setLogFileName:@"/tmp/Hola.log"];
    [_theLog setLogLevel:DELOG_Debug];
    [_theLog setLoggingEnabled:TRUE];    
    [_theLog logTrace:@"I'm here too!"];
    
    [self setUpConnection];
    [self setUpUi];
    [self setUpConnection];
    
    _stats=[[StatMan alloc] init];
    _oddsP=FALSE;
    _isGameLocal=TRUE;
    
    _remotePick=nil;
    _localPick=nil;
    
    _needLocal=TRUE;
    _needRemote=TRUE;
    _waitLabel.text=@"";
    _peerName.text=@"Local";
    
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
    [_theLog logTrace:@"redraw"];
    [_statusBox setNeedsDisplay];
    _statLine.text=[_stats statString];
    _streakLine.text=[_stats streakString];
    [_historyView reloadData];
    [_historyView scrollRectToVisible:CGRectMake(0, _historyView.contentSize.height - _historyView.bounds.size.height, _historyView.bounds.size.width, _historyView.bounds.size.height) animated:YES];
}

- (NSNumber *) pick {
    [_theLog logTrace:@"pick"];

    // Get random value between 0 and 1
    int x = arc4random() % 2;
    x+=1;
    _gamePick.text = [NSString stringWithFormat:@"%d",x];
    return [NSNumber numberWithInt:x];
}

- (void)push:(int)val {
    [_theLog logTrace:@"push %d", val];

    _userPick.text = [NSString stringWithFormat:@"%d",val];
    
    // Remote Game
    if (!_isGameLocal) {
        _needLocal=FALSE;
        
        [self tellRemote:[NSNumber numberWithInt:val]];
        [self.view setNeedsDisplay];
        if (!_needRemote) {
            _waitLabel.text=@"";
            [self finishPlay:_remotePick];
        }
        else {
            _waitLabel.text=@"Them";
        }
    }
    // Local Game
    else {
        NSNumber *pick = [self pick];
        [self finishPlay:pick];
    }
}

// 0 means toggle
// 1 or 2 is the guess
- (void) tellRemote:(NSNumber *)val {
    NSString *message = [NSString stringWithFormat:@"%d",[val intValue]];
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    
    [_theLog logTrace:@"Sending Peer data %d", [val intValue]];
    if (![self.session sendData:data
                        toPeers:_session.connectedPeers
                       withMode:MCSessionSendDataReliable
                          error:&error]) {
        [_theLog logTrace:@"Data Send Error %@", error];
    }
}

- (void) finishPlay:(NSNumber *)pick {
    [_theLog logTrace:@"finishPlay:"];
 
    int val = [_localPick intValue];
    int p=[pick intValue];
    
    if (_oddsP) {
        if (p!=val) {
            _statusBox.boxState=OEBoxWin;
            [_theLog logTrace:@"I won"];
            [_stats addWin];
        }
        else {
            _statusBox.boxState=OEBoxLose;
            [_theLog logTrace:@"I lost"];
            [_stats addLoss];
        }
    }
    else {
        if (p==val) {
            _statusBox.boxState=OEBoxWin;
            [_theLog logTrace:@"I won"];
            [_stats addWin];
        }
        else {
            _statusBox.boxState=OEBoxLose;
            [_theLog logTrace:@"I lost"];
            [_stats addLoss];
        }
    }
    [self redraw];
    _localPick=nil;
    _remotePick=nil;
    _needLocal=TRUE;
    _needRemote=TRUE;
    _waitLabel.text=@"";

}

- (IBAction)pushOne {
    _localPick=[NSNumber numberWithInt:1];
    [self push:1];
}

- (IBAction)pushTwo {
    _localPick=[NSNumber numberWithInt:2];
    [self push:2];
}

- (IBAction)resetStats {
    [_stats resetStats];
    [self cleanUI];
    [self redraw];
}

- (IBAction)toggleOE {
    _oddsP=!_oddsP;
    NSString *titleForButton=(_oddsP)?@"Odds":@"Evens";
    [_toggleButton setTitle:titleForButton forState: UIControlStateNormal];
    
    if (!_isGameLocal) {
        [self tellRemote:[NSNumber numberWithInt:0]];
    }
    //[_stats resetStats];
    //[self cleanUI];
    [self redraw];
}


- (IBAction)searchForPeers {
    [self presentViewController:self.browserViewController animated:YES completion:nil];
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
    NSString *item = [_stats.history objectAtIndex:indexPath.row];
    cell.textLabel.text = item;
    if ([item isEqualToString:@"W"]) {
        cell.backgroundColor=[UIColor greenColor];
        cell.textLabel.textColor=[UIColor greenColor];
    }
    else {
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


#pragma mark Session Delegate Methods

//Called when a peer connects to the user, or the users device connects to a peer.
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    [_theLog logTrace:@"Got Peer info %@ %d", peerID, (int) state];
    
    // On disconnect
    if (state==MCSessionStateNotConnected) {
        _isGameLocal=TRUE;
        [_theLog logTrace:@"Lost peer, going back to local mode"];
        [_peerName performSelectorOnMainThread: @selector(setText:) withObject:@"Local" waitUntilDone:TRUE];
        [self resetStats];
    }
    else if (state==MCSessionStateConnected) {
        [_theLog logTrace:@"Setting peer label to (%@)", [peerID displayName]];
        _isGameLocal=FALSE;
        [_peerName performSelectorOnMainThread: @selector(setText:) withObject:[peerID displayName] waitUntilDone:TRUE];
    }
}

// Called when the users device recieves data from a peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    int valFromPeer = [newStr intValue];
    
    [_theLog logTrace:@"Got Peer data %d", valFromPeer];
    
    // 0 means toggle
    if (valFromPeer ==0) {
        _isGameLocal=TRUE;
        [self performSelectorOnMainThread: @selector(toggleOE) withObject:nil waitUntilDone:TRUE];
        _isGameLocal=FALSE;
    }
    else {
        _remotePick=[NSNumber numberWithInt:valFromPeer];
        _needRemote=FALSE;
        if (!_needLocal) {
            [_waitLabel performSelectorOnMainThread: @selector(setText:) withObject:@"" waitUntilDone:TRUE];
            [self performSelectorOnMainThread: @selector(finishPlay:) withObject:_remotePick waitUntilDone:TRUE];
        }
        else {
            [_waitLabel performSelectorOnMainThread: @selector(setText:) withObject:@"You" waitUntilDone:TRUE];
        }
    }
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
    // hack to force peer to be opposite of local in terms of odds/evens at the start
    _isGameLocal=TRUE;
    [self tellRemote:[NSNumber numberWithInt:0]];
    _isGameLocal=FALSE;
    
    [self.browserViewController dismissViewControllerAnimated:YES completion:nil];
}

// Called when the user has tapped the Cancel button the peer selection screen.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self.browserViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
