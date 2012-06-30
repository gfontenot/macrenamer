//
//  MRFileController.h
//  MacRenamer
//
//  Created by Gordon Fontenot on 6/27/12.
//  Copyright (c) 2012 Gordon Fontenot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRFileController : NSObject {
  NSMutableArray *files;
}

- (NSInteger)count;
- (NSDictionary *)fileForIndex:(NSInteger)index;
- (void)addFile:(NSString *)rawFilePath;
- (NSString *)modifiedFileNameForFileName:(NSString *)originalName atIndex:(NSInteger)index forRenameTab:(NSTabViewItem *)tabItem;
- (void)updateFileAtIndex:(NSInteger)index forName:(NSString *)newName andPath:(NSString *)newPath;
- (void)clear;

// Forward Declarations (will delete)
- (NSString *)findAndReplaceRename:(NSString *)baseFileName forRenameTab:(NSTabViewItem *)tabItem;
- (NSString *)numberRename:(NSString *)baseFileName forIndex:(NSInteger)index andRenameTab:(NSTabViewItem *)tabItem;

@end
