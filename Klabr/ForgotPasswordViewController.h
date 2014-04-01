//
//  ForgotPasswordViewController.h
//  Klabr
//
//  Created by Sanchit Chadha on 3/30/14.
//  Copyright (c) 2014 Sanchit Chadha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "BTTextField.h"
#import "BTButton.h"

@interface ForgotPasswordViewController : UIViewController
@property (strong, nonatomic) IBOutlet BTTextField *userNameField;
@property (strong, nonatomic) IBOutlet BTButton *recoverPasswordButton;
- (IBAction)recoverPasswordButton:(UIButton *)sender;

@end
