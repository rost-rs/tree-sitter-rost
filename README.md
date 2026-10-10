# tree-sitter-rost

Tree-sitter grammar, AST parser, and syntax highlighting queries for the **`.rost`** declarative styling and configuration language.

---

## Features

- **⚡ Blazing Fast Parsing:** Pure C AST parser generated from Tree-sitter ABI 15 with zero allocation during token scanning.
- **🎨 Comprehensive Syntax Highlighting:**
  - **Directives:** `@theme`, `@version`, `@author`, `@engine`, `@palette`, `@rule`, `@import`, `@extends`, `@breakpoint`.
  - **Selectors:** `#window`, `#button.primary`, `#card`, `#palette`, `#badge`, `#counter_button`.
  - **Properties:** Dimensions, box model (`padding [ ... ]`), hex colors (`#1e1e2e`), typography, constraints, and animations.
  - **Enums & States:** Pipe-delimited variant sets (`state | idle, hover, active, disabled |`).
  - **Reactive Bindings:** Event expressions (`on_click = emit_submit(id: 42)`).
- **📂 Code Folding:** Automatic code folding for scoped blocks `{ ... }`, lists `[ ... ]`, and enum variant sets `| ... |`.
- **🏷️ Official File Icon:** Dedicated vector icon in [`assets/rost.svg`](assets/rost.svg) (PNG: [`assets/rost.png`](assets/rost.png)) with native integration for Neovim file explorers (`mini.icons`, `nvim-web-devicons`, Neo-tree, Snacks).

---

## Grammar Syntax & Language Specification

```rost
// Directives
@theme "cyber-synthwave-dark"
@author "utilrs"
@version "1.0.0"

// Component Blocks and Scoped Selectors
#button.primary {
    width: 140px,
    height: 44px,
    bg: #1e1e2e,
    color: #ffffff,
    border_radius: 8px,
    opacity: 0.95,
    
    // States and enums
    state | idle, hover, active, disabled |,
    
    // Box model lists
    padding [ 8px, 16px ],
    margin [ 0px, 8px ],
    
    // Functional and reactive bindings
    on_click = emit_submit(id: 42)
}
```

### Directives Reference

| Directive | Description | Syntax Example |
| :--- | :--- | :--- |
| `@theme` | Sets active visual theme or token scope identifier | `@theme "cyber-dark"` |
| `@version` | Specifies semantic version metadata | `@version "1.0.0"` |
| `@author` | Declares author or organization maintainer | `@author "utilrs"` |
| `@engine` | Target native UI engine (`gpui`, `egui`, `iced`, `slint`, `bevy`) | `@engine "gpui"` |
| `@palette` | Root color token palette dictionary block | `@palette { bg: #1e1e2e }` |
| `@rule` | Declares an AST linting or static analysis rule | `@rule "enforce-tokens"` |
| `@import` | Imports and merges an external `.rost` file | `@import "tokens/palette.rost"` |
| `@extends` | Inherits rules from a parent component or theme block | `@extends "#button.base"` |
| `@breakpoint` | Declares responsive media query conditions | `@breakpoint "compact" { ... }` |

### Core Properties & Attributes

| Category | Properties | Units / Values |
| :--- | :--- | :--- |
| **Dimensions** | `width`, `height`, `min_width`, `max_width`, `min_height`, `max_height` | `px`, `rem`, `em`, `%`, `vw`, `vh` |
| **Colors** | `bg`, `color`, `text_color`, `border_color`, palette tokens (`bg_*`, `text_*`, `accent*`) | `#RGB`, `#RRGGBB`, `#RRGGBBAA` |
| **Shape & Border** | `border_radius`, `border_width` | `px`, `%` |
| **Box Model** | `padding`, `margin`, `padding_top`, `padding_bottom`, `margin_top`, `margin_bottom` | `[ v, h ]`, `[ t, r, b, l ]`, `px` |
| **Typography** | `font_size`, `font_weight`, `font_family`, `line_height`, `letter_spacing`, `text_align` | `px`, `rem`, `normal`, `bold`, `100`-`900` |
| **Layout Flow** | `display`, `flex_direction`, `align_items`, `justify_content`, `gap`, `overflow` | `flex`, `grid`, `row`, `column`, `center` |
| **Visual Effects** | `opacity`, `visibility`, `elevation`, `box_shadow` | `0.0`..`1.0`, `visible`, `hidden`, `4`, `8` |
| **States** | `state \| idle, hover, active, disabled, focused, selected \|` | Pipe-delimited enum |
| **Events** | `on_click`, `on_hover`, `on_change`, `on_submit` | Functional expression |

---

## Installation & Setup

### 1. Automated Installation (Recommended)

Run the included installation script from within the repository:

```bash
git clone https://github.com/rost-rs/tree-sitter-rost.git
cd tree-sitter-rost
./install.sh
```

This compiles the parser to `~/.local/share/nvim/site/parser/rost.so`, copies queries to `~/.config/nvim/queries/rost/`, and configures `~/.config/nvim/lua/plugins/rost.lua` with filetype detection, treesitter registration, and the dedicated single-character Rost icon (`assets/rost.svg`).

---

### 2. Manual Build and Install Shared Library for Neovim

Neovim loads compiled Tree-sitter parsers (`.so`) from its runtime `parser/` directory.

Compile and copy the parser directly:

```bash
cd tree-sitter-rost
mkdir -p ~/.local/share/nvim/site/parser
gcc -O3 -fPIC -shared -I src src/parser.c -o ~/.local/share/nvim/site/parser/rost.so
```

Copy the highlight, fold, and indent queries into Neovim's query directory:

```bash
mkdir -p ~/.config/nvim/queries/rost
cp queries/* ~/.config/nvim/queries/rost/
```

---

### 3. Neovim / LazyVim Complete Configuration

Create `~/.config/nvim/lua/plugins/rost.lua`:

```lua
-- 1. Native .rost filetype detection
vim.filetype.add({
  extension = {
    rost = "rost",
  },
})

-- 2. Auto-start Tree-sitter highlighting and rost-lsp
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rost",
  callback = function(args)
    pcall(vim.treesitter.start, args.buf, "rost")
    vim.lsp.start({
      name = "rost-lsp",
      cmd = { "rost-lsp" },
      root_dir = vim.fs.root(args.buf, { ".git", "Cargo.toml" }) or vim.fn.getcwd(),
    })
  end,
})

-- 3. File Icon Setup (Vector SVG: assets/rost.svg)
-- Programmatic Nerd Font U+E68B to prevent broken/unprintable glyphs in text
local rost_icon = vim.fn.nr2char(0xe68b)

pcall(function()
  local mini = require("mini.icons")
  mini.setup({
    file = { [".rost"] = { glyph = rost_icon, hl = "MiniIconsOrange" } },
    filetype = { rost = { glyph = rost_icon, hl = "MiniIconsOrange" } },
    extension = { rost = { glyph = rost_icon, hl = "MiniIconsOrange" } },
  })
end)

pcall(function()
  local devicons = require("nvim-web-devicons")
  devicons.set_icon({
    rost = { icon = rost_icon, color = "#e55f28", cterm_color = "208", name = "Rost" },
  })
end)

return {
  -- 4. Icon integration for LazyVim (Neo-tree, Snacks, Bufferline)
  {
    "nvim-mini/mini.icons",
    opts = {
      file = { [".rost"] = { glyph = rost_icon, hl = "MiniIconsOrange" } },
      filetype = { rost = { glyph = rost_icon, hl = "MiniIconsOrange" } },
      extension = { rost = { glyph = rost_icon, hl = "MiniIconsOrange" } },
    },
  },

  -- 5. Fallback for nvim-web-devicons
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      override = {
        rost = { icon = rost_icon, color = "#e55f28", cterm_color = "208", name = "Rost" },
      },
    },
  },

  -- 6. Register parser metadata with nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      local parsers = require("nvim-treesitter.parsers")
      local parser_config = parsers.get_parser_configs and parsers.get_parser_configs() or parsers

      parser_config.rost = {
        install_info = {
          url = "https://github.com/rost-rs/tree-sitter-rost", -- or local clone path
          files = { "src/parser.c" },
          generate_requires_npm = false,
        },
        filetype = "rost",
      }
    end,
  },
}
```

---

### 3. Helix Editor

In `~/.config/helix/languages.toml`:

```toml
[[language]]
name = "rost"
scope = "source.rost"
injection-regex = "rost"
file-types = ["rost"]
comment-token = "//"
roots = [".git"]
indent = { tab-width = 4, unit = "    " }

[[grammar]]
name = "rost"
source = { path = "path/to/tree-sitter-rost" }
```

Copy queries and compile:

```bash
mkdir -p ~/.config/helix/runtime/queries/rost
cp queries/* ~/.config/helix/runtime/queries/rost/
hx --grammar build
```

---

### 4. Zed Editor

Add an extension manifest in your Zed extension directory:

```toml
# extension.toml
id = "rost"
name = "Rost"
version = "0.1.0"
schema_version = 1
authors = ["The Rost Project Contributors"]
description = "Support for .rost stylesheets and configuration language"
repository = "https://github.com/rost-rs/tree-sitter-rost"

[grammars.rost]
repository = "https://github.com/rost-rs/tree-sitter-rost"
commit = "main"
```

---

## Verifying in Neovim

Inside Neovim, check that Tree-sitter recognizes `rost`:

```vim
:lua =vim.treesitter.language.inspect("rost")
```

When visiting any `.rost` file, verify highlighting captures on the current token:

```vim
:Inspect
```

---

## License

MIT License. Copyright (c) 2026 The Rost Project Contributors.
