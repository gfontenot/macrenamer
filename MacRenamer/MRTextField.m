//
//  MRTextField.m
//  MacRenamer
//
//  Created by Gordon Fontenot on 6/27/12.
//  Copyright (c) 2012 Gordon Fontenot. All rights reserved.
//

#import "MRTextField.h"
#import "MRAppDelegate.h"

@implementation MRTextField

- (void)textDidChange:(NSNotification *)aNotification {
  [super textDidChange:aNotification];
  [(MRAppDelegate *)self.delegate uiElementDidChange:(self)];
}

@end
