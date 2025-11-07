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
