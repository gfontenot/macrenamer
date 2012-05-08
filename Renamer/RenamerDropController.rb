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
  attr_accessor :numberTabItem
  attr_accessor :findTextBox
  attr_accessor :replaceTextBox
  attr_accessor :regexCheckBox

  attr_writer :submit_button

  def awakeFromNib

    NSUserDefaults.standardUserDefaults.registerDefaults({useRegex: true})
    NSUserDefaults.standardUserDefaults.synchronize

    renamerTableView.registerForDraggedTypes([NSURLPboardType])
    regexCheckBox.state = NSUserDefaults.standardUserDefaults[:useRegex]
    @files = []
  end

  def modified_file_name_for_file(file_name)
    base_file_name, file_ext = file_name.split('.')

    if renamerTabView.selectedTabViewItem == findAndReplaceTabItem

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
    else
      replaced_file_name = "#{base_file_name}_NUMBER"
    end
    findTextBox.stringValue ? "#{replaced_file_name}.#{file_ext}" : file_name
  end

  def rename_files
    @files.each do |file|
      original_file_name = file[:name]
      original_file_path = file[:path].path
      new_file_name = modified_file_name_for_file(original_file_name)
      new_file_path = original_file_path.gsub(original_file_name, new_file_name)
      File.rename(original_file_path, new_file_path)

      file[:name] = new_file_name
      file[:path] = new_file_path
    end

    renamerTableView.reloadData

  end

  def textDidChange
    renamerTableView.reloadData
  end

  # NSTableViewDelegate

  def numberOfRowsInTableView(a_tableView)
    @files.count
  end

  def tableView(a_tableView, objectValueForTableColumn: aTableColumn, row: rowIndex)
    file = @files[rowIndex]
    aTableColumn == originalNameColumn ? file[:name] : modified_file_name_for_file(file[:name])
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
      @files << {name: file_url.lastPathComponent, path: file_url}
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

end