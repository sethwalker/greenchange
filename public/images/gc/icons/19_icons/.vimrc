set nocompatible      " We're running Vim, not Vi!
syntax on             " Enable syntax highlighting
filetype on           " Enable filetype detection
filetype indent on    " Enable filetype-specific indenting
filetype plugin on    " Enable filetype-specific plugins
filetype plugin indent on    " Enable filetype-specific plugins

set expandtab
set tabstop=2
set sw=2
set showmatch
set autoindent
au BufNewFile,BufRead  svn-commit.* setf svn
