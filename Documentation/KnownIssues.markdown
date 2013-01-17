Known Issues
============

These are the known issues with DTRichTextEditor.

Lists
=====

- need to prevent deletion of parts of list prefix
- selection is not properly preserved when toggling a paragraph between list and non-list
- paragraph space following a list is not preserved

HTML
====
- there is a bug in processing CSS that might cause a large document to lose all paragraphs. (This causes performance problems layouting since always all affected paragraphs are re-layouted when replacing substrings)

Performance
===========
- instead of just the changed region always the entire content view area is dirtied causing slow redrawing on long documents