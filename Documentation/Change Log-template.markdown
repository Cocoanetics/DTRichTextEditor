Change Log
==========

This is the history of version updates.

Version 1.6.7

- ADDED: Support for tintColor on >= iOS 7
- FIXED: iOS 8 crash
- FIXED: Image text attachments missing from HTML output
- CHANGED: Updated DTCoreText to 1.6.13

Version 1.6.6

- CHANGED: Updated DTLoupe to 1.5.4
- CHANGED: Updated DTCoreText to 1.6.10
- CHANGED: Updated DTFoundation to 1.6.1

Version 1.6.5

- ADDED: support for arm64
- FIXED: Hyperlink would continue to be extended when typing right of it
- FIXED: Text get corrupted during Dictation on iOS 7
- FIXED: Setting the attributed text to nil would not remove selection
- CHANGED: Updated DTCoreText to 1.6.9
- CHANGED: Updated DTFoundation to 1.6.0

Version 1.6.4

- FIXED: Backwards deleting of list prefixes broken due to a change in iOS 7
- FIXED: A crash might occur if editing text while drawing of tiles was still going on
- ADDED: Adjust bottom contentInset to avoid cutting of autocorrect prompt
- CHANGED: Updated DTCoreText to 1.6.8

Version 1.6.3

- FIXED: Pasting from Google Drive might yield empty content
- CHANGED: Updated DTCoreText to 1.6.6

Version 1.6.2

- FIXED: Removed unnecessary test that would prevent redrawing for "empty" contents
- FIXED: Tapping on editor would cause incorrect scrolling on long documents if the editor was not first reponder
- CHANGED: Updated DTCoreText to 1.6.3

Version 1.6.1

- FIXED: Pasted plain text missing typing attributes
- ADDED: DTProcessCustomHTMLAttributes in Demo App parsing options
- CHANGED: Processing of Custom HTML Attributes is now optional and defaults to off.
- CHANGED: Updated DTCoreText to 1.6.1

Version 1.6.0

- FIXED: Multi-stage text input had issues with input delegate messaging
- ADDED: Support for custom HTML attributes
- ADDED: Delegate method for finer control over pasted content.
- ADDED: More formatting options in Demo app
- CHANGED: Updated DTCoreText to 1.6.0

Version 1.5.1

- FIXED: Crash on hitting enter key on empty list item right after parsing
- FIXED: Scroll Indicator inset incorrectly
- FIXED: Changing typing attributes inside a list would not be preserved on Enter key
- FIXED: Pasting an image attribute now uses registered DTTextAttachment subclass for IMG tag
- ADDED: Support for Define context menu option to show dictionary
- CHANGED: Updated DTCoreText to 1.5.3

Version 1.5

- ADDED: Implemented Support for Ordered and Unordered Lists, editable 1 level
- CHANGED: Improved handling of nested lists
- ADDED: Method to set text color for range
- ADDED: Method to set strikethrough style for range
- ADDED: HTMLStringWithOptions methods
- ADDED: Ability to animate between input views (custom keyboards)
- FIXED: style information would not obey custom CSS stylesheet in textDefaults
- CHANGED: editing delegate now uses editorView:shouldChangeTextInRange:replacementText: for image pasting
- ADDED: [DEMO] Formatting View Controller, shown as popover on iPad and input view on iPhone

Version 1.4.1

- FIXED: Editor delegate set an out of bounds range when deleting backwards with a selection which starts from position 0. 
- UPDATED: DTCoreText to 1.4.3
- FIXED: Synthesizing italics for fonts that don't have italic face. e.g. American Typewriter

Version 1.4

- ADDED: A delegation protocol that gives it feature parity with UITextView.
- FIXED: override typing attributes (like setting bold with no selection) would be reset on a new line
- FIXED: Autocorrection was broken due to removal of input delegate notification
- FIXED: Some problems with Undo
- FIXED: In some circumstances Editor view would scroll horizontally
- FIXED: Apps using multiple instances of Editor would have Undo problems
- UPDATED: DTCoreText to 1.4

Version 1.3

- NO CHANGES: This is an interim version since we want to have the version number catch up to DTCoreText. Also this is the first tagged version on our git server.

Version 1.2.3

- FIXED: inParagraph being ignored in replaceRange:withAttachment:inParagraph:

Version 1.2.2

- CHANGED: Scaling for ranged selection loupe is now being calculated from the caret size
- FIXED: This removed the synchronization by queue and replaced it with @synchronized as this was causing display problems
- FIXED: Encoding of Emoji multi-byte unicode sequences
- CHANGED: Updated to DTCoreText 1.3.2

Version 1.2.1

- FIXED: Too large documents would cause editor to go black. Changed content layer to tiled for fix.
- FIXED: Making incremental changes right after setting string would cause incorrect content view height (e.g. contents in loupe be invisible)
- FIXED: Use default font size from textDefaults if typingAttributes are missing a font attribute
- REMOVED: defunct debug crosshairs functionality which stopped working when loupe was change to be layer-based


Version 1.2

- ADDED: dictation placeholder
- ADDED: setFont convenience method to set fontFamily and pointSize for default font
- FIXED: Loupe contents where not adjusted for Retina
- FIXED: Problems when Editor View being initialized with CGRectZero
- FIXED: Selection problem in readonly mode, words at line ends cannot be selected
- FIXED: Drag handles showing during readonly dragging
- FIXED: Default for shouldDrawLinks was defaulting to NO which would cause links to be invisible if not drawin in custom subview
- FIXED: Parser did not add font attribute to empty paragraph, causing smaller carets for these lines
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
