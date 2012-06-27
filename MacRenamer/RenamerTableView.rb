#
#  MacRenamerDropController.rb
#  MacRenamer
#
#  Created by Gordon Fontenot on 05/08/12.
#  Copyright 2012 Gordon Fontenot. All rights reserved.
#

class MacRenamerTableView < NSTableView

  def keyDown(theEvent)
    key = theEvent.charactersIgnoringModifiers.characterAtIndex(0)
    if (key == NSDeleteCharacter) 
      delegate.deleteItemAtIndex(self.selectedRow)
    end
  end

end