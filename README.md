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

# Usage

In NORMAL mode, trigger `select_unicode`, and an FZF menu will appear that allows you to filter characters by name and choose a character to be inserted.

NOTE: It does not currently work in INSERT mode.


# Configuration

```lua
return {
    enabled = true,
    'cskeeters/unicode.nvim',
    lazy = false, -- Not lazy so that categories and characters can be loaded asynchronously

    keys = {
      { "<leader><leader>u", function()
          require('unicode').select_unicode()
      end, desc = "Select Unicode" },
    },

    opts = {
        notify_min_level = vim.log.levels.INFO,
    },
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
package.cpath = package.cpath .. ";" ..  HOME .. "/.luarocks/lib/lua/5.1/?.so"
```

## Global installation

```lua
package.cpath = package.cpath .. ";/usr/lib64/lua/5.1/?.so"
```

> [!TIP]
> The path may vary by OS/Distribution.  You can check your path with 
> ```bash
> luarocks path --lua-version=5.1
> ```
