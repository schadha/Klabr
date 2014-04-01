//
//  HomeViewController.h
//  Klabr
//
//  Created by Sanchit Chadha on 3/30/14.
//  Copyright (c) 2014 Sanchit Chadha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SearchViewController.h"
#import "BTButton.h"
#import "BTTextField.h"

@interface HomeViewController : UIViewController<NSURLConnectionDelegate>



- (IBAction)loginButton:(UIButton *)sender;
- (IBAction)createAccountButton:(UIButton *)sender;
- (IBAction)forgotPasswordButton:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet BTButton *loginButton;
@property (strong, nonatomic) IBOutlet BTButton *createAccountButton;
@property (strong, nonatomic) IBOutlet BTButton *forgotPasswordButton;
@property (strong, nonatomic) IBOutlet BTTextField *userNameField;
@property (strong, nonatomic) IBOutlet BTTextField *passwordField;

@end
