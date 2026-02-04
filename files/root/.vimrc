" ============================
"   Vim 中文优化配置（修复版）
" ============================

" 使用 UTF-8 编码
set encoding=utf-8
set fileencodings=utf-8,gb18030,gbk,gb2312

" 显示行号
set number

" 显示光标位置
set ruler

" 自动缩进
set autoindent
set smartindent
set expandtab
set tabstop=4
set shiftwidth=4

" 高亮语法
syntax on

" 搜索增强
set hlsearch
set incsearch
set ignorecase
set smartcase

" 更好的中文折行
set wrap
set linebreak
set showbreak=↪\

" True Color（ttyd 支持）
set termguicolors

" 中文帮助
set helplang=cn
