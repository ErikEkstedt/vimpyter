" Inserts python block recognized by notedown
function! vimpyter#insertPythonBlock()
  exec 'normal!i```python'
  exec 'normal!o```'
  exec 'normal!O'
endfunction

" Asynchronously starts notebook loader for given file
function! s:startNotebook(notebook_loader, flags)
  if exists('b:original_file')
    call jobstart(a:notebook_loader . ' ' . a:flags . ' ' . b:original_file)
    echo 'Started ' . a:notebook_loader
  else
    echo 'No reference to original .ipynb file'
  endif
endfunction

function! vimpyter#startJupyter()
  call s:startNotebook('jupyter notebook', g:vimpyter_jupyter_notebook_flags)
endfunction

" function! vimpyter#startNteract()
"   call jobstart('nteract')
"   " call s:startNotebook('nteract', g:vimpyter_nteract_flags)
" endfunction

function! vimpyter#updateNotebook()
  if exists('b:original_file')
    silent call jobstart('notedown --from markdown --to notebook ' . b:proxy_file .
          \ ' > ' . b:original_file)
  else
    echo 'Unable to update original file, buffer not found'
  endif
endfunction

function! vimpyter#createView()
  let l:original_file = expand('%:p')
  let l:proxy_file = '/tmp/' . substitute(l:original_file, '/', '_', 'g')[1:]

  call system('notedown --to markdown ' . l:original_file .
        \ ' > ' . l:proxy_file)

  silent execute 'edit' l:proxy_file

  let b:original_file = l:original_file
  let b:proxy_file = l:proxy_file

  " FOLDING OF PYTHON INPUT AND JSON OUTPUT
  set foldmethod=marker
  set foldmarker=```{.,```

  set filetype=jupyter

  silent execute ':bd' l:original_file

endfunction

function! vimpyter#getOriginalFile()
  echo 'This view points to: ' . b:original_file
endfunction
