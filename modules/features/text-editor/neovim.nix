{ self, inputs, ... }: {
  flake.nixosModules.neovim = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myNeovim
    ];
    environment.variables.EDITOR = "nvim";
    environment.shellAliases = {
      vim = "nvim";
      vi = "nvim";
    };
  };

  perSystem = { pkgs, system, ... }:
    let
      nixvimModule = {
        inherit pkgs;
        module = {
          extraPackages = with pkgs; [
            nodejs
            xdg-utils
          ];

          globals = {
            mapleader = " ";
            maplocalleader = " ";
          };

          opts = {
            number = true;
            relativenumber = true;
            shiftwidth = 2;
            tabstop = 2;
            expandtab = true;
            smartindent = true;
            wrap = false;
            cursorline = true;
            termguicolors = true;
            scrolloff = 8;
            mouse = "a";
            clipboard = "unnamedplus";
            undofile = true;
            ignorecase = true;
            smartcase = true;
            updatetime = 250;
            timeoutlen = 300;
          };

          # Esquema de Cores (Catppuccin Mocha alinhado com o restante do sistema)
          colorschemes.catppuccin = {
            enable = true;
            settings = {
              flavour = "mocha";
              transparent_background = false;
            };
          };

          # Plugins essenciais para desenvolvimento e engenharia
          plugins = {
            # Realce de sintaxe avançado
            treesitter = {
              enable = true;
              settings = {
                highlight.enable = true;
                indent.enable = true;
              };
            };

            # Barra de status
            lualine = {
              enable = true;
              settings.options.theme = "catppuccin";
            };

            # Barra de buffers/abas superior
            bufferline = {
              enable = true;
            };

            # Navegação de arquivos e busca fuzzy
            telescope = {
              enable = true;
              keymaps = {
                "<leader>ff" = "find_files";
                "<leader>fg" = "live_grep";
                "<leader>fb" = "buffers";
                "<leader>fh" = "help_tags";
                "<leader>fd" = "diagnostics";
              };
            };

            # Git integrado no editor
            gitsigns = {
              enable = true;
            };

            # Dicas de atalhos em tempo real
            which-key = {
              enable = true;
            };

            # Fechamento automático de parênteses e chaves
            nvim-autopairs = {
              enable = true;
            };

            # Comentários rápidos (gcc, gc)
            comment = {
              enable = true;
            };

            # Preview no Navegador (Firefox)
            markdown-preview = {
              enable = true;
              settings = {
                auto_close = 1;
                theme = "dark";
                browser = "firefox";
              };
            };

            # Renderização nativa e visual dentro do próprio Neovim
            render-markdown = {
              enable = true;
            };

            # LSP (Language Server Protocol) para Engenharia (C/C++, Rust, Nix, Python, Bash)
            lsp = {
              enable = true;
              servers = {
                # C / C++ (Essencial para embarcados e computação)
                clangd.enable = true;

                # Rust
                rust_analyzer = {
                  enable = true;
                  installCargo = false;
                  installRustc = false;
                };

                # Nix (LSP para configurações do NixOS)
                nil_ls.enable = true;

                # Python
                pyright.enable = true;

                # Shell / Bash
                bashls.enable = true;
              };
              keymaps = {
                diagnostic = {
                  "[d" = "goto_prev";
                  "]d" = "goto_next";
                  "<leader>e" = "open_float";
                };
                lspBuf = {
                  "K" = "hover";
                  "gd" = "definition";
                  "gD" = "declaration";
                  "gi" = "implementation";
                  "gr" = "references";
                  "<leader>ca" = "code_action";
                  "<leader>rn" = "rename";
                  "<leader>f" = "format";
                };
              };
            };

            # Autocomplete moderno
            cmp = {
              enable = true;
              autoEnableSources = true;
              settings = {
                mapping = {
                  "<C-Space>" = "cmp.mapping.complete()";
                  "<C-d>" = "cmp.mapping.scroll_docs(-4)";
                  "<C-f>" = "cmp.mapping.scroll_docs(4)";
                  "<C-e>" = "cmp.mapping.close()";
                  "<CR>" = "cmp.mapping.confirm({ select = true })";
                  "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
                  "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
                };
                sources = [
                  { name = "nvim_lsp"; }
                  { name = "path"; }
                  { name = "buffer"; }
                ];
              };
            };
          };

          # Atalhos rápidos de utilidade
          keymaps = [
            {
              mode = "n";
              key = "<leader>w";
              action = "<cmd>w<cr>";
              options.desc = "Salvar arquivo";
            }
            {
              mode = "n";
              key = "<leader>q";
              action = "<cmd>q<cr>";
              options.desc = "Fechar janela";
            }
            {
              mode = "n";
              key = "<C-h>";
              action = "<C-w>h";
              options.desc = "Mover para janela esquerda";
            }
            {
              mode = "n";
              key = "<C-j>";
              action = "<C-w>j";
              options.desc = "Mover para janela abaixo";
            }
            {
              mode = "n";
              key = "<C-k>";
              action = "<C-w>k";
              options.desc = "Mover para janela acima";
            }
            {
              mode = "n";
              key = "<C-l>";
              action = "<C-w>l";
              options.desc = "Mover para janela direita";
            }
            {
              mode = "n";
              key = "<leader>mp";
              action = "<cmd>MarkdownPreviewToggle<cr>";
              options.desc = "Markdown Preview no Navegador";
            }
          ];
        };
      };
    in
    {
      packages.myNeovim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule nixvimModule;
    };
}
