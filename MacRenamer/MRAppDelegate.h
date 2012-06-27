//
//  MRAppDelegate.h
//  MacRenamer
//
//  Created by Gordon Fontenot on 6/27/12.
//  Copyright (c) 2012 Gordon Fontenot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MRFileController;

@interface MRAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource, NSTabViewDelegate> {
  
  IBOutlet NSTableView *_tableView;

  IBOutlet NSTableColumn *originalNameColumn;
  IBOutlet NSTableColumn *modifiedNameColumn;

  IBOutlet NSTabView *tabView;

  IBOutlet NSTabViewItem *findAndReplaceTabItem;
  IBOutlet NSTextField *findTextBox;
  IBOutlet NSTextField *replaceTextBox;
  IBOutlet NSButton *regexCheckBox;

  IBOutlet NSTabViewItem *numberTabItem;
  IBOutlet NSTextField *numberAttachTextField;
  IBOutlet NSPopUpButton *numberRenameFormatPicker;

  IBOutlet NSWindow *progressSheet;
  IBOutlet NSProgressIndicator *progressBar;
  
}

@property (assign) IBOutlet NSWindow *window;

@property (assign) NSInteger numberStartValue;
@property (assign) NSInteger numberStepValue;
@property (nonatomic) MRFileController *fileController;

- (IBAction)submit:(id)sender;
- (IBAction)checkboxToggle:(id)sender;
- (IBAction)numberOptionChanged:(id)sender;
- (IBAction)clearList:(id)sender;
- (IBAction)uiElementDidChange:(id)sender;

@end
