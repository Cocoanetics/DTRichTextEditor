
Version 1.0.4

- FIXED: toggleHighlightInRange has Yellow hard-coded.
- ADDED: passing nil to toggleHighlightInRange does not try to add a color
- FIXED: hasText reports YES even if only content is the default \n 
- ADDED: implemented delete: for sake of completeness
- CHANGED: moved isEditable from category to main implementation to quench warning
- CHANGED: implemented DTTextSelectionRect and cleaned up selection handling to fix warning

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