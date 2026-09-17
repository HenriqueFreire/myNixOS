# Guia de Navegadores Minimalistas & Baixo Consumo de RAM (NixOS)

Este documento reúne opções de navegadores otimizados para setups minimalistas, comparando consumo de memória, recursos e exemplos de configuração no NixOS.

---

## 1. Navegadores Gráficos com Foco em Teclado (*Vim-Like*)

### **Qutebrowser** (Recomendado para produtividade)
* **Motor**: Chromium/Blink (`QtWebEngine`).
* **Consumo de RAM**: ~300 MB a 600 MB.
* **Características**:
  * Totalmente operado por atalhos de teclado (`hjkl`, `f` para abrir links com hints numéricas/letras, `:d` para fechar aba, `/` para busca).
  * Bloqueador de anúncios nativo integrado (suporta listas Brave/EasyList).
  * Sem abas pesadas, interface gráfica limpa e altamente integrável com XMonad/Niri.
* **Como testar temporariamente**:
  ```bash
  nix run nixpkgs#qutebrowser
  ```
* **Exemplo de módulo NixOS**:
  ```nix
  # modules/features/qutebrowser.nix
  { ... }: {
    programs.qutebrowser = {
      enable = true;
      settings = {
        content.blocking.enabled = true;
        content.blocking.method = "both";
        colors.webpage.darkmode.enabled = true; # Opcional: força modo escuro
      };
    };
  }
  ```

---

## 2. Navegadores com Motor Gecko (Privacidade & Sem Telemetria)

### **LibreWolf**
* **Motor**: Gecko (Fork independente do Firefox).
* **Consumo de RAM**: ~500 MB a 800 MB.
* **Características**:
  * Toda a telemetria, Pocket e anúncios da Mozilla vêm desativados por padrão.
  * Extensão `uBlock Origin` já embutida e ativada nativamente.
  * Compatibilidade 100% com sites modernos, gerenciadores de senhas e aceleração VA-API da GPU Intel.
* **Como testar temporariamente**:
  ```bash
  nix run nixpkgs#librewolf
  ```
* **No NixOS**:
  ```nix
  environment.systemPackages = [ pkgs.librewolf ];
  ```

---

## 3. Navegadores Ultraleves (WebKitGTK)

### **Badwolf** / **Surf**
* **Motor**: WebKitGTK.
* **Consumo de RAM**: ~150 MB a 300 MB.
* **Características**:
  * Interface com zero decorações pesadas.
  * Excelente para consultas rápidas, leitura de documentação e wikis.
* **Como testar temporariamente**:
  ```bash
  nix run nixpkgs#badwolf
  # ou
  nix run nixpkgs#surf
  ```

---

## 4. Navegadores TUI no Terminal (Consumo < 25 MB)

Ideais para navegar em documentações, tutoriais e artigos sem precisar sair do terminal ou iniciar o ambiente gráfico.

| Navegador | Consumo | Destaque |
| :--- | :--- | :--- |
| **`w3m`** | ~15 MB | Suporte a imagens inline no terminal e navegação Vim-like |
| **`lynx`** | ~10 MB | Extremamente rápido, navegação pura em hipertexto |
| **`browsh`** | ~80 MB | Renderiza páginas modernas (incluindo vídeos) em modo texto ASCII |

* **Como testar temporariamente**:
  ```bash
  nix run nixpkgs#w3m -- https://nixos.org
  nix run nixpkgs#lynx -- https://lite.duckduckgo.com
  ```

---

## 5. Otimizações para Manter o Firefox Ultraleve

Se preferir manter o Firefox padrão, você pode reduzir o consumo de RAM em até **50%** com configurações declarativas no NixOS:

```nix
programs.firefox = {
  enable = true;
  preferences = {
    # 1. Descartar abas inativas automaticamente sob pressão de memória
    "browser.tabs.unloadOnLowMemory" = true;

    # 2. Aceleração de vídeo em hardware na GPU Intel HD 620
    "media.ffmpeg.vaapi.enabled" = true;
    "media.hardware-video-decoding.enabled" = true;

    # 3. Desativar animações desnecessárias e telemetria
    "toolkit.cosmeticAnimations.enabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "browser.ping-centre.telemetry" = false;
    "experiments.active" = false;
    "experiments.supported" = false;
  };
};
```

### Extensões Essenciais para Economia de RAM no Firefox:
1. **uBlock Origin**: Bloqueia dezenas de megabytes em scripts pesados de terceiros por aba.
2. **Auto Tab Discard**: Suspende abas que estão em segundo plano há mais de X minutos.
