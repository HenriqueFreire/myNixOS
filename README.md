# ❄️ myNixOS: Configuração Declarativa do NixOS com Flakes

Repositório pessoal de configuração do sistema operacional **NixOS**, estruturado com **Nix Flakes**, arquitetura modular (`flake-parts` + `import-tree`) e foco em reprodutibilidade, produtividade por teclado e desenvolvimento de software de alta performance.

---

## 🏗️ Arquitetura do Sistema

```text
myNixOS/
├── flake.nix                  # Ponto de entrada com flake-parts e nixvim
├── flake.lock                 # Travamento exato das versões dos inputs
└── modules/
    ├── features/              # Módulos funcionais e de aplicações
    │   ├── text-editor/       # Editor Neovim configurado declarativamente (Nixvim)
    │   ├── xmonad.nix         # Window Manager dinâmico em Haskell com xmobar
    │   ├── niri.nix           # Compositor Wayland scrollable-tiling
    │   ├── antigravity/       # Agente Antigravity CLI + integrações MCP
    │   ├── docker.nix         # Contêineres e isolamento
    │   ├── git.nix            # Controle de versão e aliases
    │   ├── android.nix        # Ferramentas Android / ADB
    │   └── terminals/         # Emuladores de terminal de baixa latência
    └── hosts/
        └── my-machine/        # Configuração de hardware e sistema da máquina principal
```

---

## 🛠️ Principais Recursos e Escolhas Técnicas

1. **Reprodutibilidade Estrita com Flakes:**
   - Construção declarativa do ambiente sem dependência de canais imperativos mutáveis (`nix-channels`).
2. **Gerenciador de Janelas Minimalista (XMonad & Niri):**
   - Configuração de atalhos ergonômicos no padrão Vim (`hjkl`), tiling automático e barra `xmobar` customizada.
3. **Editor de Texto Declarativo (Nixvim):**
   - Neovim gerenciado diretamente pela linguagem Nix, com LSPs, linters, Treesitter e WakaTime integrados.
4. **Agente de IA Integrado (Antigravity):**
   - Empacotamento customizado do agente Antigravity CLI com ferramentas essenciais (`git`, `ripgrep`, `fd`, `uv`) injetadas no path do runtime.
5. **Áudio e Mídia Modernos:**
   - Gerenciamento de som com **PipeWire** e controle de volume granular via **WirePlumber**.

---

## 🚀 Como Aplicar / Reconstruir o Sistema

Para testar ou aplicar as alterações nesta máquina:

```bash
# Rebuild e ativação imediata
sudo nixos-rebuild switch --flake .#my-machine

# Apenas teste sem alterar o bootloader
sudo nixos-rebuild test --flake .#my-machine
```

---

## 📜 Licença
Código de configuração aberto sob a licença [MIT](LICENSE) para fins educacionais e referência da comunidade Nix.
