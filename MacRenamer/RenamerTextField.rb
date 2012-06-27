#
#  MacRenamerTextField.rb
#  MacRenamer
#
#  Created by Gordon Fontenot on 5/7/12.
#  Copyright 2012 Gordon Fontenot. All rights reserved.
#


class MacRenamerTextField < NSTextField
  def textDidChange(notification)
    super
    delegate.ui_element_did_change(self)
  end
end