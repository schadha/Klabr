//
//  AppDelegate.h
//  Klabr
//
//  Created by Sanchit Chadha on 3/30/14.
//  Copyright (c) 2014 Sanchit Chadha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *SERVER_IP;
@property (strong, nonatomic) NSString *PORT;
@property (strong, nonatomic) NSDictionary *userData;

@end
