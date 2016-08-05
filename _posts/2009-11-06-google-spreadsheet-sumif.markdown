---
title: Better Conditional Sum in Google Spreadsheet
layout: post
categories: googledocs
---

In the [original
article](/googledocs/2009/05/09/google-spreadsheet-filter-sum.html) I
described using
<code>SUM()</code> and <code>FILTER()</code> in a [Google
Docs](http://docs.google.com/) spreadsheet to calculate the sum over a
subset of cells within a column. Turns out, there's a better way:

```
=SUMIF('Worksheet name'!E:E, "food", 'Worksheet name'!D:D)
```

In this version, the <code>SUMIF()</code> function combines the behavior of
the <code>SUM()</code> and <code>FILTER()</code> functions I was using before.
The first argument is the column to be compared to the filter value, the second
argument is the filter value itself (or the cell address containing the filter
value) and the third argument is the column over which the sum is to be
calculated. So in the above example, in column D of the worksheet named
"Worksheet name" all cells for which the corresponding cell in column E
contains the value "food" are selected, and the sum of those select cells is
returned.

In addition to being more succinct and easier to read, the use of
<code>SUMIF()</code> has the added benefit of returning <code>0</code> if there
are no rows matching the filter. Using <code>SUM()</code> and
<code>FILTER()</code> instead returns <code>#N/A</code>.
