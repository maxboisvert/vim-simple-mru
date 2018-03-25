if exists("g:loaded_vim_simple_mru")
  finish
endif
let g:loaded_vim_simple_mru = 1

let g:vsm_size = get(g:, 'vsm_size', 100)
let g:vsm_file = get(g:, 'vsm_file', '.vim-simple-mru')
let g:vsm_exclude = get(g:, 'vsm_exclude', '')
let g:vsm_file_list = g:vsm_file . ".list"

fun! s:SimpleMruPlugin()
    command SimpleMRU call <SID>Open()
    autocmd BufEnter * call s:Add()

    fun! s:Add()
        let fname = fnamemodify(@%, ":.")

        if fname == "" || &buftype != "" || fname == g:vsm_file_list
            return
        endif

        if g:vsm_exclude != "" && fname =~# g:vsm_exclude
            return
        endif

        call writefile([fname], g:vsm_file, 'a')
        call s:UpdateMruFile()
    endfun

    fun! s:Open()
        exec "e " . g:vsm_file_list . " | 1"

        let b:vsm_buffer_init = get(b:, "vsm_buffer_init", 0)
        if !b:vsm_buffer_init
            let b:vsm_buffer_init = 1

            setlocal autoread
            setlocal buftype=nofile
            setlocal noswapfile
            setlocal nowrap
            setlocal nobuflisted
            setlocal bufhidden=hide
            nnoremap <silent> <buffer> <cr> :exec "e " . getline('.')<CR>
        endif
    endfun

    fun! s:UpdateMruFile()
        let command1 = "tail -r " . g:vsm_file . " | awk '!a[$0]++' > " . g:vsm_file_list
        let comment2 = "tail -r " . g:vsm_file_list . " > " . g:vsm_file
        call system("(" . command1 . "; " . comment2 . ") &")
    endfun
endfun

call s:SimpleMruPlugin()
