Known Issues
============

These are the known issues with DTRichTextEditor.

Lists
=====

List support is incomplete. We recommend to not implement it at this time.

- need to prevent deletion of parts of list prefix
- selection is not properly preserved when toggling a paragraph between list and non-list
- paragraph space following a list is not preserved

We are looking for somebody to chip in so that we can finish this functionality.

Auto Layout
===========

- At this time DTRichTextEditor does not support auto layout. When using it in a storyboard that uses auto layout please disable auto layout for the editor view. It works fine, but some work is needed to add the necessary code to deal with the different way how subview frames are managed with auto layout.

Performance
===========

- On retina displays you might see the longer axis to be displayed in two steps. This is caused by `CATiledLayer` which limits the maximum tile size.
