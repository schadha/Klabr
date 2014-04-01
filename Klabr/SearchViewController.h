//
//  SearchViewController.h
//  Klabr
//
//  Created by Sanchit Chadha on 3/30/14.
//  Copyright (c) 2014 Sanchit Chadha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "ChatViewController.h"
#import "BTTextField.h"
#import "BTButton.h"

@interface SearchViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>


@property (strong, nonatomic) IBOutlet BTTextField *searchField;
- (IBAction)searchButton:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet BTButton *searchButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *userData;



@end
