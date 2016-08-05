---
title: Refactoring Views for Clarity
layout: post
---

I recently found myself doing some work on the views of an application I
developed more than 18 months ago. As seems so often the case when
looking at something I wrote long ago, I found myself somewhat
dissatisfied with the way some of the code had been written. The
partials I was looking at were DRY but long. In Ruby I've learned to
extoll the virtues of shorter, more focused methods, and in Rails, by
extension, I think these same virtues apply to smaller, more focused
views.

The controller I was working on handled the usual [RESTful
actions](http://api.rubyonrails.org/classes/ActionController/Resources.html#M000501)
for a resource named <tt>billable</tt>, but in addition to the usual
suspects, the billable resource also had several custom collection
actions named <code>day</code>, <code>week</code> and
<code>month</code>. As you might guess from their names, they returned
collections of billables by day, week and month, respectively. The base
views were simple -- they displayed a title and rendered a
<tt>_billables</tt> partial which displayed a table summarizing the
collection. The <tt>_billables</tt> partial was my primary concern
as it had grown too long. (See the original code [below](#before)).

I decided to address the problem breaking the <tt>_billables</tt>
partial up. I created <tt>_head</tt> and <tt>_foot</tt>
partials to display the header and footer sections of the table, and I
created a <tt>_billable</tt> (singular) partial which displayed a
row for individual billables. I opted to shed some of the original
approach's DRYness by replacing the one call to <code>#render</code> in
each view with two calls for the <tt>_head</tt> and
<tt>_foot</tt> partials and a third call for the
<tt>_billable</tt> partial for the entire collection. (See these
changes [below](#after)).

While I am not necessarily wed to the details of this new approach, I do
think the result is a net gain. There are more files, more lines of code
and there's more duplication. But I believe everything is clearer. I
also believe the duplication I've added is unlikely to add maintenance
headaches -- it's hard to imagine it changing in any way that wouldn't
require significant updates with or without the duplication. (As long as
I am using a table to display the collection, I will have a header,
footer and main body).

<a name="before"></a>These are the partials I started with:

```erb
<!-- day.html.erb -->
<h1>Billables | Daily</h1>
<%= render :partial => 'billables' %>

<!-- week.html.erb -->
<h1>Billables | Weekly</h1>
<%= render :partial => 'billables' %>

<!-- month.html.erb -->
<h1>Billables | Monthly</h1>
<%= render :partial => 'billables' %>

<!-- _billables.html.erb -->
<table>
  <thead>
    <tr>
      <th></th>
      <th>Date</th>
      <th>Vendor</th>
      <th>Project</th>
      <th>Rate</th>
      <th></th>
    </tr>
  </thead>
  <tfoot>
    <tr>
      <td colspan="4">Total</td>
      <td><%= number_to_currency @billables.to_a.sum(&:rate) %></td>
      <td></td>
    </tr>
  </tfoot>
  <tbody>
    <% for billable in @billables %>
      <% content_tag_for :tr, billable, :class => cycle('odd', 'even') do %>
        <td>
          <%= link_to 'view', billable %> |
          <%= link_to 'edit', edit_billable_path(billable) %>
        </td>
        <td><%= billable.date.to_s(:short) %></td>
        <td><%= h billable.vendor.name %></td>
        <td><%= h billable.project.name %></td>
        <td><%= number_to_currency billable.rate %></td>
        <td>
          <%= link_to 'delete', billable, :method => :delete %>
        </td>
      <% end %>
    <% end %>
  </tbody>
</table>
```

<a name="after"></a>These are the partials I ended with:

```erb
<!-- day.html.erb -->
<h1>Billables | Daily</h1>
<table>
  <thead><%= render :partial => 'head' %></thead>
  <tfoot><%= render :partial => 'foot' %></tfoot>
  <tbody><%= render :partial => @billables %></tbody>
</table>

<!-- week.html.erb -->
<h1>Billables | Weekly</h1>
<table>
  <thead><%= render :partial => 'head' %></thead>
  <tfoot><%= render :partial => 'foot' %></tfoot>
  <tbody><%= render :partial => @billables %></tbody>
</table>

<!-- month.html.erb -->
<h1>Billables | Monthly</h1>
<table>
  <thead><%= render :partial => 'head' %></thead>
  <tfoot><%= render :partial => 'foot' %></tfoot>
  <tbody><%= render :partial => @billables %></tbody>
</table>

<!-- _head.html.erb -->
<tr>
  <th></th>
  <th>Date</th>
  <th>Vendor</th>
  <th>Project</th>
  <th>Rate</th>
  <th></th>
</tr>

<!-- _foot.html.erb -->
<tr>
  <td colspan="4">Total</td>
  <td><%= number_to_currency @billables.to_a.sum(&:rate) %></td>
  <td></td>
</tr>

<!-- _billable.html.erb -->
<% content_tag_for :tr, billable, :class => cycle('odd', 'even') do %>
  <td>
    <%= link_to 'view', billable %> |
    <%= link_to 'edit', edit_billable_path(billable) %>
  </td>
  <td><%= billable.date.to_s(:short) %></td>
  <td><%= h billable.vendor.name %></td>
  <td><%= h billable.project.name %></td>
  <td><%= number_to_currency billable.rate %></td>
  <td>
    <%= link_to 'delete', billable, :method => :delete %>
  </td>
<% end %>
```
