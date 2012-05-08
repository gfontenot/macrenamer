#
#  AppDelegate.rb
#  Renamer
#
#  Created by Gordon Fontenot on 5/7/12.
#  Copyright 2012 Gordon Fontenot. All rights reserved.
#

class AppDelegate
	attr_accessor :window
  attr_accessor :tableView
	def applicationDidFinishLaunching(a_notification)
		# Insert code here to initialize your application
	end
	
	def applicationShouldTerminateAfterLastWindowClosed(sender)
    true
  end
end

