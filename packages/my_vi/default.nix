{ stdenv, vimUtils, fetchFromGitHub, ripgrep, vim_configurable, vimPlugins
, runtimeShell }:
let
  vim-ripgrep = vimUtils.buildVimPluginFrom2Nix {
    name = "vim-ripgrep";
    version = "1.0.2";
    src = fetchFromGitHub {
      owner = "jremmen";
      repo = "vim-ripgrep";
      rev = "ec87af6b69387abb3c4449ce8c4040d2d00d745e";
      sha256 = "1by56rflr0bmnjvcvaa9r228zyrmxwfkzkclxvdfscm7l7n7jnmh";
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

        set wildignore=*.class,*.o,
        let g:ctrlp_working_path_mode = 0
        let g:ctrlp_extensions = ['line']
        let g:rg_binary = '${ripgrep}/bin/rg'
        let g:ctrlp_user_command = '${ripgrep}/bin/rg %s --files --color=never --glob ""'
        let g:ctrlp_use_caching = 0

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
        nnoremap <C-d> :sh<CR>
        nnoremap <C-e> :checkt<CR>
        nnoremap <C-a> :CtrlPClearAllCaches<CR>
        nnoremap <C-f> :Rg<Space>

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
          ctrlp
          vim-polyglot
          vim-dispatch
          vim-airline
          vim-eunuch
          vim-ripgrep
          auto-pairs
          vim-json
          vim-better-whitespace
          vim-monokai-pro
        ];
      };
    };
  };
in stdenv.mkDerivation {
  name = "vi-symlink";
  phases = "installPhase";
  installPhase = ''
    mkdir -p $out/bin
    cd $out/bin
    mk_wrapper() {
      echo "#!${runtimeShell}" > $1
      echo "exec ${vim}/bin/vim $2 \"\$@\"" >> $1
      chmod +x $1
    }
    mk_wrapper vim
    mk_wrapper vi
    mk_wrapper view -R
    mk_wrapper vimdiff -d
  '';
}
