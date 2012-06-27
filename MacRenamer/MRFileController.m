//
//  MRFileController.m
//  MacRenamer
//
//  Created by Gordon Fontenot on 6/27/12.
//  Copyright (c) 2012 Gordon Fontenot. All rights reserved.
//

#import "MRFileController.h"
#import "RegexKitLite.h"

@implementation MRFileController

- (id)init {
  files = [NSMutableArray new];
  
  return self;
}

- (NSInteger)count {
  return [files count];
}

- (NSDictionary *)fileForIndex:(NSInteger)index {
  return [files objectAtIndex:index];
}

- (void)addFile:(NSString *)rawFilePath {
  
  NSURL *fileURL = [NSURL URLWithString:rawFilePath];
  
  NSString *fileName = [fileURL lastPathComponent];
  NSString *filePath = rawFilePath;
  
  NSDictionary *file = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: fileName, filePath, nil] forKeys:[NSArray arrayWithObjects: @"name", @"path", nil]];

  if (![files containsObject:file]) {
    [files addObject:file];
  }
}

- (NSString *)modifiedFileNameForFileName:(NSString *)originalName atIndex:(NSInteger)index forRenameTab:(NSTabViewItem *)tabItem {
  
  NSArray *splitName = [originalName componentsSeparatedByString:@"."];
  
  NSString *baseFileName;
  NSString *fileExt;
  
  if ([splitName count] > 1) {
    baseFileName = [[splitName objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [splitName count] -1)]] componentsJoinedByString:@"."];
    fileExt = [NSString stringWithFormat: @".%@", [splitName objectAtIndex:[splitName count] -1]];
  }
  
  NSString *replacedFileName;
  
  if ([[tabItem identifier] isEqualToString:@"1"]) { // Rename
    replacedFileName = [self findAndReplaceRename:baseFileName forRenameTab:tabItem];
  } else {
    replacedFileName = [self numberRename:baseFileName forIndex:index andRenameTab:tabItem];
  }
  
  return [NSString stringWithFormat:@"%@%@", replacedFileName, fileExt];
}

- (NSString *)findAndReplaceRename:(NSString *)baseFileName forRenameTab:(NSTabViewItem *)tabItem {
  
  NSString *findText = [[[tabItem view] viewWithTag:100] stringValue];
  NSString *replaceText = [[[tabItem view] viewWithTag:101] stringValue];
  
  if ([findText isEqualToString:@""]) {
    return baseFileName;
  }
  
  NSString *replacedFileName;

  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useRegex"]) {
    replacedFileName = [baseFileName stringByReplacingOccurrencesOfRegex:findText withString:replaceText];
  } else {
    replacedFileName = [baseFileName stringByReplacingOccurrencesOfString:findText withString:replaceText];
  }
  
  return replacedFileName;
}

- (NSString *)numberRename:(NSString *)baseFileName forIndex:(NSInteger)index andRenameTab:(NSTabViewItem *)tabItem {
  NSInteger startNumber = [[[tabItem view] viewWithTag:100] integerValue];
  NSInteger stepValue = [[[tabItem view] viewWithTag:101] integerValue];
  NSInteger attachedNumber = (index * stepValue) + startNumber;
  
  NSString *attachedText = [[[tabItem view] viewWithTag:102] stringValue];
  
  if (!attachedText) {
    attachedText = @"";
  }
  
  NSString *formattedName;
  
  switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"numberRenameOption"]) {
    case 0: // original-text-number
      formattedName = [NSString stringWithFormat:@"%@%@%i", baseFileName, attachedText, attachedNumber];
      break;
    case 1: // number-text-original
      formattedName = [NSString stringWithFormat:@"%i%@%@", attachedNumber, attachedText, baseFileName];
      break;
    case 2: // text-number
      formattedName = [NSString stringWithFormat:@"%@%i", attachedText, attachedNumber];
      break;
    case 3: // number-text
      formattedName = [NSString stringWithFormat:@"%i%@", attachedNumber, attachedText];
      break;
    default:
      NSLog(@"Error! Should not be called! Option was %ld", [[NSUserDefaults standardUserDefaults] integerForKey:@"numberRenameOption"]);
      break;
  }
  return formattedName;
}

- (void)updateFileAtIndex:(NSInteger)index forName:(NSString *)newName andPath:(NSString *)newPath {
  
}

- (void)clear {
  
}



@end
