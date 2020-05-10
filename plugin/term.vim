" TOC:
" :C - clean (remove compiled executable)
" :D - run <file> in debugger; break on current line
" :J - compile and execute current buffer
" :L - clean terminal from regular window
" :M - compile and open quickfix window
" :Q - close terminal from regular window
" :R - open REPL
" :T - open terminal in right window

function! TermMake(cr, cl) " TODO move expands inside function
  write!

  if &filetype ==# 'rust'
    let cmd = &makeprg . ' --out-dir ' . expand('%:h') . ' ' . expand('%')
  elseif &filetype ==# 'c'
    let cmd = &makeprg .  ' -o ' . expand('%<') . ' ' . expand('%')
  elseif &filetype ==# 'plantuml'
    let cmd = &makeprg . ' ' . expand('%')
  else
    return
  endif

  let cmd = ' ' . cmd

  if len(term_list())
    call term_sendkeys(term_list()[0], a:cl)
  else
    call term_start('fish', {'vertical': 1, 'term_finish': 'close'})
  endif

  call term_sendkeys(term_list()[0], cmd . a:cr)
  NERDTreeRefreshRoot
endfunction

function! TermExecute(cr, cl, cu) " TODO move expands inside function
  if len(term_list())
    call term_sendkeys(term_list()[0], a:cl)
  else
    call term_start('fish', {'term_rows': 10, 'term_kill': 'kill', 'term_finish': 'close'})
    wincmd k
  endif

  if b:exec ==# './'
    call VIMRC_Make(a:cr, a:cl)
  endif

  write
  call term_sendkeys(term_list()[0], a:cu . ' ' . b:exec . expand('%<') . b:bin_ext . a:cr)
endfunction

function! TermDebug(cr, cl)
  if len(term_list())
    call term_sendkeys(term_list()[0], a:cl)
  else
    call term_start('fish', {'vertical': 1, 'term_finish': 'close'})
    wincmd k
  endif

  write
  call term_sendkeys(term_list()[0], ' ' . 'ipdb -c "break ' . line('.') . '" -c "continue" ' . expand('%') . a:cr)
endfunction

function! TermClose(cu, cd)
  cclose

  for term in term_list()
    call term_sendkeys(term, 'i' . a:cu . a:cd)
  endfor
endfunction

command! -nargs=0 R :execute ':rightbelow terminal ++rows=10 ++close ' . b:repl
command! -nargs=0 Q :call TermClose(expand('<C-U>'), expand('<C-D>'))

command! -nargs=0 M :call TermMake(expand('<CR>'), expand('<C-L>'))
command! -nargs=0 J :call TermExecute(expand('<CR>'), expand('<C-L>'), expand('<C-U>'))

command! -nargs=0 L if len(term_list()) | :call term_sendkeys(term_list()[0], expand('<C-L>')) | endif
command! -nargs=0 C :call delete(expand('%<')) | :NERDTreeRefreshRoot

command! -nargs=0 T if !len(term_list()) | :call term_start('fish', {'vertical': 1, 'term_finish': 'close'}) | endif
command! -nargs=0 D :call TermDebug(expand('<CR>'), expand('<CL>'))
