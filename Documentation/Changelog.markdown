Version 1.0.2

- FIXED: copying multiple local attachments would cause them to all turn into the last image on pasting. A local attachment is one that has contents, but no contentURL so this is represented as HTML DATA URL and does not require an additional DTWebResource in the pastboard.
- FIXED: issue #127, position of inserted autocorrection text when dismissing keyboard.
- FIXED: Changed DTLoupeView to using 4 layers instead of drawRect. This fixes a display bug when moving the loupe to far to the right or down.