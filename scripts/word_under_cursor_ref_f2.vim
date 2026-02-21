function! WordUnderCursorRef()
  let word = expand('<cword>')
  let pat  = '\V\<'.escape(word, '\').'\>'
  let repl = '[`'.escape(word, '\').'`](@ref)'
  if pat == '' || repl == ''
    return
  endif
  let new = substitute(word, pat, repl, '')
  execute 'normal! ciw' . new
  silent .s/\(\[`\w\+`\](@ref)\)()/\1/ge
  silent .s/\(\[`\w\+\)\(`\](@ref)\)!/\1!\2/ge
endfunction

map! <F2> <ESC>:call WordUnderCursorRef()<CR>i
map <F2> :call WordUnderCursorRef()<CR>
