# cmp-cmdline-prompt.nvim
[nvim-cmp] source for Neovim's command line `input()` prompt.

## Sample settings

```lua
local cmp = require('cmp')

-- for cmdline `input()` prompt
-- see: `:help getcmdtype()`
cmp.cmdline.setup('@', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'cmdline-prompt' },
    },
    sorting = {
        comparators = { cmp.config.compare.order }
    },
    window = {
        completion = {
            -- "prompt: " Adjust to the number of the prompt charaters 
            -- Can't get prompt length as far as I know :(
            col_offset = 8,
        },
    },
})
```

[nvim-cmp]: https://github.com/hrsh7th/nvim-cmp "hrsh7th/nvim-cmp: A completion plugin for neovim coded in Lua."
