//
//  Framework_iOSAppDelegate.h
//  Framework-iOS
//
//  Created by Diney Bomfim on 4/30/11.
//  Copyright 2011 DB-Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FI/FI.h>

@class Framework_iOSViewController;

@interface Framework_iOSAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet Framework_iOSViewController *viewController;

@end
