
"                                 CHEN                                     "
"                              VIM-PYTHON                                  "
"                                                                          "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"								插件管理
set nocompatible              " be iMproved, required
set hidden
filetype off                  " required


if filereadable(expand("~/.vim/.vimrc.plug"))
  	source ~/.vim/.vimrc.plug
endif

"filetype plugin indent on
" To ignore plugin indent changes, instead use:
filetype plugin on
"
" Brief help
" :PluginList          - list configured plugins
" :PluginInstall(!)    - install (update) plugins
" :PluginSearch(!) foo - search (or refresh cache first) for foo
" :PluginClean(!)      - confirm (or auto-approve) removal of unused plugins
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Plugin commands are not allowed.
" Put your stuff after this line

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""
"Fast edit vimrc
""""""""""""""""""""""""""""""
function! MySys()
 if has("win32")
   return "windows"
 else
   return "linux"
 endif
endfunction


function! SwitchToBuf(filename)
  "let fullfn = substitute(a:filename, "^\\~/", $HOME . "/", "")
  " find in current tab
 let bufwinnr = bufwinnr(a:filename)
 if bufwinnr != -1
	 exec bufwinnr . "wincmd w"
	return
 else
	" find in each tab
	tabfirst
	let tab = 1
	while tab <= tabpagenr("$")
		let bufwinnr = bufwinnr(a:filename)
		if bufwinnr != -1
		exec "normal " . tab . "gt"
		exec bufwinnr . "wincmd w"
		return
		endif
		tabnext
		let tab = tab + 1
	endwhile
	 " not exist, new tab
	 exec "tabnew " . a:filename
 endif
endfunction


let mapleader = " "
if MySys() == 'linux'
  "Fast reloading of the .vimrc
  map <silent> <leader>ss :source ~/.vimrc<cr>
  "Fast editing of .vimrc
  map <silent> <leader>ee :call SwitchToBuf("~/.vimrc")<cr>
  "When .vimrc is edited, reload it
  autocmd! bufwritepost .vimrc source ~/.vimrc
elseif MySys() == 'windows'
  " Set helplang
  set helplang=cn
  "Fast reloading of the _vimrc
  map <silent> <leader>ss :source ~/_vimrc<cr>
  "Fast editing of _vimrc
  map <silent> <leader>ee :call SwitchToBuf("~/_vimrc")<cr>
  "When _vimrc is edited, reload it
  autocmd! bufwritepost _vimrc source ~/_vimrc
endif



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                               基本配置
"
"开启语法高亮
 syntax on
"syntax enable
"
"自动、智能缩进
 autocmd FileType python setlocal ts=4 sts=4 sw=4 expandtab
 autocmd FileType cpp setlocal ts=4 sts=4 sw=4 expandtab
 autocmd FileType c setlocal ts=4 sts=4 sw=4 expandtab
 autocmd FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
 autocmd FileType html setlocal ts=2 sts=2 sw=2 expandtab
 autocmd BufRead *.css setlocal ts=2 sts=2 sw=2 expandtab
 autocmd BufRead *.json setlocal ts=2 sts=2 sw=2 expandtab
 autocmd BufRead *.vue setlocal ts=2 sts=2 sw=2 expandtab
 autocmd BufRead *.wxml setlocal ts=2 sts=2 sw=2 expandtab
 autocmd BufRead *.wxss setlocal ts=2 sts=2 sw=2 expandtab
 set autoindent
 set cindent
 set smartindent
 set fileformat=unix
 filetype indent on

"paste toggle
"" set pastetoggle=<C>t
"中文乱码"
 set fileencodings=utf-8,chinese
"默认展开所有代码
" tips : 用za 来 fold/unfold
 set foldmethod=indent
 nnoremap <space><space> za
 set foldlevel=99
 set ruler
 set number
 set relativenumber
 set cursorline
 set cursorcolumn
set textwidth=9999
"set nowrap
 set wrap
" 搜索
set hlsearch                    " highlight searches
set incsearch                   " do incremental searching, search as you type
set ignorecase                  " ignore case when searching
set smartcase                   " no ignorecase if Uppercase char present
"在当前目录及子目录下用find打开指定文件
 set path=./**
"恢复上次光标位置
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
"启动界面
 set shortmess=atI
"Alt 组合键不映射到菜单上
 set winaltkeys=no

imap jj <Esc>
imap <C-h> <left>
imap <C-l> <right>
cmap q<CR> qa<CR>

"MacOS
set backspace=indent,eol,start

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                   mac os map
if has('mac') && ($TERM == 'xterm-256color' || $TERM == 'screen-256color')
map <Esc>OP <F1>
map <Esc>OQ <F2>
map <Esc>OR <F3>
map <Esc>OS <F4>
map <Esc>[16~ <F5>
map <Esc>[17~ <F6>
map <Esc>[18~ <F7>
map <Esc>[19~ <F8>
map <Esc>[20~ <F9>
map <Esc>[21~ <F10>
map <Esc>[23~ <F11>
map <Esc>[24~ <F12>
endif
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"							nerdtree
"
"不显示帮助信息
 let NERDTreeMinimalUI=1
"鼠标点击
 let NERDTreeMouseMode = 2
"宽度
 let g:NERDTreeWinSize = 30
"忽略文件、隐藏文件
 let NERDTreeIgnore = ['\.pyc$']
 let NERDTreeSortOrder=['\/$', 'Makefile', 'makefile', '*', '\~$']
 nmap wm :NERDTreeToggle<cr>
 autocmd StdinReadPre * let s:std_in=1
 autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
 autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"		window
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"关闭当前窗口
 nmap wc      <C-w>c
"分割窗口
 nmap wv      <C-w>v
 nmap ws      <C-w>s

"打开quickfix
nnoremap co :copen<cr><<Esc>
nnoremap cc :cclose<cr><Esc>
nnoremap cb :cbottom<cr><Esc>
nnoremap cn :cnext<cr><Esc>
nnoremap cp :cprev<cr><Esc>

"" nmap w<c-n>  <C-w>n
"" nmap w:      <C-w>:
"分割窗口移动快捷键
nnoremap wh  <c-w>h
nnoremap wj  <c-w>j
nnoremap wk  <c-w>k
nnoremap wl  <c-w>l
nnoremap wp  <c-w>p

" resize the windows
nnoremap w<up>   <c-w>+
nnoremap w<down>   <c-w>-
nnoremap w<left>   <c-w><
nnoremap w<right>   <c-w>>

"""""""""""""""""""""""""""""
" terminal
" """"""""""""""""""""""""""
tnoremap <Esc> <C-W>N
au BufWinEnter * if &buftype == 'terminal' | setlocal bufhidden=hide | endif

"autocmd BufRead *.py :NERDTreeToggle
"关闭窗口
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"							 tagbar
"autocmd BufRead *.* nmap tb :Tagbar<cr>
nmap tb :Tagbar<cr>
"let tagbar_ctags_bin='/usr/bin/ctags'
let tagbar_width=35
"let g:tagbar_compact = 1
let g:tagbar_autoshowtag = 1
let g:tagbar_previewwin_pos = "aboveleft"
autocmd BufWinEnter * if &previewwindow | setlocal nonumber | endif
"let g:tagbar_autopreview = 1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Cuda *.cu as cpp filetype
au BufNewFile,BufRead *.cu
    \ set filetype=cpp

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                  py文件头
"autocmd bufnewfile *.py call HeaderPython()
"function HeaderPython()
"    call setline(1, "#!/usr/bin/env python")
"    call append(1, "# -*- coding: utf-8 -*-")
"    normal G
"    normal o
"    normal o
"endf
function! ScriptHeader()
    if &filetype == 'python'
        let header = "#!/usr/bin/env python"
        let cfg = "# vim: ts=4 sw=4 sts=4 expandtab"
    elseif &filetype == 'sh'
        let header = "#!/bin/bash"
    endif
    let line = getline(1)
    if line == header
        return
    endif
    normal m'
    call append(0,header)
    call append(1, "# -*- coding: utf-8 -*-")
    if &filetype == 'python'
        call append(2, cfg)
    endif
    normal ''
    set tags+=$HOME/.vim/tags/python.ctags
endfunction

au BufNewFile *.py call ScriptHeader()
au BufNewFile *.sh call ScriptHeader()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                               power-line
"set nocompatible   " Disable vi-compatibility
set laststatus=2   " Always show the statusline
set encoding=utf-8 " Necessary to show Unicode glyphs"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                markdown
let g:vim_markdown_folding_style_pythonic = 1
let g:vim_markdown_toc_autofit = 1
autocmd BufRead *.md nmap tb :Toc<cr>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



""""""""""""""""""""""""""
" Copy & Pase
"set clipboard=unnamed
" """""""""""""""""""""""

""""""""""""""""""""""""""""""
" mark setting
""""""""""""""""""""""""""""""
"nmap <silent> <leader>hl <Plug>MarkSet
"vmap <silent> <leader>hl <Plug>MarkSet
"nmap <silent> <leader>hh <Plug>MarkClear
"vmap <silent> <leader>hh <Plug>MarkClear
"nmap <silent> <leader>hr <Plug>MarkRegex
"vmap <silent> <leader>hr <Plug>MarkRegex
" For mark plugin
"hi MarkWord1 ctermbg=Cyan ctermfg=Black guibg=#8CCBEA guifg=Black
"hi MarkWord2 ctermbg=Green ctermfg=Black guibg=#A4E57E guifg=Black
"hi MarkWord3 ctermbg=Yellow ctermfg=Black guibg=#FFDB72 guifg=Black
"hi MarkWord4 ctermbg=Red ctermfg=Black guibg=#FF7272 guifg=Black
"hi MarkWord5 ctermbg=Magenta ctermfg=Black guibg=#FFB3FF guifg=Black
"hi MarkWord6 ctermbg=Blue ctermfg=Black guibg=#9999FF guifg=Black

let g:mwDefaultHighlightingPalette = 'extended'
let g:mwDefaultHighlightingNum = 9
let g:mwAutoLoadMarks = 1


""""""""""""""""""""""""""""""
" vim-cellmode
" """"""""""""""""""""""""""""
" C-c send current selected lines to tmux
" C-g sends the current cell to tmux
" C-b d

"noremap <silent> <C-a> :call RunTmuxPythonAllCellsAbove()<CR>
"let g:cellmode_use_tmux=1
"let g:cellmode_use_tmux=1
"let g:cellmode_use_tmux=1

""""""""""""""""""""""""""""""
" indentLine
" """"""""""""""""""""""""""""
let g:indentLine_concealcursor="nc"
let g:indentLine_fileTypeExclude=['tex', 'json']
let g:indentLine_setColors=1

""""""""""""""""""""""""""""""
" BufExplorer
""""""""""""""""""""""""""""""
nmap <silent> <Leader>be   :BufExplorer<CR>
let g:bufExplorerDefaultHelp=0 " Do not how default help.
let g:bufExplorerShowRelativePath=1 " Show relative paths.
let g:bufExplorerSortBy='mru' " Sort by most recently used.
let g:bufExplorerSplitRight=0 " Split left.
let g:bufExplorerSplitVertical=1 " Split vertically.
let g:bufExplorerSplitVertSize = 30 " Split width
let g:bufExplorerUseCurrentWindow=1 " Open in new window.
autocmd BufWinEnter \[Buf\ List\] setl nonumber


""""""""""""""""""""""""""""""
" vim-cpp-enhanced-highlight.vim
""""""""""""""""""""""""""""""
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_template_highlight = 1

""""""""""""""""""""""""""""""
"":nmap <C-[> :ta<CR>
"":nmap <C-t> :pop<CR>
"":nmap <C-[> :tag<CR>
"CTRL-T			Jump to [count] older entry in the tag stack
" Context search. See the --from-here option of global(1).
:nmap <C-\>] :cs find d        <C-R>=expand("<cword>")<CR>:<C-R>=line('.')<CR>:%<CR>
:nmap <C-\>n :tn<CR>
:nmap <C-\>p :tp<CR>
:nmap <C-\>[ :top<CR>

"""""""""""""""""""""""""""""
" airline
""

let g:airline_powerline_fonts = 1

  let g:airline_left_sep='>'
  let g:airline_right_sep='<'

  if !exists('g:airline_symbols')
    let g:airline_symbols = {}
  endif

  " unicode symbols
  "let g:airline_left_sep = '»'
  let g:airline_left_sep = '▶'
  "let g:airline_right_sep = '«'
  let g:airline_right_sep = '◀'
  let g:airline_symbols.crypt = '🔒'
  "let g:airline_symbols.linenr = '☰'
  "let g:airline_symbols.linenr = '␊'
  "let g:airline_symbols.linenr = '␤'
  let g:airline_symbols.linenr = '¶'
  "let g:airline_symbols.maxlinenr = ''
  let g:airline_symbols.maxlinenr = '㏑'
  let g:airline_symbols.branch = '⎇'
  let g:airline_symbols.paste = 'ρ'
  "let g:airline_symbols.paste = 'Þ'
  "let g:airline_symbols.paste = '∥'
  let g:airline_symbols.spell = 'Ꞩ'
  let g:airline_symbols.notexists = '∄'
  let g:airline_symbols.whitespace = 'Ξ'

  " powerline symbols
  "let g:airline_left_sep = ''
  "let g:airline_left_alt_sep = ''
  "let g:airline_right_sep = ''
  "let g:airline_right_alt_sep = ''
  "let g:airline_symbols.branch = ''
  let g:airline_symbols.readonly = ''
  "let g:airline_symbols.linenr = '☰'
  "let g:airline_symbols.maxlinenr = ''

"let g:airline_extensions = ['branch', 'tabline', 'bufferline']
let g:airline_extensions = ['branch', 'tabline']

" airline tabline

let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#show_buffers = 1
""* enable/disable displaying tabs, regardless of number. (c) >
let g:airline#extensions#tabline#show_tabs = 1

"let g:airline#extensions#tabline#left_sep=' '
"let g:airline#extensions#tabline#left_alt_sep='|'
"let g:airline#extensions#tabline#right_sep = ''
"let g:airline#extensions#tabline#right_alt_sep = ''

"let g:airline#extensions#tabline#buffer_idx_mode=1


"enable/disable displaying open splits per tab (only when tabs are opened). >
"let g:airline#extensions#tabline#show_splits = 1
let g:airline#extensions#tabline#show_tab_nr=1

""* enable/disable displaying tab type (far right) >
  let g:airline#extensions#tabline#show_tab_type = 1


""* define the set of filetypes which are ignored selectTab keymappings
let g:airline#extensions#tabline#keymap_ignored_filetypes = ['vimfiler', 'nerdtree', 'tagbar']


nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
""* change the display format of the buffer index >
"let g:airline#extensions#tabline#buffer_idx_format = {
"        \ '0': '0 ',
"        \ '1': '1 ',
"        \ '2': '2 ',
"        \ '3': '3 ',
"        \ '4': '4 ',
"        \ '5': '5 ',
"        \ '6': '6 ',
"        \ '7': '7 ',
"        \ '8': '8 ',
"        \ '9': '9 '
"        \}

" "* configure whether buffer numbers should be shown. >
"      let g:airline#extensions#tabline#buffer_nr_show = 1

" tab
noremap <C-k>o :tabnew<CR>
noremap <C-k>c :tabclose<CR>
noremap <C-k>p :tabnext<CR>
noremap <C-k>n :tabprev<CR>
"noremap <C-k>h <Plug>AirlineSelectPrevTab
"noremap <C-k>l <Plug>AirlineSelectNextTab


let g:airline_theme='molokai'
"let g:airline_theme='zenburn'
"let g:airline_theme='powerlineish'
"gitgutter
"function! GitStatus()
  "let [a,m,r] = GitGutterGetHunkSummary()
  "return printf('+%d ~%d -%d', a, m, r)
"endfunction
"set statusline+=%{GitStatus()}
"let g:gitgutter_sign_allow_clobber = 1
"highlight GitGutterAdd    guifg=#009900 ctermfg=2
"highlight GitGutterChange guifg=#bbbb00 ctermfg=3
"highlight GitGutterDelete guifg=#ff2222 ctermfg=1

"let g:gitgutter_sign_added = 'xx'
"let g:gitgutter_sign_modified = 'yy'
"let g:gitgutter_sign_removed = 'zz'
let g:gitgutter_sign_removed_first_line = '^^'
let g:gitgutter_sign_removed_above_and_below = '{'
let g:gitgutter_sign_modified_removed = 'ww'
highlight link GitGutterChangeLine DiffText
let g:gitgutter_diff_relative_to = 'working_tree'



"""""""""""""""""""""""""""""""""""""""""
" ShowTrailingWhitespace
"一键清楚行尾空白符
nnoremap <leader>w  :%s/\s\+$//<cr>:let @/=''<CR>

"""""""""""""""""""""""""""""
"      	                          主题
set termguicolors
set t_Co=256
let g:monokai_term_italic = 1
let g:monokai_gui_italic = 1


"if !exists("g:vimrc_loaded")
    "colorscheme molokai
    "let g:molokai_original = 1
    "let g:rehash256 = 1
    if has("gui_running")
        set guioptions-=T "隐藏工具栏
        set guioptions-=L
        set guioptions-=r
        set guioptions-=m
        set gfn=Source\ Code\ Pro\ for\ Powerline\ Semi-Bold\ 10
        set gfw=STHeiti\ 9
        set langmenu=en_US
        set linespace=0
    endif " has
"endif " exists(...)

"colorscheme monokai
colorscheme molokai
"colorscheme editplus
"colorscheme zenburn

"set background=dark
"colorscheme solarized
"call togglebg#map("<F8>")
"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  clang format
"
"clang-format for formating cpp code

let g:clang_format#code_style = "webkit"
let g:clang_format#style_options = {
        \ "AccessModifierOffset" : -4,
        \ "AllowShortIfStatementsOnASingleLine" : "true",
        \ "AlwaysBreakTemplateDeclarations" : "true",
        \ "Standard" : "C++11"}

" map to <Leader>cf in C++ code
autocmd FileType c,cpp,objc nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
autocmd FileType c,cpp,objc vnoremap <buffer><Leader>cf :ClangFormat<CR>
" if you install vim-operator-user
autocmd FileType c,cpp,objc map <buffer><Leader>x <Plug>(operator-clang-format)
" Toggle auto formatting:
nmap <Leader>C :ClangFormatAutoToggle<CR>
"nnoremap <leader>cf :call FormatCode("webkit")<cr>
"nnoremap <leader>lf :call FormatCode("LLVM")<cr>
"vnoremap <leader>cf :call FormatCode("webkit")<CR>
"vnoremap <leader>lf :call FormatCode("LLVM")<cr>
"let g:autoformat_verbosemode = 1
"func FormatCode(style)
"  let firstline=line(".")
"  let lastline=line(".")
"  " Visual mode
"  if exists(a:firstline)
"    firstline = a:firstline
"    lastline = a:lastline
"  endif
"  let g:formatdef_clangformat = "'clang-format --lines='.a:firstline.':'.a:lastline.' --assume-filename='.bufname('%').' -style=" . a:style . "'"
"  let formatcommand = ":" . firstline . "," . lastline . "Autoformat"
"  exec formatcommand
"endfunc
au BufNewFile,BufRead *.svg setf svg


" LeaderF 设置
let g:Lf_ShowHidden = 1                 " 显示隐藏文件
let g:Lf_StlSeparator = {'left': '', 'right': ''} " 设置状态栏分隔符
let g:Lf_WindowPosition = 'popup'             " 窗口位置：'popup', 'bottom', 'top', 'left', 'right'
"let g:Lf_PopupPosition = {'top': 0, 'left': 0}  " 弹出窗口位置
"let g:Lf_PopupPosition = {'down': 0.3}  " 弹出窗口位置在底部，占屏幕高度的30%
let g:Lf_PopupWidth = 0.8                     " 弹出窗口宽度占比
let g:Lf_PopupHeight = 0.6                    " 弹出窗口高度占比

" 显示设置
let g:Lf_ShowRelativePath = 1                 " 显示相对路径
let g:Lf_StlShowFileNumber = 1                " 状态栏显示文件数量

" 性能优化
let g:Lf_PreviewInPopup = 1                   " 使用弹出窗口预览文件内容
let g:Lf_FuzzyMatchSpawnLeader = 1            " 启动 LeaderF 使用子进程进行模糊匹配
let g:Lf_UseCache = 1                         " 启用缓存

" 控制搜索参数
let g:Lf_CommandMap = {
      \ 'tag': 'global',
      \ 'tagAppend': 'global -a',
      \ 'file': 'ctrlp'
      \ }

" LeaderF 键绑定
" nnoremap <Leader>ff :Leaderf file<CR>
" nnoremap <Leader>fb :Leaderf buffer<CR>  " 缓冲区搜索
nnoremap <C-p> :Leaderf file<CR>
nnoremap <C-l> :Leaderf buffer<CR> 
nnoremap <Leader>fh :Leaderf help<CR> 
nnoremap <Leader>fm :Leaderf mru<CR>
nnoremap <Leader>ft :Leaderf tag<CR>
nnoremap <Leader>rg :Leaderf rg<CR>

nnoremap <silent> <leader>gd <Plug>LeaderfGtagsDefinition
nnoremap <silent> <leader>gr <Plug>LeaderfGtagsReference
nnoremap <silent> <leader>gs <Plug>LeaderfGtagsSymbol
nnoremap <silent> <leader>gg <Plug>LeaderfGtagsGrep
vmap <silent> <leader>gd <Plug>LeaderfGtagsDefinition
vmap <silent> <leader>gr <Plug>LeaderfGtagsReference
vmap <silent> <leader>gs <Plug>LeaderfGtagsSymbol
vmap <silent> <leader>gg <Plug>LeaderfGtagsGrep



" LeaderF with ripgrep 设置
"let g:Lf_RgConfig = [['--colors=match:fg:208'], ['-g', '!_build']]
let g:Lf_GrepBackend = 'rg'

let g:Lf_GtagsAutoGenerate = 1
let s:cachedir = expand('~/.cache/vim')
let g:Lf_WorkingDirectoryMode = 'c'
let g:Lf_CacheDirectory = s:cachedir
" let g:Lf_ShortcutF = <C-p>
" let g:Lf_ShortcutB = <C-l>




" floaterm 设置
nnoremap <silent><leader>tt :FloatermToggle<CR>
nnoremap <silent><leader>th :FloatermHide<CR>
nnoremap <silent><leader>tk :FloatermKill<CR>
" tnoremap <silent><leader>t <C-\><C-n>:FloatermToggle<CR>

" 配置 Floaterm
nnoremap <silent> <Leader>to :Leaderf floaterm<CR>
" tnoremap <silent> <Leader>tl <C-\><C-n>:Leaderf floaterm<CR>

let g:Lf_UseFloaterm = 1        " 启用 Floaterm 支持
let g:floaterm_width = 0.8      " 设置 Floatterm 宽度占屏幕 80%
let g:floaterm_height = 0.8     " 设置 Floatterm 高度占屏幕 80%
let g:floaterm_wintype = 'float' " 设置窗口类型为浮动

" indentLine 设置
let g:indentLine_enabled = 1

" vim-gitgutter 设置
let g:gitgutter_enabled = 1

" tagbar 设置
" nmap <F8> :TagbarToggle<CR>
"autocmd Buffer *.* nmap to :Tagbar<CR>

" vim-bookmarks 设置
nmap mm :BookmarkToggle<CR>
nmap mi :BookmarkAnnotate<CR>
nmap mn :BookmarkNext<CR>
nmap mp :BookmarkPrev<CR>
nmap ma :BookmarkShowAll<CR>
nmap mc :BookmarkClearAll<CR>

nmap <leader>ls <Plug>MarkSet
nmap <leader>lc <Plug>MarkClear
nmap <leader>lr <Plug>MarkRegex
nmap <leader>lp <Plug>MarkSearchCurentPrev
nmap <leader>ln <Plug>MarkSearchCurentNext

" coc.nvim 设置
set updatetime=1000
set signcolumn=yes

function! CheckBackspace() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1] =~# '\s'
endfunction

"inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
"inoremap <silent><expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
"inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#next(1) :
	"\ CheckBackspace() ? "\<TAB>" : coc#refresh()
"inoremap <silent><expr> <S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

inoremap <expr> <c-space> coc#refresh()

nnoremap <silent> K       :call CocActionAsync('doHover')<CR>
nnoremap <silent> gd      <Plug>(coc-definition)
nnoremap <silent> gD      <Plug>(coc-type-definition)
nnoremap <silent> gy      <Plug>(coc-type-implementation)
nnoremap <silent> gr      <Plug>(coc-references)

" coc-clangd 设置
let g:coc_global_extensions = [ 'coc-json', 'coc-clangd' ]

" Jump to previous/next diagnostic message
nnoremap <silent> [g <Plug>(coc-diagnostic-prev)
nnoremap <silent> ]g <Plug>(coc-diagnostic-next)

" Autocomplete
inoremap <silent><expr> <C-CR> coc#refresh()

" Show diagnostics in a floating window
nnoremap <silent> <leader>a  :<C-u>CocList diagnostics<CR>

" Use <leader>qf to fix the current diagnostic error
nnoremap <silent> <leader>qf :CocAction quickfix<CR>

" Format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Rename symbol at cursor
nmap <leader>rn <Plug>(coc-rename)

" Symbol renaming
nmap <leader>rr <Plug>(coc-rename)

" Call CocCommand from command line
nnoremap <leader>cc :CocCommand<CR>

" Open CocList
nnoremap <leader>cl :CocList<CR>

" 配置编译器标志
" autocmd FileType c,cpp call coc#ext#build()

" 启用补全
set completeopt=menuone,noinsert,noselect

" 跑 CocInfo 来显示错误
nnoremap <silent> <leader>li :CocInfo<CR>

" 文件类型自动补全建议
" autocmd FileType c,cpp call coc#ext#build()

" tab
noremap to :tabnew<CR>
noremap tc :tabclose<CR>
noremap tp :tabnext<CR>
noremap tn :tabprev<CR>
nmap t1 <Plug>AirlineSelectTab1
nmap t2 <Plug>AirlineSelectTab2
nmap t3 <Plug>AirlineSelectTab3
nmap t4 <Plug>AirlineSelectTab4
nmap t5 <Plug>AirlineSelectTab5
nmap t6 <Plug>AirlineSelectTab6
nmap t7 <Plug>AirlineSelectTab7
nmap t8 <Plug>AirlineSelectTab8

nnoremap <leader>w  :%s/\s\+$//<CR>:let @/=''<CR>


