{ stdenv, vimUtils, fetchFromGitHub, ripgrep, bat, git, findutils, ncurses, file
, coreutils, vim_configurable, vimPlugins, bash, makeWrapper }:
let
  tabline = vimUtils.buildVimPluginFrom2Nix {
    name = "tabline";
    version = "1.0.0";
    src = fetchFromGitHub {
      owner = "mkitt";
      repo = "tabline.vim";
      rev = "69c9698a3240860adaba93615f44778a9ab724b4";
      sha256 = "51b8PxyKqBdeIvmmZyF2hpMBjkyrlZDdTB1opr5JZ7Y=";
    };
    dependencies = [ ];
  };
  vim = vim_configurable.customize {
    name = "vim";
    vimrcConfig = {
      customRC = ''
        set encoding=utf-8
        set termguicolors
        set backspace=indent,eol,start
        colorscheme monokai_pro

        let g:strip_whitespace_on_save=1
        let g:strip_whitespace_confirm=0

        set hlsearch
        syntax on
        nmap <C-n> :nohlsearch<CR>

        nnoremap ) :<C-R>=len(getqflist())==1?"cc":"cn"<CR><CR>
        nnoremap ( :<C-R>=len(getqflist())==1?"cc":"cp"<CR><CR>

        nnoremap <C-h> <C-w>h
        nnoremap <C-j> <C-w>j
        nnoremap <C-k> <C-w>k
        nnoremap <C-l> <C-w>l

        nnoremap <C-i> :Make<CR>
        nnoremap <C-y> :Make clean<CR>
        nnoremap <C-o> :Make format<CR>
        nnoremap <C-d> :sus<CR>
        nnoremap <C-e> :checkt<CR>
        nnoremap <C-f> :Rg<Space>
        nnoremap <C-p> :Files<CR>

        set expandtab
        set tabstop=4
        set shiftwidth=4
        set number
        " mypy https://github.com/vim-syntastic/syntastic/blob/master/syntax_checkers/python/mypy.vim
        set errorformat+=%f:%l:%c:%t:%m,

        filetype plugin indent on
        autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
        autocmd FileType make setlocal noexpandtab
                  '';
      packages.myVimPackage = with vimPlugins; {
        start = [
          fugitive
          fzf-vim
          vim-polyglot
          vim-dispatch
          vim-airline
          vim-eunuch
          auto-pairs
          vim-json
          vim-better-whitespace
          vim-monokai-pro
          tabline
        ];
      };
    };
  };
  path = stdenv.lib.makeBinPath [
    ripgrep
    bat
    git
    findutils
    coreutils
    ncurses
    bash
    file
  ];
in stdenv.mkDerivation {
  name = "vi-symlink";
  phases = "installPhase";
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    makeWrapper ${vim}/bin/vim $out/bin/vim --set PATH ${path}
    makeWrapper ${vim}/bin/vim $out/bin/vi --set PATH ${path}
    makeWrapper ${vim}/bin/vim $out/bin/view --set PATH ${path} --add-flags -R
    makeWrapper ${vim}/bin/vim $out/bin/vimdiff --set PATH ${path} --add-flags -d
  '';
}
