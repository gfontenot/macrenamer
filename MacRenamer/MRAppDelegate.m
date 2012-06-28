//
//  MRAppDelegate.m
//  MacRenamer
//
//  Created by Gordon Fontenot on 6/27/12.
//  Copyright (c) 2012 Gordon Fontenot. All rights reserved.
//

#import "MRAppDelegate.h"
#import "MRFileController.h"

@implementation MRAppDelegate

@synthesize window = _window;
@synthesize numberStartValue, numberStepValue;
@synthesize fileController;

- (id)init {
  [super init];
  self.fileController = [MRFileController new];
  self.numberStartValue = 1;
  self.numberStepValue = 1;
  
  return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [defaults registerDefaults:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"YES", @"0", nil] forKeys:[NSArray arrayWithObjects:@"useRegex", @"numberRenameOption", nil]]];
  [defaults synchronize];
  
  [_tableView registerForDraggedTypes:[NSArray arrayWithObjects:NSURLPboardType, nil]];
  
  [regexCheckBox setState:[defaults integerForKey:@"useRegex"]];
  [numberRenameFormatPicker selectItemAtIndex:[defaults integerForKey:@"numberRenameOption"]];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
  return YES;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filePath {
  NSLog(@"DROP");
  [self.fileController addFile:filePath];
  [_tableView reloadData];
  return YES;
}

- (void)renameFiles {
  [progressBar setDoubleValue:0];
  [progressBar setUsesThreadedAnimation:YES];
  [progressBar setMaxValue:[self.fileController count]];
  
  [NSApp beginSheet:progressSheet modalForWindow:_window modalDelegate:self didEndSelector:nil contextInfo:nil];
  
  BOOL conflicts = NO;
  
  for (NSInteger i = 0; i < [self.fileController count]; i++) {
    NSDictionary *file = [self.fileController fileForIndex:i];
    NSString *originalFileName = [file objectForKey:@"name"];
    NSString *originalFilePath = [file objectForKey:@"path"];
    
    NSString *newFileName = [self.fileController modifiedFileNameForFileName:originalFileName atIndex:i forRenameTab:[tabView selectedTabViewItem]];
    NSString *newFilePath = [originalFilePath stringByReplacingOccurrencesOfString:originalFileName withString:newFileName];
    
    if (originalFileName != newFileName) {
      if ([[NSFileManager defaultManager] fileExistsAtPath:newFilePath]) {
        conflicts = YES;
      } else {

        if ([[NSFileManager defaultManager] fileExistsAtPath:originalFilePath]) {
          NSLog(@"Original file exists");
        }

        NSError *error = nil;
        if ([[NSFileManager defaultManager] moveItemAtPath:originalFilePath toPath:newFilePath error:&error]) {
          NSLog(@"Move successful");
        } else {
          conflicts= YES; // For right now, set conflicts to yes.
          NSLog(@"%@", error);
        }
        [fileController updateFileAtIndex:i forName:newFileName andPath:newFilePath];
      }
      [progressBar incrementBy:1];
    }
    
    [NSApp endSheet:progressSheet];
    [progressSheet orderOut:self];
    
    if (conflicts) {
      NSAlert *conflictsAlert = [NSAlert new];
      [conflictsAlert addButtonWithTitle:@"OK"];
      [conflictsAlert setMessageText:@"Some file not renames!"];
      [conflictsAlert setInformativeText:@"Some files could not be renamed due to a conflict.\nPlease check the files and try again"];
      [conflictsAlert setAlertStyle:NSWarningAlertStyle];
      [conflictsAlert beginSheetModalForWindow:_window modalDelegate:self didEndSelector:nil contextInfo:nil];
    }
  }
  [_tableView reloadData];
}

#pragma mark - NSTableViewDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return [self.fileController count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  NSDictionary *file = [self.fileController fileForIndex:row];
  return (tableColumn == originalNameColumn) ? [file objectForKey:@"name"] : [fileController modifiedFileNameForFileName:[file objectForKey:@"name"] atIndex:row forRenameTab:[tabView selectedTabViewItem]];
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
  [_tableView setDropRow:-1 dropOperation:NSTableViewDropOn];
  return NSDragOperationEvery;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
//  (row < 0) ? row = 0 : row = row;
  
  NSDictionary *options = [NSDictionary new];
  NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
  
  NSArray *droppedFiles = [[info draggingPasteboard] readObjectsForClasses:classes options:options];
  
  if ([droppedFiles count] == 0) {
    return NO;
  }
  
  for (NSString *fileURL in droppedFiles) {
    [fileController addFile:[NSString stringWithFormat:@"%@", fileURL]];
  }
  
  [_tableView reloadData];
  return YES;
}

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem {
  [_tableView reloadData];
}

#pragma mark - Button actions

- (IBAction)submit:(id)sender {
  [self renameFiles];
}

- (IBAction)checkboxToggle:(id)sender {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [defaults setBool:[regexCheckBox state] forKey:@"useRegex"];
  [defaults synchronize];
  
  [_tableView reloadData];
}

- (IBAction)numberOptionChanged:(id)sender {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [defaults setInteger:[numberRenameFormatPicker indexOfSelectedItem] forKey:@"numberRenameOption"];
  [defaults synchronize];
  
  [_tableView reloadData];
}

- (IBAction)clearList:(id)sender {
  [fileController clear];
  [_tableView reloadData];
}

- (IBAction)uiElementDidChange:(id)sender {
  [_tableView reloadData];
}

@end