//
//  CreateAccountViewController.h
//  Klabr
//
//  Created by Sanchit Chadha on 3/30/14.
//  Copyright (c) 2014 Sanchit Chadha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "BTButton.h"
#import "BTTextField.h"

@interface CreateAccountViewController : UIViewController<UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet BTTextField *userNameField;
@property (strong, nonatomic) IBOutlet BTTextField *passwordField1;
@property (strong, nonatomic) IBOutlet BTTextField *passwordField2;
@property (strong, nonatomic) IBOutlet BTButton *createAccountButton;

- (IBAction)createAccountButton:(UIButton *)sender;

@end
