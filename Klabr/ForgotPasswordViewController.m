//
//  ForgotPasswordViewController.m
//  Klabr
//
//  Created by Sanchit Chadha on 3/30/14.
//  Copyright (c) 2014 Sanchit Chadha. All rights reserved.
//

#import "ForgotPasswordViewController.h"

@interface ForgotPasswordViewController ()

@property (nonatomic, strong) NSString *SERVER_IP;
@property (nonatomic, strong) NSString *PORT;
@property (nonatomic, strong) NSDictionary *userData;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *username;

@end

@implementation ForgotPasswordViewController

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

- (void)recoverPasswordTask:(NSString*)username
{
    NSString *post = [NSString stringWithFormat:@"Username=%@",
                      [self urlEncodeValue:username]];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@/user/forgotpassword", self.SERVER_IP, self.PORT]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [[NSURLConnection connectionWithRequest:request delegate:self] start];
    
}

- (IBAction)recoverPasswordButton:(UIButton *)sender
{
    self.username = [self.userNameField text];
    
    
    if ([self.username isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Incomplete Fields"
                              message:@"Please fill in the Username and Password fields!"
                              delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else {
        [self recoverPasswordTask:self.username];
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
                              initWithTitle:@"Password Recovered"
                              message:@"An email with a new password has been sent!"
                              delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Username Doesn't Exist"
                              message:@"Enter a valid username!"
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
    
    if([[alertView title] isEqualToString:@"Password Recovered"] && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)setUpView
{
    CGFloat *range = (CGFloat*)malloc(sizeof(CGFloat) * 2);
    range[0] = 0.0f;
    range[1] = 1.0f;
    
    self.recoverPasswordButton.rounding = 8.0f;
    self.recoverPasswordButton.colors = @[[UIColor colorWithRed:92.0f/255 green:184.0f/255 blue:92.0f/255 alpha:1]];
    [self.recoverPasswordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.recoverPasswordButton.selectedColors = @[[UIColor blueColor]];
    self.recoverPasswordButton.disabledColors = @[[UIColor lightGrayColor]];
    self.recoverPasswordButton.corners = UIRectCornerAllCorners;
    self.recoverPasswordButton.colorRange = range;
    
    CGRect rect = CGRectMake(20, 105, 280, 30);
    BTTextField *userNameField = [[BTTextField alloc] initWithFrame:rect];
    userNameField.borderWidth = 1.5;
    userNameField.borderColor = [UIColor colorWithRed:92.0f/255 green:184.0f/255 blue:92.0f/255 alpha:1];
    userNameField.bodyColor = [UIColor colorWithWhite:0.95 alpha:1];
    userNameField.placeholder = @"Enter Your User Name";
    userNameField.font = [UIFont systemFontOfSize:14];
    userNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    userNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    userNameField.selectedBorderColor = [UIColor colorWithRed:92.0f/255 green:184.0f/255 blue:92.0f/255 alpha:1];
    [self.view addSubview:userNameField];
    
    self.userNameField = userNameField;
}

@end
