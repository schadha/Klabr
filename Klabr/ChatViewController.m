//
//  ChatViewController.m
//  Klabr
//
//  Created by Sanchit Chadha on 3/30/14.
//  Copyright (c) 2014 Sanchit Chadha. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@property (nonatomic, strong) NSString *SERVER_IP;
@property (nonatomic, strong) NSString *PORT;
@property (nonatomic, strong) NSMutableArray *messages;


@end

@implementation ChatViewController

- (void)viewDidLoad
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.SERVER_IP = [appDelegate.SERVER_IP substringFromIndex:7];
    self.PORT = appDelegate.PORT;
    
    self.messages = [[NSMutableArray alloc] init];
    
    [self setTitle:self.roomName];
    [self.messageBox setInputAccessoryView:[[UIView alloc] init]];
    
    socket = [[SocketIO alloc] initWithDelegate:self];
    [socket connectToHost:self.SERVER_IP onPort:[self.PORT integerValue]];
    
    SocketIOCallback cb = ^(id argsData) {
        // do something with response
    };
    
    [socket sendEvent:@"join_room" withData:self.roomName andAcknowledge:cb];
    
    [self setUpView];
    [super viewDidLoad];
}

- (void)setUpView
{
    CGFloat *range = (CGFloat*)malloc(sizeof(CGFloat) * 2);
    range[0] = 0.0f;
    range[1] = 1.0f;
    
    self.sendButton.rounding = 8.0f;
    self.sendButton.colors = @[[UIColor colorWithRed:91.0f/255 green:192.0f/255 blue:222.0f/255 alpha:1]];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendButton.selectedColors = @[[UIColor blueColor]];
    self.sendButton.disabledColors = @[[UIColor lightGrayColor]];
    self.sendButton.corners = UIRectCornerAllCorners;
    self.sendButton.colorRange = range;
    
    CGRect rect = CGRectMake(13, 522, 251, 30);
    BTTextField *messageField = [[BTTextField alloc] initWithFrame:rect];
    messageField.borderWidth = 1.5;
    messageField.borderColor = [UIColor colorWithRed:91.0f/255 green:192.0f/255 blue:222.0f/255 alpha:1];
    messageField.bodyColor = [UIColor colorWithWhite:0.95 alpha:1];
    messageField.placeholder = @"Enter Message Here";
    messageField.font = [UIFont systemFontOfSize:14];
    messageField.autocorrectionType = UITextAutocorrectionTypeDefault;
    messageField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    messageField.selectedBorderColor = [UIColor colorWithRed:91.0f/255 green:192.0f/255 blue:222.0f/255 alpha:1];
    [self.view addSubview:messageField];
    
    self.messageBox = messageField;
}

-(void)viewWillAppear:(BOOL)animated {
    [self scrollToBottom];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        
        SocketIOCallback cb = ^(id argsData) {
        };
        
        [socket sendEvent:@"leave_room" withData:self.roomName andAcknowledge:cb];
    }
    [super viewWillDisappear:animated];
}

- (IBAction)sendButton:(UIButton *)sender {
    NSString *message = [self.messageBox text];
    
    if (![message isEqualToString:@""]) {

        
        NSMutableDictionary *JSONDict = [[NSMutableDictionary alloc] init];
        [JSONDict setObject:[self.userData objectForKey:@"Username"] forKey:@"Username"];
        [JSONDict setObject:message forKey:@"Message"];
        [JSONDict setObject:[self.userData objectForKey:@"id"] forKey:@"userKey"];
        [JSONDict setObject:self.roomName forKey:@"room"];
        
        [socket sendEvent:@"add_message" withData:JSONDict];
        [self.messages addObject:[NSString stringWithFormat:@"%@ said: %@", [self.userData objectForKey:@"Username"], message]];
        
        [self.messageBox setText:@""];
        [self.chatTableView reloadData];
        [self scrollToBottom];
    }
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    if ([error code] == SocketIOUnauthorized) {
        NSLog(@"not authorized");
    } else {
        NSLog(@"onError() %@", error);
    }
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSLog(@"EVENT NAME: %@", packet.name);
    if ([packet.name isEqualToString:@"new_message"]) {
        NSDictionary *messageData = [[[packet dataAsJSON] objectForKey:@"args"] objectAtIndex:0];
        [self.messages addObject:[NSString stringWithFormat:@"%@ said: %@", [messageData objectForKey:@"Username"], [messageData objectForKey:@"Message"]]];
        [self.chatTableView reloadData];
        [self scrollToBottom];
    }
    else if ([packet.name isEqualToString:@"joined_room"]) {
        NSArray *messageData = [[[[packet dataAsJSON] objectForKey:@"args"] objectAtIndex:0] objectForKey:@"messages"];
        for (int i = 0; i < [messageData count]; i++) {
            NSString *username = [[messageData objectAtIndex:i] objectForKey:@"Username"];
            NSString *message =[[messageData objectAtIndex:i] objectForKey:@"said"];
            [self.messages addObject:[NSString stringWithFormat:@"%@ said: %@", username, message]];
            [self.chatTableView reloadData];
            [self scrollToBottom];
        }
    }
    else if ([packet.name isEqualToString:@"num_clients"]) {
        
    }
}

- (void)scrollToBottom
{
    CGFloat yOffset = 0;
    
    yOffset = self.chatTableView.contentSize.height - self.chatTableView.bounds.size.height;
    
    [self.chatTableView setContentOffset:CGPointMake(0, yOffset) animated:NO];
}

#pragma mark - UITableViewDataSource Protocol Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

// Customize the appearance of the table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell"];
    
    // Configure the cell
    NSUInteger rowNumber = [indexPath row];
    
    if (rowNumber < 7) {
        [self.chatTableView setUserInteractionEnabled:NO];
    }
    else {
        [self.chatTableView setUserInteractionEnabled:YES];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.textLabel setNumberOfLines:0];
    
    cell.textLabel.text = [self.messages objectAtIndex:rowNumber];
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell"];
    NSString *text = [self.messages objectAtIndex:[indexPath row]];
    
    CGFloat lineHeight = cell.textLabel.font.lineHeight;
    CGFloat lines = (text.length / 55.0f) * lineHeight;
    CGFloat height = lines + 50.0f; //adding some padding
    return height;
}

@end
