Version 1.2
- ADDED: dictation placeholder
- ADDED: setFont convenience method to set fontFamily and pointSize for default font
- FIXED: Loupe contents where not adjusted for Retina
- FIXED: Problems when Editor View being initialized with CGRectZero
- FIXED: Selection problem in readonly mode, words at line ends cannot be selected
- FIXED: Drag handles showing during readonly dragging
- FIXED: Default for shouldDrawLinks was defaulting to NO which would cause links to be invisible if not drawin in custom subview
- CHANGED: Refactored selectionRectsForRange: for RTL support and better performance
- CHANGED: DTMutableCoreTextLayoutFrame now caches selection rects for latest requested range
- CHANGED: Margin around edited text is now set via contentInset instead of content view's edgeInsets
- CHANGED: Adopted resizing contentSize through content view notification instead of KVO, since content views no longer resize themselves
- CHANGED: Prevent unnecessary re-layouting in several places (e.g. changing orientation)
- CHANGED: selectedTextRange now set to nil in resignFirstResponder
- CHANGED: textDefault and individual properties now set each other


Version 1.1.4
- FIXED: horizontal flickering when moving round loupe over text
- FIXED: cursor does not stop blinking during selection
- FIXED: see-through mode of loupe used when touch leaves visible content area
- FIXED: content size problem caused by DTCoreText change
- FIXED: avoid redrawing of loupe if in see-through mode
- CHANGED: restrict loupe towards bottom so that it does not go under keyboard
- CHANGED: loupe no goes into see-through mode if touch point goes outside of visible area
- CHANGED: renamed contentView to attributedTextContentView to avoid possible conflict with internal ivar of UIScrollView
- CHANGED: replaced semaphore-based sync with dispatch_queue
- CHANGED: improved performance on re-drawing so that only the area affected by the re-layouted lines is actually redrawn
- CHANGED: dragging a selection handle now also scrolls the view if the touch point moves outside of the visible area
- UPDATED: DTCoreText to 1.2.1

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