Known Issues
============

These are the known issues with DTRichTextEditor.

Auto Layout
===========

- At this time DTRichTextEditor does not support auto layout. When using it in a storyboard that uses auto layout please disable auto layout for the editor view. It works fine, but some work is needed to add the necessary code to deal with the different way how subview frames are managed with auto layout.

Performance
===========

- On retina displays you might see the longer axis to be displayed in two steps. This is caused by `CATiledLayer` which limits the maximum tile size.

Spell Check
===========

- Not implemented, Sponsor wanted