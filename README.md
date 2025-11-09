This Neovim plugin provides the user with the capability to select a Unicode character to be added to the current buffer.

![unicode.nvim UI Screenshot](https://github.com/cskeeters/i/blob/master/unicode.nvim-screenshot.webp?raw=true "unicode.nvim UI Screenshot")

This is helpful for entering:

* [Non-breaking spaces](https://en.wikipedia.org/wiki/Non-breaking_space)
* [Non-breaking hyphens](https://en.wikipedia.org/wiki/Hyphen#Nonbreaking_hyphens)
* [word joiners](https://en.wikipedia.org/wiki/Word_joiner)
* [zero-width spaces](https://en.wikipedia.org/wiki/Zero-width_space)
* Footnote markers (✝)
* Arrows (→ ↣)
* Fleurons (𐡸 𐫱 𐡷)
* Symbols (❖ »)
* Math Symbols (𝛀 𝚫 ≠ ∑ ∫)
* Emoji (with [Fitzpatrick modifier sequences](https://emojipedia.org/emoji-modifier-sequence)) (👍👍🏻)

# How it works

The plugin creates a list of characters from `data/UnicodeData.txt` that is provided to `vim.ui.select`.  The plugin assumes that the user has replaced this with [telescope](https://github.com/nvim-telescope/telescope.nvim)'s [ui-select extension](https://github.com/nvim-telescope/telescope-ui-select.nvim) or [fzf-lua](https://github.com/ibhagwan/fzf-lua).

> [!WARNING]
> Neovim's default UI requires the user to scroll through too many pages of characters before making a selection which is painful.

# Configuration

```lua
-- function is required so that require('unicode') will only execute when key
-- is pressed after lua is initialized.
local function select_unicode()
    require('unicode').select_unicode()
end

return {
    enabled = true,
    'cskeeters/unicode.nvim',
    lazy = false, -- Not lazy so that categories and characters can be loaded asynchronously

    keys = {
      { mode = {"n", "i"}, "<C-S-u>", select_unicode, desc = "Select Unicode" },
    },

    opts = {
        notify_min_level = vim.log.levels.INFO,
    },
}
```


## fzf-lua

```lua
return {
  "ibhagwan/fzf-lua",
  config = function()
    require("fzf-lua").setup({
        winopts = {
            fullscreen = true,
        },
    })

    -- Replace vim.ui.select menu
    require("fzf-lua").register_ui_select()

  end
}
```

## telescope

```lua
return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-ui-select.nvim',
    },

    init = function()
        require("telescope").setup({
            defaults = {
                layout_strategy = 'horizontal',
                layout_config = {
                    height = 0.99,
                    width = 0.99,
                },
                sorting_strategy = "ascending",
            },
        })

        -- Replace vim.ui.select menu
        require('telescope').load_extension('ui-select')
    end
}
```

# Dependencies

This plugin depends on [starwing/luautf8](https://github.com/starwing/luautf8), which can be installed via [LuaRocks](https://luarocks.org/).

> [!IMPORTANT]
> Neovim uses Lua 5.1, so you have to pass that flag to `luarocks`.

What I do is install the rock on the command line and then make sure `package.cpath` is set properly in Neovim's configuration (`init.lua`).


```bash
luarocks install luautf8 --lua-version=5.1 --local CFLAGS="$(CFLAGS) -std=c99 -fPIC" [--local]
```

> [!NOTE]
> CFLAGS is **not** necessary unless your compiling on gnu < 5.0.


## Neovim Configuration for Local Installation

```lua
local HOME = os.getenv("HOME")
package.cpath = package.cpath .. ";" ..  HOME .. "/.luarocks/lib/lua/5.1/?.so"   -- macOS
package.cpath = package.cpath .. ";" ..  HOME .. "/.luarocks/lib64/lua/5.1/?.so" -- Linux
```

## Neovim Configuration for Global installation

```lua
package.cpath = package.cpath .. ";/usr/lib64/lua/5.1/?.so" -- Linux
```

> [!TIP]
> The path may vary by OS/Distribution.  You can check your path with 
> ```bash
> luarocks path --lua-version=5.1
> ```
