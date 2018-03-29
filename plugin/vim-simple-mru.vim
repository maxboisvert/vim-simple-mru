if exists("g:loaded_vim_simple_mru")
  finish
endif
let g:loaded_vim_simple_mru = 1

let g:vsm_size = get(g:, 'vsm_size', 100)
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

    fun! s:Add()
        let fname = fnamemodify(@%, ":.")

        if fname == "" || fname[0] == "/" || fname[0] == "." || (g:vsm_exclude != "" && fname =~# g:vsm_exclude)
            return
        endif

        let command1 = 'sed -i .bak "\+' . fname . '+d" ' . g:vsm_file
        let command2 = "echo '" . fname . "' >> " . g:vsm_file
        call system("(" . command1 . " ; " . command2 . ") &")
    endfun
endfun

call s:SimpleMruPlugin()
