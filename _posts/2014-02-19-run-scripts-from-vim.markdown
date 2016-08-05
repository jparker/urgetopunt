---
layout: post
title: Execute Ruby or Python Scripts from Vim
categories: vim
---

While developing Ruby script using Vim I frequently want to execute the
script. This is easy to do by calling <kbd>:!ruby %</kbd> in Vim, but
that's rather a lot of typing. With a Vim mapping I shortened this:

```viml
noremap <Leader>rx :!ruby %<CR>
```

Now I just have to hit <kbd>\rx</kbd> in Vim to execute the current
buffer. (NB: I'm using the default Vim leader <kbd>\</kbd>.) Of
course, sometimes I want to pass arguments to the script on the command
line. This was easy to accomplish by omitting the carriage return at the
end of the mapping:

```viml
" note the trailing white space on the next line
noremap <Leader>re :!ruby % 
```

Now I can hit <kbd>\re</kbd>, and before the script executes, I can enter the
desired arguments and hit enter to execute the contents of the buffer. (Note
the trailing white space at the end of the mapping. This is deliberate. With
it, I don't remember to add a space before entering any optional arguments. I
have a simple mind, and it delights in simple things.)

Recently I started working with Python, and I wanted the same ability.
My first iteration defined new mappings for Python:

```viml
" note the trailing white space on the next line
noremap <Leader>pe :!python % 
noremap <Leader>px :!python %<CR>
```

This gave me <kbd>\pe</kbd> and <kbd>\px</kbd> mappings similar to
the originals.

But this placed an awkward load on my right pinky finger using a QWERTY
keyboard layout. Moreover, now I had the extra cognitive overhead of of
choosing a mapping based on my the type of file I was working with. What am I
to do when I add another language to the arsenal? More mappings? This isn't
what I wanted. What I really wanted was to continue using the <kbd>\rx</kbd>
mapping. Let's just rewrite the original mapping and have it run a function.

```viml
function! RunFile()
  if match(@%, '.rb$') != -1
    let argv = input('!ruby % ')
    exec '!ruby % ' . argv
  elseif match(@%, '.py$') != -1
    let argv = input('!python % ')
    exec '!python % ' . argv
  else
    echo '<< ERROR >> RunFile() only supports ruby and python'
  endif
endfunction

noremap <Leader>rx :call RunFile()<CR>
```

This version introduces a slight change to my workflow. Now when I hit
<kbd>\rx</kbd> Vim prompts me for any additional arguments I want to pass to
the script on execution --- this is what <kbd>\re</kbd> and <kbd>\pe</kbd> did
before. The original behavior of <kbd>\rx</kbd> and <kbd>\px</kbd> is gone.
This means an extra carriage return when I'm executing the script without
arguments, but it's easier to type and less to remember overall. When it's time
to support a new language, I can just add an <code>elseif</code> branch to
<code>RunFile()</code>
