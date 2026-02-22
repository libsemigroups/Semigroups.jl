function! SphinxToJuliaDoc()
  silent '<,'>s/\.\. doctest::/# Example\r```jldoctest/ge
  silent '<,'>s/>>>/julia>/ge
  silent '<,'>s/^\s\+//ge
  silent '<,'>s/julia>.\{-,}\n/\r&/ge
  silent '<,'>s/\<True\>/true/ge
  silent '<,'>s/\<False\>/false/ge
  silent '<,'>s/``libsemigroups_pybind11``/Semigroups.jl/ge
  silent '<,'>s/:any:\(`\w\+`\)/[\1](@ref)/ge
  silent '<,'>s/:raises \(\w\+\):/# Throws\r- `\1`/ge
  silent '<,'>s/\*\(\w\+\)\*/`\1`/ge
  silent '<,'>s/:complexity:/# Complexity\r- /ge
  silent '<,'>s/:param \(\w\+\):.*\n:type \(\w\+\):/# Arguments\r- `\1::\2`:/ge
  silent '<,'>s/list\[\(.\{-,}\)\]/Vector{\1}/ge
  silent '<,'>s/:returns:.*\n//ge
  silent '<,'>s/:rtype:.*\n//ge
  silent '<,'>s/``\(\w\+\)``/`\1`/ge
endfunction

map! <F3> <ESC>:call SphinxToJuliaDoc()<CR>i
map <F3> :call SphinxToJuliaDoc()<CR>
