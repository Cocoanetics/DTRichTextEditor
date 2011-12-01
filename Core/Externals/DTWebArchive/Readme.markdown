# DTWebArchive

Safari uses the WebKit class WebArchive to transfer rich data from e.g. Safari. This project aims to give you the capability of accepting such pasteboard data in your apps. WebArchive and the related WebRessource classes are tightly coubled with WebKit and private. This project is a reverse-engineered class giving you the same functionality on iOS.

For example you could allow your users to copy something from a web page and paste it into your app preserving the formatting.

I put this into it's own GitHub project instead of adding it to NSAttributedString+HTML because it might be useful for you even if you don't dabble in CoreText with HTML.

To use it, just copy the contents of the Core folder to your project.

Follow [@cocoanetics](http://twitter.com/cocoanetics) on Twitter.

KNOWN ISSUES

- There might be a different kind of representation of WebArchives besides a binary plist, namely archived with an NSKeyedArchiver. If you ever encounter that, let me know.
