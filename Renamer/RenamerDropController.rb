#
#  RenamerDropController.rb
#  Renamer
#
#  Created by Gordon Fontenot on 5/7/12.
#  Copyright 2012 Gordon Fontenot. All rights reserved.
#


class RenamerDropController
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

  def initialize
    self.numberStartValue = 1
    self.numberStepValue = 1
    self
  end

  def awakeFromNib
    NSUserDefaults.standardUserDefaults.registerDefaults({useRegex: true})
    NSUserDefaults.standardUserDefaults.synchronize

    renamerTableView.registerForDraggedTypes([NSURLPboardType])
    regexCheckBox.state = NSUserDefaults.standardUserDefaults[:useRegex]
    @files = []
  end

  def modified_file_name_for_file(file_name, index)
    base_file_name, file_ext = file_name.split('.')

    replaced_file_name = if renamerTabView.selectedTabViewItem == findAndReplaceTabItem
      regex_rename(file_name, base_file_name)
    else
      number_rename(file_name, base_file_name, index)
    end
    findTextBox.stringValue ? "#{replaced_file_name}.#{file_ext}" : file_name
  end

  def rename_files
    @files.each_with_index do |file, index|
      original_file_name = file[:name]
      original_file_path = file[:path]
      new_file_name = modified_file_name_for_file(original_file_name, index)
      new_file_path = original_file_path.gsub(original_file_name, new_file_name)
      File.rename(original_file_path, new_file_path)

      file[:name] = new_file_name
      file[:path] = new_file_path
    end
    renamerTableView.reloadData
  end

  def regex_rename(file_name, base_file_name)
    return file_name if findTextBox.stringValue == ""
    case regexCheckBox.state
    when NSOnState
      begin
        replaced_file_name = base_file_name.gsub(/#{findTextBox.stringValue}/i, replaceTextBox.stringValue)
      rescue
        replaced_file_name = base_file_name
      end
    else
      replaced_file_name = base_file_name.gsub(findTextBox.stringValue, replaceTextBox.stringValue)
    end
  end

  def number_rename(file_name, base_file_name, index)

    attached_text = numberAttachTextField.stringValue
    attached_number = (index * numberStepValue + numberStartValue).to_i
    case numberRenameFormatPicker.indexOfSelectedItem
    when 0 # original-text-number
      "#{base_file_name}#{attached_text}#{attached_number}"
    when 1 # number-text-original
      "#{attached_number}#{attached_text}#{base_file_name}"
    when 2 # text-number
      "#{attached_text}#{attached_number}"
    when 3 # number-text
      "#{attached_number}#{attached_text}"
    end
  end

  # NSTableViewDelegate

  def numberOfRowsInTableView(a_tableView)
    @files.count
  end

  def tableView(a_tableView, objectValueForTableColumn: aTableColumn, row: rowIndex)
    file = @files[rowIndex]
    aTableColumn == originalNameColumn ? file[:name] : modified_file_name_for_file(file[:name], rowIndex)
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
      add_file(file_url)
    end

    renamerTableView.reloadData
  end

  def deleteItemAtIndex(index)
    @files.delete_at(index)
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

  def clear_list(sender)
    @files.clear
    renamerTableView.reloadData
  end

  def ui_element_did_change(sender)
    renamerTableView.reloadData
  end

  public

  def add_file(file_url)
    if file_url.class == String
      file_url = NSURL.fileURLWithPath(file_url) 
    end
    @files << {name: file_url.lastPathComponent, path: file_url.path}
  end
end