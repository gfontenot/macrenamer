#
#  AppDelegate.rb
#  Renamer
#
#  Created by Gordon Fontenot on 5/7/12.
#  Copyright 2012 Gordon Fontenot. All rights reserved.
#

class AppDelegate
	attr_accessor :window

  attr_accessor :renamerTableView
  attr_accessor :originalNameColumn
  attr_accessor :modifiedNameColumn

  attr_accessor :renamerTabView

  attr_accessor :findAndReplaceTabItem
  attr_accessor :findTextBox
  attr_accessor :replaceTextBox
  attr_accessor :regexCheckBox

  attr_accessor :numberTabItem
  attr_accessor :numberStartValue
  attr_accessor :numberStepValue
  attr_accessor :numberAttachTextField
  attr_accessor :numberRenameFormatPicker

  attr_accessor :progressSheet
  attr_accessor :progressBar

  def initialize
    @fileController = FileController.new
    @numberStartValue = 1
    @numberStepValue = 1
  end

	def applicationDidFinishLaunching(a_notification)
	  NSUserDefaults.standardUserDefaults.registerDefaults({useRegex: true, numberRenameOption: 0})
    NSUserDefaults.standardUserDefaults.synchronize

    renamerTableView.registerForDraggedTypes([NSURLPboardType])
    regexCheckBox.state = NSUserDefaults.standardUserDefaults[:useRegex]
    numberRenameFormatPicker.selectItemAtIndex(NSUserDefaults.standardUserDefaults[:numberRenameOption])
	end
	
	def applicationShouldTerminateAfterLastWindowClosed(sender)
    true
  end

  def application(application, openFile: file)
    @fileController.add_file(file)
    renamerTableView.reloadData
    true
  end

  def rename_files

    progressBar.doubleValue = 0
    progressBar.usesThreadedAnimation = true
    progressBar.maxValue = @fileController.files.count

    NSApp.beginSheet(progressSheet, modalForWindow:window, modalDelegate: self, didEndSelector: nil, contextInfo: nil)

    conflicts = false
    @fileController.files.each_with_index do |file, index|
      original_file_name = file[:name]
      original_file_path = file[:path]
      new_file_name = @fileController.modified_file_name(original_file_name, index, self)
      new_file_path = original_file_path.gsub(original_file_name, new_file_name)

      unless original_file_name == new_file_name
        if File.exists?(new_file_path)
          puts "File Exists! #{new_file_name}"
          conflicts = true
        else
          File.rename(original_file_path, new_file_path)
          file[:name] = new_file_name
          file[:path] = new_file_path
        end
        progressBar.incrementBy(1)
      end

      NSApp.endSheet(progressSheet)
      progressSheet.orderOut(self)

      if conflicts
        alert = NSAlert.new
        alert.addButtonWithTitle("OK")
        alert.setMessageText("Some files not renamed!")
        alert.setInformativeText("Some files could not be renamed due to a conflict.\nPlease check the files and try again")
        alert.setAlertStyle(NSWarningAlertStyle)
        alert.beginSheetModalForWindow(window, modalDelegate: self, didEndSelector:nil, contextInfo:nil)
      end
    end

    renamerTableView.reloadData
  end

  # NSTableViewDelegate

  def numberOfRowsInTableView(a_tableView)
    @fileController.files.count
  end

  def tableView(a_tableView, objectValueForTableColumn: aTableColumn, row: rowIndex)
    file = @fileController.files[rowIndex]
    aTableColumn == originalNameColumn ? file[:name] : @fileController.modified_file_name(file[:name], rowIndex, self)
  end

  def tableView(a_tableView, validateDrop: info, proposedRow: row, proposedDropOperation: operation)
    renamerTableView.setDropRow(-1, dropOperation: NSTableViewDropOn)
    NSDragOperationEvery
  end

  def tableView(a_tableView, acceptDrop: info, row: row, dropOperation: operation)
    row = 0 if row < 0
    options = {}
    classes = [NSURL]
    dropped_files = info.draggingPasteboard.readObjectsForClasses(classes, options: options)
    return false unless dropped_files

    dropped_files.each do |file_url|
      @fileController.add_file(file_url)
    end

    renamerTableView.reloadData
  end

  def deleteItemAtIndex(index)
    @fileController.delete_file_at(index)
    renamerTableView.reloadData
  end

  # NSTabViewDelegate

  def tabView(a_tabView, willSelectTabViewItem: tabViewItem)
    renamerTableView.reloadData
  end

  #  Buttons 

  def submit(sender)
    rename_files
  end

  def checkboxToggle(sender)
    NSUserDefaults.standardUserDefaults[:useRegex] = regexCheckBox.state.boolValue
    NSUserDefaults.standardUserDefaults.synchronize 
    renamerTableView.reloadData
  end

  def numberOptionChanged(sender)
    NSUserDefaults.standardUserDefaults[:numberRenameOption] = numberRenameFormatPicker.indexOfSelectedItem
    NSUserDefaults.standardUserDefaults.synchronize 
    renamerTableView.reloadData
  end

  def clear_list(sender)
    @fileController.clear
    renamerTableView.reloadData
  end

  def ui_element_did_change(sender)
    renamerTableView.reloadData
  end
end

