//
//  AndScreenCapAppDelegate.h
//  AndScreenCap
//
//  Created by qihnus on 10/7/11.
//  Copyright (c) 2012 qihn.us. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AndScreenCapAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *destinationFolderTextField;

- (IBAction)captureScreen:(id)sender;
- (IBAction)chooseDestination:(id)sender;

@end
