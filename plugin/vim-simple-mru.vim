if exists("g:loaded_vim_simple_mru")
  finish
endif
let g:loaded_vim_simple_mru = 1

let g:vsm_window_size = get(g:, 'vsm_window_size', 8)
let g:vsm_size = get(g:, 'vsm_size', 100)
let g:vsm_file = get(g:, 'vsm_file', '.vim-simple-mru')
let g:vsm_open_last_file_on_startup = get(g:, 'vsm_open_last_file_on_startup', 1)
let g:vsm_exclude = get(g:, 'vsm_exclude', '')

fun! s:SimpleMruPlugin()
    command SimpleMruOpen call <SID>Open()

    autocmd BufEnter * call s:Add()

    fun! s:Add()
        let fname = @%

        if fname == "" || &buftype != ""
            return
        endif

        if g:vsm_exclude != ""
            if fname =~# g:vsm_exclude
                return
            endif
        endif

        call writefile([fname], g:vsm_file, 'a')
    endfun

    fun! s:Open()
        call setqflist(s:GetMruFiles())
        copen
    endfun

    fun! s:GetMruFiles()
        let mru_files = []

        if !s:FileExists(g:vsm_file)
            return mru_files
        endif

        let tmp_file = g:vsm_file . ".tmp"
        call system("tail -n " . g:vsm_size ." -r " . g:vsm_file . " | awk '!a[$0]++' > " . tmp_file)

        for mru_file in readfile(tmp_file)
            call add(mru_files, { 'filename': mru_file, "text": fnamemodify(mru_file, ":t") })
        endfor

        return mru_files
    endfun

    fun! s:FileExists(file)
        return filereadable(a:file)
    endfun
endfun

call s:SimpleMruPlugin()
