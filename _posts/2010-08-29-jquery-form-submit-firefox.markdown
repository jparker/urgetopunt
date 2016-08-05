---
title: Creating and submitting forms with jQuery in Firefox
layout: post
categories: jquery firefox
---

There's an interesting gotcha when creating and submitting forms using
[jQuery](http://jquery.com/) in
[Firefox](http://www.mozilla.org/firefox/). Firefox silently fails to
submit forms that have not yet been attached to the DOM. For example,
consider the following scenario:

```javascript
$('a.destroy').click(function() {
  if (confirm("Blah blah blah...")) {
    var f = $('<form method="post" action="' + $(this).attr('href') + '"></form>');
    f.html('<input type="hidden" name="_method" value="delete" />');
    f.submit();
  }
  return false;
});
```

Clicking on a link with CSS class "destroy" in
[Safari](http://www.apple.com/safari/) or
[Chrome](http://www.google.com/chrome/) works as expected -- a form is
created and submitted. In Firefox, nothing seems to happen. To get it
working in Firefox, the form must be attached to the DOM, e.g., using
<code>appendTo()</code>:

```javascript
$('a.destroy').click(function() {
  if (confirm("Blah blah blah...")) {
    var f = $('<form method="post" action="' + $(this).attr('href') + '"></form>');
    f.html('<input type="hidden" name="_method" value="delete" />');
    f.appendTo($('body')); // required for submission to work in Firefox
    f.submit();
  }
  return false;
});
```

With the addition of <code>f.appendTo($('body'))</code>, clicking on a
link with CSS class "destroy" submits in Firefox (as well as Safari and
Chrome). I scratched my head on this for a while before stumbling across
[balpha's comment on the jQuery API documentation for
<code>submit()</code>](http://api.jquery.com/submit/#comment-45454172).
