---
title: Conditional Sum in Google Spreadsheet
layout: post
categories: googledocs
---

It's the simplest things I always forget. Hopefully I'll remember this
article next time. When traveling to a conference I record and
categorize my expenses in a [Google Docs](http://docs.google.com/)
spreadsheet, usually creating a new worksheet for each trip. I have a
separate worksheet which contains a cumulative summary of each category
of expense. This is the formula I use to keep the running total for
specific categories.

```
=SUM(FILTER('Worsheet name'!D2:D; 'Worksheet name'!E2:E="food"))
```

The SUM function is self-explanatory. The FILTER function selects all
cells from a given range which match particular conditions. The range of
cells to choose from is the first argument. Subsequent arguments
describe the conditions. In the above example we select all cells from
column D from row 2 onwards for which the value of the corresponding
cell in column E equals "food".

**UPDATE**: As is so often the case when I learn something, there is a
[better way](/googledocs/2009/11/06/google-spreadsheet-sumif.html).
