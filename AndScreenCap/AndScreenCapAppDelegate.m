//
//  AndScreenCapAppDelegate.m
//  AndScreenCap
//
//  Created by qihnus on 10/7/11.
//  Copyright (c) 2012 qihn.us. All rights reserved.
//

#import "AndScreenCapAppDelegate.h"

@implementation AndScreenCapAppDelegate

@synthesize window, destinationFolderTextField;

NSString *const DEST_DIR = @"dest_dir";

NSString *resultFilePath;

- (NSString *)getDatetimeString
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    return currentTime;
}

- (NSString *)getOutputFileName
{
    return [NSString stringWithFormat:@"Screenshot - %@.png", [self getDatetimeString]];
}

- (NSString *)getDesktopPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (void)revealInFinder:(NSString *)fileName
{
    NSLog(@"opening %@", fileName);
    [[NSWorkspace sharedWorkspace] selectFile:fileName inFileViewerRootedAtPath:[fileName stringByDeletingLastPathComponent]];
}

- (IBAction)chooseDestination:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    // TODO: be able to create a new folder
    NSInteger button = [panel runModal];
    if (button == NSOKButton) {
        NSString *destPath = [[[panel URLs] objectAtIndex:0] path];
        [[NSUserDefaults standardUserDefaults] setValue:destPath forKey:DEST_DIR];
        [destinationFolderTextField setStringValue:destPath];
    }
}

- (void)showError:(NSString *)msg
{
    NSRunAlertPanel(@"Error", msg, @"OK", nil, nil);
}

- (void)processResult
{
    [self revealInFinder:resultFilePath];
}

- (void)checkTaskStatus:(NSNotification *)aNotification
{
    int status = [[aNotification object] terminationStatus];
    if (status == 0) {
        NSLog(@"Task succeeded.");
        [self processResult];
    } else {
        NSLog(@"Task failed.");
        [self showError:@"Cannot capture. Do you have your device connected?"];
    }
}

- (void)runTask:(NSString *)cmd withArgs:(NSArray *)args inDir:(NSString *)dir
{
    NSTask *task = [[NSTask alloc] init];
    [task setCurrentDirectoryPath:dir];
    [task setLaunchPath:cmd];
    [task setArguments:args];

    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    [task setStandardInput:[NSPipe pipe]];

    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    NSData *data = [file readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"cmd returned:\n%@", output);
}

- (IBAction)captureScreen:(id)sender
{
    NSString *cmd = [[NSBundle mainBundle] pathForResource:@"screenshot2" ofType:nil];
    NSLog(@"%@", cmd);

    NSMutableArray *args = [NSMutableArray array];
    [args addObject:[self getOutputFileName]];

    NSString *path = [destinationFolderTextField stringValue];
    resultFilePath = [path stringByAppendingPathComponent:[self getOutputFileName]];

    [self runTask:cmd withArgs:args inDir:path];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTaskStatus:) name:NSTaskDidTerminateNotification object:nil];
    NSString *destPath = [[NSUserDefaults standardUserDefaults] valueForKey:DEST_DIR];
    if (destPath == nil) {
        destPath = [self getDesktopPath];
    }
    [destinationFolderTextField setStringValue:destPath];
}

@end
