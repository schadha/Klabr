//
//  CreateAccountViewController.m
//  Klabr
//
//  Created by Sanchit Chadha on 3/30/14.
//  Copyright (c) 2014 Sanchit Chadha. All rights reserved.
//

#import "CreateAccountViewController.h"

@interface CreateAccountViewController ()

@property (nonatomic, strong) NSString *SERVER_IP;
@property (nonatomic, strong) NSString *PORT;
@property (nonatomic, strong) NSDictionary *userData;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end

@implementation CreateAccountViewController

- (void)viewDidLoad
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.SERVER_IP = appDelegate.SERVER_IP;
    self.PORT = appDelegate.PORT;
    
    self.userData = [[NSMutableDictionary alloc]init];
    
    [self setUpView];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)createAccountTask:(NSString*)username password:(NSString *)password
{
    NSString *post = [NSString stringWithFormat:@"Username=%@&Password=%@",
                      [self urlEncodeValue:username],
                      [self urlEncodeValue:password]];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@/user/create", self.SERVER_IP, self.PORT]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [[NSURLConnection connectionWithRequest:request delegate:self] start];
    
}

- (IBAction)createAccountButton:(UIButton *)sender
{
    self.username = [self.userNameField text];
    
    if ([[self.passwordField1 text] isEqualToString:[self.passwordField2 text]]) {
            self.password = [self.passwordField1 text];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Password Mismatch"
                              message:@"Passwords don't match in both fields."
                              delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([self.username isEqualToString:@""] || [self.password isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Incomplete Fields"
                              message:@"Please fill in the Username and Password fields!"
                              delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else {
        [self createAccountTask:self.username password:self.password];
    }
}

- (NSString *)urlEncodeValue:(NSString *)str
{
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8));
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSError *error = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
    self.userData = jsonDictionary;
    
    if (![self.userData objectForKey:@"Error"]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Account Created"
                              message:@"Account created succesfully!"
                              delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Username Already Exists"
                              message:@"Choose another username!"
                              delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Connection Error"
                          message:@"There seems to be a problem with the server, try again later."
                          delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if([[alertView title] isEqualToString:@"Account Created"] && buttonIndex == 0)
    {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)setUpView
{
    CGFloat *range = (CGFloat*)malloc(sizeof(CGFloat) * 2);
    range[0] = 0.0f;
    range[1] = 1.0f;
    
    self.createAccountButton.rounding = 8.0f;
    self.createAccountButton.colors = @[[UIColor colorWithRed:92.0f/255 green:184.0f/255 blue:92.0f/255 alpha:1]];
    [self.createAccountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.createAccountButton.selectedColors = @[[UIColor blueColor]];
    self.createAccountButton.disabledColors = @[[UIColor lightGrayColor]];
    self.createAccountButton.corners = UIRectCornerAllCorners;
    self.createAccountButton.colorRange = range;
    
    CGRect rect = CGRectMake(20, 89, 280, 30);
    BTTextField *userNameField = [[BTTextField alloc] initWithFrame:rect];
    userNameField.borderWidth = 1.5;
    userNameField.borderColor = [UIColor colorWithRed:92.0f/255 green:184.0f/255 blue:92.0f/255 alpha:1];
    userNameField.bodyColor = [UIColor colorWithWhite:0.95 alpha:1];
    userNameField.placeholder = @"Select Your User Name";
    userNameField.font = [UIFont systemFontOfSize:14];
    userNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    userNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    userNameField.selectedBorderColor = [UIColor colorWithRed:92.0f/255 green:184.0f/255 blue:92.0f/255 alpha:1];
    [self.view addSubview:userNameField];
    
    CGRect rect2 = CGRectMake(20, 127, 280, 30);
    BTTextField *passwordField1 = [[BTTextField alloc] initWithFrame:rect2];
    passwordField1.borderWidth = 1.5;
    passwordField1.borderColor = [UIColor colorWithRed:92.0f/255 green:184.0f/255 blue:92.0f/255 alpha:1];
    passwordField1.bodyColor = [UIColor colorWithWhite:0.95 alpha:1];
    passwordField1.placeholder = @"Password";
    passwordField1.font = [UIFont systemFontOfSize:14];
    passwordField1.secureTextEntry = YES;
    passwordField1.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordField1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordField1.selectedBorderColor = [UIColor colorWithRed:92.0f/255 green:184.0f/255 blue:92.0f/255 alpha:1];
    [self.view addSubview:passwordField1];
    
    CGRect rect3 = CGRectMake(20, 165, 280, 30);
    BTTextField *passwordField2 = [[BTTextField alloc] initWithFrame:rect3];
    passwordField2.borderWidth = 1.5;
    passwordField2.borderColor = [UIColor colorWithRed:92.0f/255 green:184.0f/255 blue:92.0f/255 alpha:1];
    passwordField2.bodyColor = [UIColor colorWithWhite:0.95 alpha:1];
    passwordField2.placeholder = @"Re-Enter Password";
    passwordField2.font = [UIFont systemFontOfSize:14];
    passwordField2.secureTextEntry = YES;
    passwordField2.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordField2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordField2.selectedBorderColor = [UIColor colorWithRed:92.0f/255 green:184.0f/255 blue:92.0f/255 alpha:1];
    [self.view addSubview:passwordField2];
    
    self.userNameField = userNameField;
    self.passwordField1 = passwordField1;
    self.passwordField2 = passwordField2;
}
@end