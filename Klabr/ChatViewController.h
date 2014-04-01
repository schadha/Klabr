//
//  ChatViewController.h
//  Klabr
//
//  Created by Sanchit Chadha on 3/30/14.
//  Copyright (c) 2014 Sanchit Chadha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketIO.h"
#import "SocketIOPacket.h"
#import "AppDelegate.h"
#import "BTTextField.h"
#import "BTButton.h"

@interface ChatViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SocketIODelegate>
{
    SocketIO *socket;
}
@property (strong, nonatomic) IBOutlet UITableView *chatTableView;
@property (strong, nonatomic) IBOutlet BTTextField *messageBox;
- (IBAction)sendButton:(UIButton *)sender;
@property (nonatomic, strong) NSDictionary *userData;
@property (nonatomic, strong) NSString *roomName;
@property (strong, nonatomic) IBOutlet BTButton *sendButton;


@end
