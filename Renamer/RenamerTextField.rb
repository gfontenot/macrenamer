#
#  RenamerTextField.rb
#  Renamer
#
#  Created by Gordon Fontenot on 5/7/12.
#  Copyright 2012 WheelsTV. All rights reserved.
#


class RenamerTextField < NSTextField
  def textDidChange(notification)
    super
    delegate.textDidChange
  end
end