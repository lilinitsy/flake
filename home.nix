{ lib, pkgs, ... }:

{
  fonts.fontconfig.enable = true;

  home = {
    file.".gdbinit".text = ''
      set disassembly-flavor intel
      set history save on
      set history filename ~/.gdb_history
    '';
    packages = [
      # system-wide android
      pkgs.android-studio

      # clang
      pkgs.clang-tools

      # debugging tools
      pkgs.gdb
      pkgs.strace
      pkgs.valgrind

      # graphics stuff
      pkgs.ffmpeg-full
      pkgs.gimp
      pkgs.mesa-demos
      pkgs.renderdoc
      pkgs.shaderc
      pkgs.nv-codec-headers-11
      pkgs.vulkan-tools
      pkgs.vulkan-tools-lunarg
      pkgs.vulkan-validation-layers

      # misc
      pkgs.curl
      pkgs.file
      pkgs.linuxPackages.perf
      pkgs.man-pages
      pkgs.man-pages-posix
      pkgs.python3
      pkgs.time
      pkgs.tokei
      pkgs.tree

      # X stuff
      pkgs.arandr
      pkgs.discord
      pkgs.google-chrome
      pkgs.hexchat
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk
      pkgs.noto-fonts-emoji
      pkgs.pavucontrol
      pkgs.pinentry-gtk2 # for GPG to prompt for passwords
      pkgs.slack
      pkgs.vlc
      pkgs.vscode
      pkgs.xfce.xfce4-terminal
      pkgs.zathura
      pkgs.zoom-us

      # occasionally-used networking utilities
      pkgs.iperf3
      pkgs.nmap
      pkgs.socat
      pkgs.tcpdump

      # posix utility replacements
      pkgs.bottom
      pkgs.exa
      pkgs.fd
      pkgs.hexyl
      pkgs.ripgrep
    ];

    # Don't change me, see comment in configuration.nix.
    stateVersion = "22.05";
  };

  programs = {
    autojump.enable = true;

    bat = {
      enable = true;
      config.theme = "ansi";
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    firefox = {
      enable = true;
      package = pkgs.wrapFirefox
        (if lib.elem pkgs.system pkgs.firefox-bin-unwrapped.meta.platforms then
          pkgs.firefox-bin-unwrapped
        else
          pkgs.firefox-unwrapped) {
            applicationName = "firefox";
            extraPolicies = {
              DisablePocket = true;
              FirefoxHome = {
                Highlights = false;
                Pocket = false;
                Snippets = false;
              };
              UserMessaging = {
                ExtensionRecommendations = false;
                SkipOnboarding = true;
              };
            };
          };
    };

    gpg.enable = true;

    neovim = {
      enable = true;
      extraConfig = ''
        set clipboard=unnamedplus
        set foldlevel=999
        set foldmethod=syntax
        set nojoinspaces
        set modeline
        set mouse=a
        set number
        set relativenumber
        set title
        set undofile
        set undolevels=1000000

        nnoremap <space><space> :w<cr>

        nnoremap <f1> :bp<cr>
        inoremap <f1> <esc>:bp<cr>

        nnoremap <f2> :bn<cr>
        inoremap <f2> <esc>:bn<cr>
      '';
      extraPackages = [
        pkgs.ccls
        pkgs.clang-tools # for clang-format
        pkgs.nixfmt
        pkgs.rust-analyzer
        pkgs.rustfmt
        pkgs.rustup
      ];
      plugins = [
        { plugin = pkgs.vimPlugins.ctrlp; }
        {
          plugin = pkgs.vimPlugins.neoformat;
          config = ''
                        augroup fmt
                          autocmd!
                          autocmd BufWritePre * | Neoformat
                        augroup END
                        let g:neoformat_haskell_ormolu = {'exe':'ormolu','args':[]}
                        let g:neoformat_enabled_go = ['goimports']
                        let g:neoformat_enabled_haskell = ['ormolu']
                        let g:neoformat_enabled_javascript = ['denofmt']
                        let g:neoformat_enabled_markdown = []
                        let g:neoformat_enabled_ocaml = ['ocamlformat']
                        let g:neoformat_enabled_python = ['black']
                        let g:neoformat_enabled_rust = ['rustfmt']
                        let g:neoformat_rust_rustfmt = {
                          \ 'exe': 'rustfmt',
                          \ 'args': ['--edition', '2018'],
                          \ 'stdin': 1,
                          \ }
            	  '';
        }
        {
          plugin = pkgs.vimPlugins.nerdtree;
          config = "noremap <tab> :NERDTreeToggle<cr>";
        }
        {
          plugin = pkgs.vimPlugins.nvim-lspconfig;
          config = ''
            lua << EOF
                local nvim_lsp = require('lspconfig')
                local on_attach = function(client, bufNumber)
                  vim.api.nvim_buf_set_option(bufNumber, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

                  local function buf_set_keymap(...)
                    vim.api.nvim_buf_set_keymap(bufNumber, ...)
                  end

                  local opts = { noremap=true, silent=true }
                  buf_set_keymap('n', '<leader>qf', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
                  buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
                  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
                  buf_set_keymap('n', '[g', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
                  buf_set_keymap('n', ']g', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
                  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
                  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)

                  if client.resolved_capabilities.document_highlight then
                    vim.api.nvim_exec([[
                      hi LspReferenceRead cterm=bold ctermbg=yellow guibg=LightYellow
                      hi LspReferenceText cterm=bold ctermbg=yellow guibg=LightYellow
                      hi LspReferenceWrite cterm=bold ctermbg=yellow guibg=LightYellow
                      augroup lsp_document_highlight
                        autocmd!
                        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
                      augroup END
                    ]], false)
                  end
                end
                for _, lsp in ipairs({'ccls', 'denols', 'gopls', 'hls', 'jdtls', 'ocamllsp', 'pyright', 'rust_analyzer', 'tsserver'}) do
                  nvim_lsp[lsp].setup({ on_attach = on_attach })
                end
            EOF
          '';
        }
        pkgs.vimPlugins.quick-scope
        {
          plugin = pkgs.vimPlugins.vim-airline;
          config = ''
            let g:airline_powerline_fonts = 0
            let g:airline#extensions#tabline#enabled = 1
          '';
        }
        {
          plugin = pkgs.vimPlugins.vim-airline-themes;
          config = ''
            let g:airline_theme='dark_minimal'
          '';
        }
        pkgs.vimPlugins.vim-fugitive
        pkgs.vimPlugins.vim-gitgutter
        pkgs.vimPlugins.vim-nix
      ];
    };

    ssh.enable = true;

    tmux = {
      enable = true;
      escapeTime = 10;
      newSession = true;
      extraConfig = ''
        set -g mouse on
      '';
    };

    zsh = {
      enable = true;
      initExtra = ''
        PATH="$HOME/.local/bin:$HOME/bin:$PATH"
      '';
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "af-magic";
      };
    };
  };

  services = {
    gpg-agent.enable = true;

    network-manager-applet.enable = true;

    udiskie = {
      enable = true;
      tray = "always";
    };
  };

  xsession.enable = true;
}
