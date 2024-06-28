syntax on
colorscheme desert
"colorscheme dogui
set scrolloff=5
set listchars=tab:--
set list
set hlsearch incsearch
set iskeyword="@,48-57,_"

syntax enable
filetype plugin indent on

" IF WORD SELECTION ON FSTAR IS MESSED UP DISABLE forth.vim IN THE SYNTAX
" DIRECTORIES!!!!

set nocompatible              " be iMproved, required
filetype off                  " required

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'let-def/vimbufsync'
Plugin 'the-lambda-church/coquille'
Plugin 'derekelkins/agda-vim'
Plugin 'FStarLang/VimFStar'
Plugin 'jceb/vim-orgmode'
Plugin 'tpope/vim-speeddating'
Plugin 'vim-airline/vim-airline'
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/nerdcommenter'
Plugin 'lukerandall/haskellmode-vim'
Plugin 'godlygeek/tabular'
Plugin 'rhysd/vim-llvm'
Plugin 'matze/vim-tex-fold'
Plugin 'airblade/vim-gitgutter'
Plugin 'bohlender/vim-smt2'
Plugin 'ludovicchabant/vim-gutentags'
call vundle#end()
set laststatus=2
filetype plugin indent on

nmap <F8> :TagbarToggle<CR>

let g:haddock_browser="chromium"
let g:haddock_docdir="/usr/share/doc/ghc/"

let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDAltDelims_java = 1
"let g:NERDUsePlaceHolders = 0
let g:NERDCustomDelimiters = { 'fstar': { 'left': '(*','right': '*)' } }
let g:NERDTrimTrailingWhitespace = 1

set wildmode=longest,list,full
set wildmenu
set mouse=a
set softtabstop=8

" set cursorcolumn
" set cursorline
" hi CursorColumn cterm=None ctermbg=black
" hi CursorLine   cterm=None ctermbg=black

highlight ColorColumn ctermbg=black
" Tabs
highlight SpecialKey ctermfg=8

autocmd BufRead,BufNewFile *.cilk set filetype=c

filetype plugin on
autocmd BufRead,BufNewFile *.v set filetype=coq nocindent
autocmd BufRead,BufNewFile *.v CoqLaunch
autocmd FileType coq call coquille#FNMapping()

autocmd BufRead,BufNewFile *.c,*.cilk,*.h,*.C,*.cpp,*.cc,*.java set cindent autoindent softtabstop=8 ts=8 shiftwidth=8 fdm=syntax nu colorcolumn=81
autocmd BufRead,BufNewFile *.cpp set cindent autoindent softtabstop=8 ts=8 shiftwidth=4 fdm=syntax nu colorcolumn=81 et
autocmd BufRead,BufNewFile *.lex,*.y,set autoindent nu
autocmd BufRead,BufNewFile *.sml,*.sig set filetype=sml syntax=fsharp et ts=8 shiftwidth=4 ai nu
autocmd BufRead,BufNewFile *.ml,*.mli set et ts=8 shiftwidth=4 ai nu
autocmd BufRead,BufNewFile *.erl,*.hrl set autoindent nu

autocmd BufRead,BufNewFile *.smt2 set filetype=smt2 et
autocmd BufRead,BufNewFile *.smt set filetype=smt2 et

function! GuidoTexFoldText()
    let line = trim(getline(v:foldstart) . '  ' . getline(1 + v:foldstart))
    let folded_line_num = v:foldend - v:foldstart
    let line_text = substitute(line, '^"{\+', '', 'g')
    let fillcharcount = &textwidth - len(line_text) - len(folded_line_num)
    return '+'. repeat('-', 4) . line_text . repeat('.', fillcharcount) . ' (' . folded_line_num . ' L)'
endfunction

autocmd BufWinEnter *.tex set autoindent shiftwidth=4 et ts=8
" autocmd BufWinEnter *.tex let &foldlevel = max(map(range(1, line('$')), 'foldlevel(v:val)'))
autocmd BufWinEnter *.tex set foldtext=GuidoTexFoldText()

autocmd BufRead,BufNewFile *.bib set autoindent shiftwidth=4 et ts=8
autocmd BufRead,BufNewFile *.lhs set autoindent shiftwidth=4 et ts=8 filetype=tex
autocmd BufRead,BufNewFile *.cls set autoindent shiftwidth=4 et ts=8 filetype=tex

autocmd BufRead,BufNewFile *.fs,*.fsi,*.fst,*.fsti set filetype=fstar  autoindent expandtab nu shiftwidth=2 ts=8 iskeyword=@,',48-57,_,192-255 commentstring=(*%s*) et colorcolumn=101 foldmethod=indent foldlevel=99

autocmd BufRead,BufNewFile *.sml set filetype=sml autoindent expandtab nu shiftwidth=8 ts=8 iskeyword=@,',48-57,_,192-255 commentstring=(*%s*) et colorcolumn=101

autocmd BufWinEnter *.c,*.cilk,*.h,*.C,*.cpp,*.cc,*.java let &foldlevel = max(map(range(1, line('$')), 'foldlevel(v:val)'))
autocmd BufWinEnter *.hs set et ts=8 shiftwidth=4 autoindent nu iskeyword=@,',48-57,_,192-255
autocmd BufRead,BufNewFile *.idr set filetype=haskell     autoindent expandtab nu shiftwidth=4 ts=8 iskeyword=@,',48-57,_,192-255


autocmd FileType sh set ts=8 shiftwidth=8

nnoremap + :Ex
" nnoremap : q:i
" nnoremap / q/i

inoremap <C-l> λ
inoremap <C-y> γ
inoremap <C-g> Γ
inoremap <C-a> ∀
inoremap <C-e> ∃
inoremap <C-v> ≤
inoremap <C-z> ×
inoremap <C-O> ⊕
inoremap <C-o> ∘
inoremap <C-f> φ
inoremap <C-t> τ

inoremap <F10> ₀
inoremap <F1>  ₁
inoremap <F2>  ₂
inoremap <F3>  ₃
inoremap <F4>  ₄
inoremap <F5>  ₅
inoremap <F6>  ₆
inoremap <F7>  ₇
inoremap <F8>  ₈
inoremap <F9>  ₉

map _ff :call FormatC()<CR>
func FormatC()
	%!indent -kr -i8
endfunc

highlight clear GGG
