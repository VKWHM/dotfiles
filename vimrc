" Vim will load $VIMRUNTIME/defaults.vim if the user does not have a vimrc.
" This happens after /etc/vim/vimrc(.local) are loaded, so it will override
" any settings in these files.
"
" If you don't want that to happen, uncomment the below line to prevent
" defaults.vim from being loaded.
" let g:skip_defaults_vim = 1
"
" If you would rather _use_ default.vim's settings, but have the system or
" user vimrc override its settings, then uncomment the line below.
" source $VIMRUNTIME/defaults.vim

" All Debian-specific settings are defined in $VIMRUNTIME/debian.vim and
" sourced by the call to :runtime you can find below.  If you wish to change
" any of those settings, you should do it in this file or
" /etc/vim/vimrc.local, since debian.vim will be overwritten everytime an
" upgrade of the vim packages is performed. It is recommended to make changes
" after sourcing debian.vim so your settings take precedence.

runtime! debian.vim

" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes
set nocompatible
" numerous options, so any other options should be set AFTER changing
" 'compatible'.
"set compatible

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
syntax on

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
"set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
"au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
"filetype plugin indent on

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
"set showcmd		" Show (partial) command in status line.
"set showmatch		" Show matching brackets.
"set ignorecase		" Do case insensitive matching
"set smartcase		" Do smart case matching
"set incsearch		" Incremental search
"set autowrite		" Automatically save before commands like :next and :make
"set hidden		" Hide buffers when they are abandoned
set mouse=a		" Enable mouse usage (all modes)

" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif
" PARROT OS SETTINGS:
"Enable mouse click for nvim
set mouse=a
"Fix cursor replacement after closing nvim
set guicursor=
"Shift + Tab does inverse tab
inoremap <S-Tab> <C-d>

"See invisible characters
set list listchars=tab:>\ ,trail:+,eol:$

" --- Auto-install vim-plug if not already installed --- "
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source ~/.vimrc
endif 

" --- Plugin section --- "
call plug#begin('~/.vim/plugged')

" --- Status line --- "
Plug 'vim-airline/vim-airline'

" --- Theming --- "
Plug 'morhetz/gruvbox'
" Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'noahfrederick/vim-noctu'
Plug 'vim-airline/vim-airline-themes'
" Plug 'cormacrelf/vim-colors-github'
Plug 'NLKNguyen/papercolor-theme'
" --- Completion and syntax --- "

" Editing and usability
Plug 'jiangmiao/auto-pairs'

Plug 'erichdongubler/vim-sublime-monokai'

" --- Programming Languages ---
Plug 'sheerun/vim-polyglot'
" Plug 'davidhalter/jedi-vim'

" Initialize plugin system
Plug 'simeji/winresizer'
Plug 'simnalamburt/vim-mundo'
Plug 'mattn/emmet-vim'
Plug 'vim-scripts/HTML-AutoCloseTag'
Plug 'andrewradev/tagalong.vim'
Plug 'docunext/closetag.vim'
call plug#end()


filetype plugin indent on    " required
syntax on
" gruvbox italic fix (must appear before colorscheme)
let g:gruvbox_italic = 0
" Airline theme
" Airline powerline fonts fix
let g:airline_powerline_fonts = 1
:set background=dark
let g:gruvbox_bold = 1
let g:gruvbox_transparent_bg = 0
" let g:gruvbox_contrast_light = 'soft'
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_termcolors = 256
let g:jedi#use_tabs_not_buffers = 1
let g:jedi#force_py_version = 3
let g:winresizer_start_key = "<leader>w"

" NLKN Theme configuration
let g:PaperColor_Theme_Options = {
  \   'theme': {
  \     'default': {
  \       'transparent_background': 1
  \     }
  \   }
  \ }

"User-specific Settings.

" ---Sets---
" 
set encoding=utf-8      		" UTF-8 Support
set tabstop=4                   " 4 spaces will do
set shiftwidth=4                " control indentation for >> bind
set expandtab                   " spaces instead of tabs
set autoindent                  " always set autoindenting on
set relativenumber              " relative line numbers
set number                      " hybrid numbering with both rnu and number
set hidden                      " hide buffers instead of closing them
set ignorecase                  " ignore case when searching
set smartcase                   " ignore case if all lowercase
set nobackup                    " don't need swp files
set noswapfile                  " don't need swp files
"set showmatch                   " Show matching braces when over one
set backspace=indent,eol,start  " allow backspacing everything in insert
set hlsearch                    " highlight searches
set incsearch                   " search as typing
set laststatus=2		        " for lightline.vim plugin
set cursorline


" Use comma as leader
let g:mapleader = ','
" make it possible to write danish letters
let g:AutoPairsShortcutFastWrap=''
" Palyglot Pluggin Section
let g:python_highlight_indent_errors = 1
let g:python_highlight_all = 1

" ---Re-mappings---
" 
" Ctrl-C for yanking to register, Ctrl+P to paste from clipboard
vnoremap <C-c> "*y :let @+=@*<CR>
map <C-p> "+P
" since I constantly write accidentally mess these up when going fast
command WQ wq
command Wq wq
command W w
command Q q
" w!! to write with sudo even if not opened with sudo
cmap w!! w !sudo tee >/dev/null %
"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
" Bind to clear search
nmap <leader>/ :nohlsearch<CR>

" --- LaTeX Stuff ---
" Navigating with guides
" inoremap ,<Tab> <Esc>/<++><Enter>"_c4l
" vnoremap ,<Tab> <Esc>/<++><Enter>"_c4l
" map ,<Tab> <Esc>/<++><Enter>"_c4l
" 
" autocmd FileType tex inoremap <F6> <Esc>:w<Enter>:!pdflatex<space>%<Enter>a
" autocmd FileType tex nnoremap <F6> :w<Enter>:!pdflatex<space>%<Enter><Enter>
" autocmd FileType tex inoremap ,bf \textbf{}<++><Esc>T{i
" autocmd FileType tex inoremap ,it \textit{}<++><Esc>T{i
" autocmd FileType tex inoremap ,dm \[\]<Enter><++><Esc>khi
" autocmd FileType tex inoremap ,im $$<++><Esc>5hli
" autocmd FileType tex inoremap ,con \rightarrow
" autocmd FileType tex inoremap ,bic \leftrightarrow



" SaveAndRun scripts
let filePath = expand("%")

" Save, compile, run C programs
let outputName = filePath[0:eval(len(filePath) - 3)]
let cCmd = ".!gcc " . filePath . " -o " . outputName . " && ./" . outputName
nnoremap <silent> <F5> :call SaveAndRun("C Runner", cCmd)<CR>
vnoremap <silent> <F5> :<C-u>call SaveAndRun("C Runner", cCmd)<CR>

" Run Python scripts
let pCmd = ".!python3 " . shellescape(filePath, 1)
nnoremap <silent> <F6> :call SaveAndRun("Python3", pCmd)<CR>
vnoremap <silent> <F6> :<C-u>call SaveAndRun("Python3", pCmd)<CR>

function! SaveAndRun(bufferName, cmd)
    " save and reload current file
    silent execute "update | edit"

    " get file path of current file
    let s:current_buffer_file_path = expand("%")

    let s:output_buffer_name = a:bufferName
    let s:output_buffer_filetype = "output"

    " reuse existing buffer window if it exists otherwise create a new one
    if !exists("s:buf_nr") || !bufexists(s:buf_nr)
        silent execute 'botright new ' . s:output_buffer_name
        let s:buf_nr = bufnr('%')
    elseif bufwinnr(s:buf_nr) == -1
        silent execute 'botright new'
        silent execute s:buf_nr . 'buffer'
    elseif bufwinnr(s:buf_nr) != bufwinnr('%')
        silent execute bufwinnr(s:buf_nr) . 'wincmd w'
    endif

    silent execute "setlocal filetype=" . s:output_buffer_filetype
    setlocal bufhidden=delete
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal nobuflisted
    setlocal winfixheight
    setlocal cursorline " make it easy to distinguish
    setlocal nonumber
    setlocal norelativenumber
    setlocal showbreak=""

    " clear the buffer
    setlocal noreadonly
    setlocal modifiable
    %delete _

    " add the console output
    silent execute a:cmd

    " resize window to content length
    " Note: This is annoying because if you print a lot of lines then your code buffer is forced to a height of one line every time you run this function.
    "       However without this line the buffer starts off as a default size and if you resize the buffer then it keeps that custom size after repeated runs of this function.
    "       But if you close the output buffer then it returns to using the default size when its recreated
    "execute 'resize' . line('$')

    " make the buffer non modifiable
    setlocal readonly
    setlocal nomodifiable
endfunction
nnoremap Y "+y
vnoremap Y "+y
nnoremap yY ^"+y$

" Window management
nnoremap <leader>v  <C-w>v<C-w>l
nnoremap <leader>h  <C-w>s<C-w>j
nnoremap <leader>q  <C-w>q

" Tab toggling 
nnoremap <Tab> gt 
nnoremap <S-Tab> gT 

" Save undo trees in files
set undofile
set undodir=~/.vim/undo

" number of undo saved
set undolevels=10000 
" Reloading
noremap <silent> <leader>V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
" Undo graph
nnoremap <F4> :MundoToggle<CR>
inoremap jk <ESC>

let g:airline_theme = 'gruvbox'
colorscheme gruvbox

if system("echo $OSTYPE") =~ 'darwin*'
  if !(system("defaults read -g AppleInterfaceStyle || echo $WHM_APPEARANCE") =~ '^Dark')
      set t_Co=256   " This is may or may not needed.
      set background=light
      colorscheme PaperColor
      let g:airline_theme = 'lucius'
  endif
endif

