local cmp = require('cmp')

---@class prompt.Option
---@field public excludes? string[]|fun(context: cmp.Context, completion_type: string, custom_function: string) : boolean
---@field public kinds? prompt.OptionKind

---see `:help getcompletion()`
---@class prompt.OptionKind
---@field public buffer?        prompt.OptionKindItem|lsp.CompletionItemKind
---@field public color?         prompt.OptionKindItem|lsp.CompletionItemKind
---@field public command?       prompt.OptionKindItem|lsp.CompletionItemKind
---@field public dir?           prompt.OptionKindItem|lsp.CompletionItemKind
---@field public environment?   prompt.OptionKindItem|lsp.CompletionItemKind
---@field public event?         prompt.OptionKindItem|lsp.CompletionItemKind
---@field public expression?    prompt.OptionKindItem|lsp.CompletionItemKind
---@field public file?          prompt.OptionKindItem|lsp.CompletionItemKind
---@field public file_in_path?  prompt.OptionKindItem|lsp.CompletionItemKind
---@field public filetype?      prompt.OptionKindItem|lsp.CompletionItemKind
---@field public function?      prompt.OptionKindItem|lsp.CompletionItemKind
---@field public help?          prompt.OptionKindItem|lsp.CompletionItemKind
---@field public highlight?     prompt.OptionKindItem|lsp.CompletionItemKind
---@field public history?       prompt.OptionKindItem|lsp.CompletionItemKind
---@field public keymap?        prompt.OptionKindItem|lsp.CompletionItemKind
---@field public locale?        prompt.OptionKindItem|lsp.CompletionItemKind
---@field public mapclear?      prompt.OptionKindItem|lsp.CompletionItemKind
---@field public mapping?       prompt.OptionKindItem|lsp.CompletionItemKind
---@field public menu?          prompt.OptionKindItem|lsp.CompletionItemKind
---@field public packadd?       prompt.OptionKindItem|lsp.CompletionItemKind
---@field public runtime?       prompt.OptionKindItem|lsp.CompletionItemKind
---@field public scriptnames?   prompt.OptionKindItem|lsp.CompletionItemKind
---@field public shellcmd?      prompt.OptionKindItem|lsp.CompletionItemKind
---@field public sign?          prompt.OptionKindItem|lsp.CompletionItemKind
---@field public syntax?        prompt.OptionKindItem|lsp.CompletionItemKind
---@field public syntime?       prompt.OptionKindItem|lsp.CompletionItemKind
---@field public tag?           prompt.OptionKindItem|lsp.CompletionItemKind
---@field public tab_listfiles? prompt.OptionKindItem|lsp.CompletionItemKind
---@field public user?          prompt.OptionKindItem|lsp.CompletionItemKind
---@field public var?           prompt.OptionKindItem|lsp.CompletionItemKind
---@field public custom?        prompt.OptionKindItem|lsp.CompletionItemKind
---@field public customlist?    prompt.OptionKindItem|lsp.CompletionItemKind

---CompletionItemKind and custom Highlight group name
---@class prompt.OptionKindItem
---@field public kind lsp.CompletionItemKind
---@field public hl_group? string

---@class cmp.Source
local source = {}

---@return cmp.Source
source.new = function ()
    return setmetatable({}, { __index = source })
end

---cmp.Context
---
---See nvim-cmp: https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/context.lua
---@class cmp.Context
---@field public id string
---@field public cache cmp.cache
---@field public prev_context cmp.Context
---@field public option table
---@field public filetype string
---@field public time integer
---@field public bufnr integer
---@field public cursor vim.Position|lsp.Position
---@field public cursor_line string
---@field public curor_after_line string
---@field public curor_before_line string
---@field public aborted boolean

---cmp.SourceConfig mixed in completion_context, context and offset
---
---See nvim-cmp: https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/types/cmp.lua
---@class cmp.SourceConfigEx
---@field public name string 
---@field public option prompt.Option|nil
---@field public priority integer|nil
---@field public trigger_characters string|nil
---@field public keyword_pattern string|nil
---@field public keyword_length integer|nil
---@field public max_item_count integer|nil
---@field public group_index integer|nil
---@field public entry_filter nil|fun(entry: cmp.Entry, ctx: cmp.Context) : boolean
---// mix-in
---@field public completion_context lsp.CompletionContext
---@field public context cmp.Context
---@field public offset integer


---@param params cmp.SourceConfigEx
---@param callback fun(response: lsp.CompletionList|lsp.CompletionItem[]|nil)
source.complete = function(_, params, callback)
    local cmdline = params.context.cursor_line
    local compl_type = vim.fn.getcmdcompltype()

    local custom_function = ''
    local completion_type = compl_type
    local i = string.find(compl_type, ',', 1, true)
    if i then
        custom_function = string.sub(compl_type, i + 1)
        completion_type = string.sub(compl_type, 1, i -1)
    end

    local option = params.option or {}
    local excludes_type = type(option.excludes)
    if excludes_type == 'table' then
        for _, name in ipairs(option.excludes) do
            if name == completion_type then
                return callback()
            end
        end
    elseif excludes_type == 'function' and option.excludes(params.context, completion_type, custom_function) then
        return callback()
    end

    local items = vim.fn.getcompletion(cmdline, compl_type)
    local cmpItems = {}
    ---@type prompt.OptionKindItem
    local opt_kind = (option.kinds or {})[completion_type]
    local kind = cmp.lsp.CompletionItemKind.Text
    local hl_group = 'CmpItemKindText'
    if opt_kind then
        if type(opt_kind) == 'table' then
            kind = opt_kind.kind or 1
            hl_group = opt_kind.hl_group or ('CmpItemKind' .. (cmp.lsp.CompletionItemKind[kind] or ''))
        elseif type(opt_kind) == 'number' then
            kind = opt_kind
            hl_group = ('CmpItemKind' .. (cmp.lsp.CompletionItemKind[kind] or ''))
        end
    end
    for _, item in ipairs(items) do
        table.insert(cmpItems, {
            label = item,
            kind = kind,
            data = {
                completion_type = completion_type,
                custom_function = custom_function,
                bufnr = params.context.bufnr,
                filetype = params.context.filetype
            },
            cmp = {
                kind_text = completion_type,
                kind_hl_group = hl_group
            },
            -- -- for debugging
            -- documentation = {
            --     kind = 'markdown',
            --     value = '```yaml\n' ..
            --     'label    : "' .. item.. '"\n' ..
            --     'kind     : ' .. kind .. '\n' ..
            --     'hl_group : ' .. hl_group .. '\n' ..
            --     'cmpl_type: ' .. completion_type .. '\n' ..
            --     'function : "' .. custom_function .. '"\n' ..
            --     '```'
            -- },
        })
    end
    callback(cmpItems)
end

return source
