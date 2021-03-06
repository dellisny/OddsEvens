//
//  OEViewController.h
//  
//
//  Created by Douglas Ellis on 6/12/15.
//
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "BoxView.h"

@interface OEViewController : UIViewController <MCBrowserViewControllerDelegate,MCSessionDelegate>


typedef NS_ENUM (NSInteger,
                 OEGameMode ) {
    OELocal,
    OERemote,
};

- (IBAction)pushOne;
- (IBAction)pushTwo;
- (IBAction)resetStats;
- (IBAction)toggleOE;
- (IBAction)searchForPeers;

@property (weak, nonatomic) IBOutlet UILabel *waitLabel;
@property (weak, nonatomic) IBOutlet UILabel *userPick;
@property (weak, nonatomic) IBOutlet UILabel *gamePick;
@property (weak, nonatomic) IBOutlet UILabel *streakLine;
@property (weak, nonatomic) IBOutlet UILabel *statLine;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet BoxView *statusBox;
@property (weak, nonatomic) IBOutlet UITableView *historyView;
@property (weak, nonatomic) IBOutlet UILabel *peerName;

// connection stuff

typedef NS_ENUM (NSInteger,
                 OERemoteState ) {
    OERemoteNone,
    OERemoteSent,
    OERemoteReceiveNoSend,
    OERemoteDone,
};
@property (nonatomic, retain) MCBrowserViewController *browserViewController;
@property (nonatomic, retain) MCAdvertiserAssistant *advertiserAssistant;
@property (nonatomic, retain) MCSession *session;
@property (nonatomic, retain) MCPeerID *peerID;
@property (nonatomic, retain) NSMutableArray *messages;

@end

