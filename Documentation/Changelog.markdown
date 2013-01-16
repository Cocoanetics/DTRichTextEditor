Version 1.1.3
- FIXED: Cursor would not show when becoming first responder
- FIXED: Loupe would flash in top left corner when being presented the first time
- ADDED: Known Issues file with warning not to use lists (incomplete)
- CHANGED: refactored and made public boundsOfCurrentSelection method

Version 1.1.2
- FIXED: Crash when dragging beyond end of document with keyboard hidden
- FIXED: Selection rectangles did not get correctly extended for RTL text
- UPDATED: DTCoreText Fixes

Version 1.1.1
- UPDATED: DTCoreText to Version 1.1
- FIXED: Hopefully a certain crash involving Undo

Version 1.1.0
- ADDED: Support for Undo/Redo
- ADDED: Setting and changing font family and size for ranges
- ADDED: Support for indenting
- CHANGED: Lots of documentation added, refactoring and cleanup
- FIXED: text scaling bug when pasting
- UPDATED: DTCoreText + DTFoundation submodule

Version 1.0.7
- FIXED: Crash when selection goes beyond a paragraph, somehow left over from 1.0.6

Version 1.0.6
- FIXED: Crash when selection ends at beginning of line (introduced in 1.0.5)
- CHANGED: Removed unnecessary logging of pasteboard types on paste
- FIXED: Hitting backspace with cursor right of an Emoji would only delete half of the composed character sequence resulting in an extra glyph showing up

Version 1.0.5
- FIXED: Crash when dismissing modal view controller after loupe was shown once
- CHANGED: Loupe is now a singleton with a dedicated UIWindow
- FIXED: background-color attribute is no longer inherited from non-inline parent tag

Version 1.0.4

- FIXED: toggleHighlightInRange has Yellow hard-coded.
- ADDED: passing nil to toggleHighlightInRange does not try to add a color
- FIXED: hasText reports YES even if only content is the default \n 
- ADDED: implemented delete: for sake of completeness
- CHANGED: moved isEditable from category to main implementation to quench warning
- CHANGED: implemented DTTextSelectionRect and cleaned up selection handling to fix warning
- FIXED:  crash when pasting web content from Safari into the editor

Version 1.0.3

- FIXED: Without Keyboard drag handles should still appear to allow modifying selection for e.g. copy
- ADDED: methods to toggle highlighting on NSAttributedString, option "H" in Demo demonstrating this
- CHANGED: textDefaults is now a writeable property. For possible values see <DTHTMLAttributedStringBuilder>

Version 1.0.2

- FIXED: copying multiple local attachments would cause them to all turn into the last image on pasting. A local attachment is one that has contents, but no contentURL so this is represented as HTML DATA URL and does not require an additional DTWebResource in the pastboard.
- FIXED: issue #127, position of inserted autocorrection text when dismissing keyboard.
- FIXED: Changed DTLoupeView to using 4 layers instead of drawRect. This fixes a display bug when moving the loupe to far to the right or down.
- FIXED: Issue #464 through the internal change to DTLoupeView
- FIXED: Cursor not showing up on programmatic becomeFirstResponder (knock on effect from fixing #127)