---
layout: post
title: Running RSpec Within Vim
---

Below are a handful of mappings and a function I use to run various
incantations of [RSpec](https://www.relishapp.com/rspec) from within
[Vim](http://www.vim.org).

```viml
noremap <Leader>rs :call RunSpec('spec', '-fp')<CR>
noremap <Leader>rd :call RunSpec(expand('%:h'), '-fd')<CR>
noremap <Leader>rf :call RunSpec(expand('%'), '-fd')<CR>
noremap <Leader>rl :call RunSpec(expand('%'), '-fd -l ' . line('.'))<CR>

function! RunSpec(spec_path, spec_opts)
  let speccish = match(@%, '_spec.rb$') != -1
  if speccish
    exec '!bundle exec rspec ' . a:spec_opts . ' ' . a:spec_path
  else
    echo '<< WARNING >> RunSpec() can only be called from inside spec files!'
  endif
endfunction
```

When a spec file is open in the current buffer I can do the following:

{:.table.table-bordered.table-hover.table-striped}
|Mapping|Description|
|`\rl`|Run the example the includes the current line, e.g., <kbd>rspec spec/models/foo_spec.rb ~l N</kbd>. (If the current line is an `it` block, only that example is run. If the current line is a `describe` block, all examples within the context are run --- I'm particularly fond of this feature of RSpec.)|
|`\rf`|Run the entire spec file, e.g., <kbd>rspec spec/models/foo_spec.rb</kbd>.|
|`\rd`|Run all the spec files in the current spec file's directory, e.g., <kbd>rspec spec/models</kbd>.|
|`\rs`|Run the entire spec suite, e.g., <kbd>rspec spec</kbd>.|

The way the mappings are configured the first three mappings run
<kbd>rspec</kbd> with the documentation format. The last one runs
<kbd>rspec</kbd> with the progress (dots) format. I find the former
nice when I'm running a small number of examples and the latter
perferable when I'm running a large number of examples.
