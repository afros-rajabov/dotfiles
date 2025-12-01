return {
    "tokyonight.nvim",
    opts = function()
        local transparent_enabled = false -- default state

        return {
            transparent = transparent_enabled,
            styles = {
                sidebars = transparent_enabled and "transparent" or "dark",
                floats = transparent_enabled and "transparent" or "dark",
            },
        }
    end,
    config = function(plugin, opts)
        require("tokyonight").setup(opts)

        -- Toggle function
        local function toggle_transparency()
            -- Toggle the state
            _G.tokyonight_transparent = not (_G.tokyonight_transparent or false)

            -- Re-setup the theme with new transparency setting
            require("tokyonight").setup({
                transparent = _G.tokyonight_transparent,
                styles = {
                    sidebars = _G.tokyonight_transparent and "transparent" or "dark",
                    floats = _G.tokyonight_transparent and "transparent" or "dark",
                },
            })

            -- Reload the colorscheme
            vim.cmd("colorscheme tokyonight")

            vim.notify("Transparency: " .. (_G.tokyonight_transparent and "ON" or "OFF"))
        end

        -- Set keymap
        vim.keymap.set("n", "<leader>bg", toggle_transparency, { desc = "Toggle transparency" })
    end,
}
