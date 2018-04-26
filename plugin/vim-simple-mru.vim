if exists("g:loaded_vim_simple_mru")
  finish
endif
let g:loaded_vim_simple_mru = 1

let g:vsm_size = get(g:, 'vsm_size', 100)
let g:vsm_open_last_file = get(g:, 'vsm_open_last_file', 1)
let g:vsm_file = get(g:, 'vsm_file', '.vim-simple-mru')
let g:vsm_exclude = get(g:, 'vsm_exclude', '')

let s:vsm_used = 0
let s:vsm_init = 0
let s:vsm_fzf_options = { 'source': 'cat ' . g:vsm_file, 'sink': 'e', 'down': '40%', 'options': '+s --tac' }

command SimpleMRU call fzf#run(s:vsm_fzf_options)

augroup vim_simple_mru
    autocmd!
    autocmd VimEnter * nested call s:OpenLastFile()
    autocmd VimLeavePre * call s:CleanMruFile()
    autocmd BufEnter * call s:Add()
augroup END

fun! s:CleanMruFile()
    if !s:vsm_used
        return
    endif

    let command1 = '[ $(cat ' . g:vsm_file . ' | wc -l) -gt ' . (g:vsm_size * 2) . ' ]'
    let command2 = 'sed -i .bak "1,' . g:vsm_size . 'd" ' . g:vsm_file
    call system("(" . join([command1, command2], " && ") .") &")
endfun

fun! s:OpenLastFile()
    if g:vsm_open_last_file && len(argv()) == 0
        let last_file = system("tail -n 1 " . g:vsm_file)
        if last_file != ""
            exec "e " . last_file
        endif
    endif

    let s:vsm_init = 1
endfun

fun! s:Add()
    if !s:vsm_init
        return
    endif

    let fname = fnamemodify(@%, ":.")
    let fname_tail = fnamemodify(@%, ":t")

    if fname == ""
                \ || &buftype != ""
                \ || fname[0] == "/"
                \ || fname_tail[0] == "."
                \ || (g:vsm_exclude != "" && fname =~# g:vsm_exclude)
                \ || !filereadable(fname)
        return
    endif

    let s:vsm_used = 1
    call s:AddMruLine(fname)
endfun

fun! s:AddMruLine(fname)
    let command1 = 'sed -i .bak "\+^' . a:fname . '$+d" ' . g:vsm_file
    let command2 = "echo '" . a:fname . "' >> " . g:vsm_file
    call system("(" . join([command1, command2], " ; ") .") &")
endfun
