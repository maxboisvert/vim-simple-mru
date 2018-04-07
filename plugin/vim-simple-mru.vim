if exists("g:loaded_vim_simple_mru")
  finish
endif
let g:loaded_vim_simple_mru = 1

" TODO
" reopen last file
" filter unlisted buffers

let g:vsm_size = get(g:, 'vsm_size', 100)
let g:vsm_last_file = get(g:, 'vsm_last_file', 0)
let g:vsm_file = get(g:, 'vsm_file', '.vim-simple-mru')
let g:vsm_exclude = get(g:, 'vsm_exclude', '')

fun! s:SimpleMruPlugin()
    let s:vsm_fzf_options = {
                \ 'source': 'tail -r ' . g:vsm_file,
                \ 'sink': 'e',
                \ 'down': '40%',
                \ 'options': '-m -x +s'
                \ }

    command SimpleMRU call fzf#run(s:vsm_fzf_options)
    autocmd BufEnter * call s:Add()

    if g:vsm_last_file
        autocmd VimEnter * call s:OpenLastFile()
    endif

    let check_size_command = '[ $(cat ' . g:vsm_file . ' | wc -l) -gt ' . (g:vsm_size * 2) . ' ] && sed -i .bak "1,' . g:vsm_size . 'd" ' . g:vsm_file
    call system("(" . check_size_command . ") &")


    fun! s:OpenLastFile()
        if len(argv()) > 0
            return ""
        endif

        let last_file = system("tail -n 1 " . g:vsm_file)
        if last_file != ""
            exec "e " . last_file
        endif
    endfun

    fun! s:Add()
        let fname = fnamemodify(@%, ":.")

        if fname == "" || fname[0] == "/" || fname[0] == "."
            return
        endif

        if g:vsm_exclude != "" && fname =~# g:vsm_exclude
            return
        endif

        if &buftype != ""
            return
        endif

        if !filereadable(fname)
            return
        end

        let command1 = 'sed -i .bak "\+^' . fname . '$+d" ' . g:vsm_file
        let command2 = "echo '" . fname . "' >> " . g:vsm_file
        call system("(" . join([command1, command2], " ; ") .") &")
    endfun
endfun

call s:SimpleMruPlugin()
