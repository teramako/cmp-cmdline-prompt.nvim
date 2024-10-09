# cmp-cmdline-prompt.nvim

[nvim-cmp] source for Neovim's command line `input()` prompt.

## Sample settings

```lua
local cmp = require('cmp')

-- for cmdline `input()` prompt
-- see: `:help getcmdtype()`
cmp.setup.cmdline('@', {
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
    })
})
```

### Exclude specific completions

```lua
cmp.setup.cmdline('@', {
    sources = cmp.config.sources({
        {
            name = 'cmdline-prompt',
            ---@type prompt.Option
            option = {
                ---@type string[]
                excludes = { 'file', 'dir' }, -- complete with 'hrsh7th/cmp-path' instead of 'cmdline-prompt'
            }
        },
        { name = 'path' },
    })
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
        { name = 'path' }
    })
})
```

Arguments:

1. `context` (`cmd.Context`): See: [context.lua](https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/context.lua) in [nvim-cmp].  
   you can get `bufnr`, `filetype` ...etc.
2. `completion_type` (`string`): See: `:help getcompletion()`
3. `custom_function` (`string`): function name will be supplied when the completion type is `custom` or `customlist`.

### Appearance

By default, all completion items are set as `Text` kind.
You can change by defining `option.kinds`, and also define a different highlight group than the `kind`.

Additionaly, can be shown using [lspkind].

```lua
local lspkind = require('lspkind')

cmp.setup.cmdline('@', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        {
            name = 'cmdline-prompt',
            ---@type prompt.Option
            option = {
                kinds = {
                    file = cmp.lsp.CompletionItemKind.File,
                    dir  = {
                        kind = cmp.lsp.CompletionItemKind.Folder,
                        hl_group = 'CmpItemKindEnum'
                    },
                }
            }
        },
    }),
    formatting = {
        fields = { 'kind', 'abbr', 'menu' },
        format = function(entry, vim_item)
            local item = entry:get_completion_item()
            if entry.source.name == 'cmdline-prompt' then
                vim_item.kind = cmp.lsp.CompletionItemKind[item.kind]
                local kind = lspkind.cmp_format({ mode = 'symbol_text' })(entry, vim_item)
                local strings = vim.split(kind.kind, '%s', { trimempty = true })
                kind.kind = ' ' .. (strings[1] or '')
                kind.menu = ' (' .. (item.data.completion_type or '') .. ')'
                kind.menu_hl_group = kind.kind_hl_group
                return kind
            else
                return vim_item
            end
        end
    },
})
```

[nvim-cmp]: https://github.com/hrsh7th/nvim-cmp "hrsh7th/nvim-cmp: A completion plugin for neovim coded in Lua."
[lspkind]: https://github.com/onsails/lspkind.nvim "onsails/lspkind.nvim: vscode-like pictograms for neovim lsp completion items"
