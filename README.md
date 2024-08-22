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

### Exclude specific completions

```lua
cmp.cmdline.setup('@', {
    sources = cmp.config.sources({
        {
            name = 'cmdline-prompt',
            ---@type prompt.Option
            option = {
                ---@type string[]
                excludes = { 'file', 'dir' }, -- complete with 'hrsh7th/cmp-path' instead of 'cmdline-prompt'
            }
        },
        { namae = 'path' },
    },
})
```

For more detailed control, function also can be defined:
```lua
cmp.cmdline.setup('@', {
    sources = cmp.config.sources({
        {
            name = 'cmdline-prompt',
            ---@type prompt.Option
            option = {
                ---@type fun(context: cmd.Context, completion_type: string, custom_function: string)
                excludes = function(context, completion_type, custom_function)
                    if completion_type == 'file' or completion_type == 'dir' then
                        return true
                    end
                    return false
                end
            }
        },
        { namae = 'path' }
    },
})
```

Arguments:
1. `context` (`cmd.Context`): See: [context.lua](https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/context.lua) in [nvim-cmp].  
   you can get `bufnr`, `filetype` ...etc.
2. `completion_type` (`string`): See: `:help getcompletion()`
3. `custom_function` (`string`): when the completion type is `custom` or `customlist`

[nvim-cmp]: https://github.com/hrsh7th/nvim-cmp "hrsh7th/nvim-cmp: A completion plugin for neovim coded in Lua."
