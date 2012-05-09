#
#  FileController.rb
#  Renamer
#
#  Created by Gordon Fontenot on 5/9/12.
#  Copyright 2012 Gordon Fontenot. All rights reserved.
#


class FileController
  attr_accessor :files

  def initialize
    @files = []
  end

  def add_file(file_url)

    if file_url.class == String
      file_url = NSURL.fileURLWithPath(file_url) 
    end

    file = {name: file_url.lastPathComponent, path: file_url.path}

    @files << file unless @files.include? file
  end

  def delete_file_at(index)
    @files.delete_at(index)
  end

  def clear
    @files.clear
  end

  def rename_files
    @files.each_with_index do |file, index|
      original_file_name = file[:name]
      original_file_path = file[:path]
      new_file_name = modified_file_name(original_file_name, index)
      new_file_path = original_file_path.gsub(original_file_name, new_file_name)
      File.rename(original_file_path, new_file_path)

      file[:name] = new_file_name
      file[:path] = new_file_path
    end
    renamerTableView.reloadData
  end

  def modified_file_name(file_name, index, sender)
    base_file_name, file_ext = file_name.split('.')
    replaced_file_name = if sender.renamerTabView.selectedTabViewItem == sender.findAndReplaceTabItem
      regex_rename(file_name, base_file_name, sender)
    else
      number_rename(file_name, base_file_name, index, sender)
    end
    "#{replaced_file_name}.#{file_ext}"
  end

  def regex_rename(file_name, base_file_name, sender)

    find_text = sender.findTextBox.stringValue
    replace_text = sender.replaceTextBox.stringValue

    return base_file_name if find_text == ""
    case NSUserDefaults.standardUserDefaults[:useRegex]
    when true
      begin
        replaced_file_name = base_file_name.gsub(/#{find_text}/i, replace_text)
      rescue
        replaced_file_name = base_file_name
      end
    else
      replaced_file_name = base_file_name.gsub(find_text, replace_text)
    end
  end

  def number_rename(file_name, base_file_name, index)
    attached_text = sender.numberAttachTextField.stringValue
    attached_number = (index * sender.numberStepValue + sender.numberStartValue).to_i
    case sender.numberRenameFormatPicker.indexOfSelectedItem
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
end