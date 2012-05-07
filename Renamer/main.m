//
//  main.m
//  Renamer
//
//  Created by Gordon Fontenot on 5/7/12.
//  Copyright (c) 2012 WheelsTV. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
	return macruby_main("rb_main.rb", argc, argv);
}
