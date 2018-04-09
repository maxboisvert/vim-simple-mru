# Vim Simple MRU

## Installation

You need `fzf.vim` installed.

With `vim-plug`:
```
Plug 'maxboisvert/vim-simple-mru'
```
Or use your preffered way.

# Usage

Each time a buffer is accessed, the mru file is updated. Use the `:SimpleMRU` command to list the mru list. Also, the last opened file is opened on vim startup.

# Options (with default displayed)

```
let g:vsm_size = 100
let g:vsm_open_last_file = 1
let g:vsm_file = '.vim-simple-mru'
let g:vsm_exclude = ''
```
