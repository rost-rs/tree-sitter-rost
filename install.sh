#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "==> [tree-sitter-rost] Installing parser & queries..."

# 0. Sincronizar URL de repositorio dinamicamente en README.md si existe remote.origin.url
REPO_URL="$(git config --get remote.origin.url 2>/dev/null || echo "")"
if [ -n "$REPO_URL" ] && [ -f "$SCRIPT_DIR/README.md" ]; then
    DOC_URL="$(echo "$REPO_URL" | sed -E 's|git@github.com:|https://github.com/|')"
    sed -i -E "s|https://github.com/[^/]+/tree-sitter-rost(\.git)?|$DOC_URL|g" "$SCRIPT_DIR/README.md" 2>/dev/null || true
fi

# 1. Compilar e instalar parser en runtime de Neovim
mkdir -p "$HOME/.local/share/nvim/site/parser"
gcc -O3 -fPIC -shared -I "$SCRIPT_DIR/src" "$SCRIPT_DIR/src/parser.c" -o "$HOME/.local/share/nvim/site/parser/rost.so"
echo "  ✓ Parser compilado: $HOME/.local/share/nvim/site/parser/rost.so"

# 2. Copiar queries
mkdir -p "$HOME/.config/nvim/queries/rost"
cp -r "$SCRIPT_DIR"/queries/* "$HOME/.config/nvim/queries/rost/"
echo "  ✓ Queries instaladas: $HOME/.config/nvim/queries/rost/"

# 3. Generar configuracion de Neovim con icono individual sin hardcoding personal
mkdir -p "$HOME/.config/nvim/lua/plugins"
cat << EOF > "$HOME/.config/nvim/lua/plugins/rost.lua"
-- 1. Reconocimiento nativo de la extension .rost
vim.filetype.add({
    extension = {
        rost = "rost",
    },
})

-- 2. Activar Tree-sitter Highlighting y LSP automaticamente al abrir archivos .rost
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

-- 3. Registro del icono oficial de Rost (Path de referencia: assets/rost.svg)
-- Codepoint Nerd Font U+E68B generado programaticamente para evitar glifos rotos en texto
local rost_icon = vim.fn.nr2char(0xe68b)

pcall(function()
    local mini = require("mini.icons")
    mini.setup({
        file = {
            [".rost"] = { glyph = rost_icon, hl = "MiniIconsOrange" },
        },
        filetype = {
            rost = { glyph = rost_icon, hl = "MiniIconsOrange" },
        },
        extension = {
            rost = { glyph = rost_icon, hl = "MiniIconsOrange" },
        },
    })
end)

pcall(function()
    local devicons = require("nvim-web-devicons")
    devicons.set_icon({
        rost = {
            icon = rost_icon,
            color = "#e55f28",
            cterm_color = "208",
            name = "Rost",
        },
    })
end)

return {
    -- 4. Soporte de iconos en LazyVim via mini.icons (Neo-tree, Snacks, Bufferline)
    {
        "nvim-mini/mini.icons",
        opts = {
            file = {
                [".rost"] = { glyph = rost_icon, hl = "MiniIconsOrange" },
            },
            filetype = {
                rost = { glyph = rost_icon, hl = "MiniIconsOrange" },
            },
            extension = {
                rost = { glyph = rost_icon, hl = "MiniIconsOrange" },
            },
        },
    },

    -- 5. Fallback para nvim-web-devicons
    {
        "nvim-tree/nvim-web-devicons",
        opts = {
            override = {
                rost = {
                    icon = rost_icon,
                    color = "#e55f28",
                    cterm_color = "208",
                    name = "Rost",
                },
            },
        },
    },

    -- 6. Registro de parser en nvim-treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            local parsers = require("nvim-treesitter.parsers")
            local parser_config = parsers.get_parser_configs and parsers.get_parser_configs() or parsers

            parser_config.rost = {
                install_info = {
                    url = "$SCRIPT_DIR",
                    files = { "src/parser.c" },
                    generate_requires_npm = false,
                },
                filetype = "rost",
            }
        end,
    },
}
EOF
echo "  ✓ Configuracion instalada: $HOME/.config/nvim/lua/plugins/rost.lua"
echo "==> [tree-sitter-rost] Setup completado exitosamente!"
