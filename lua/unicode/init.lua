local utf8 = require 'lua-utf8'
local fmt = string.format

CATEGORIES_PATH = "data/categories"
CHARACTERS_PATH = "data/UnicodeData.txt"

local categories = nil
local characters = nil -- Loaded when this is not nil

local M = {}

M.default_opts = {
    notify_min_level = vim.log.levels.INFO,
}

M.opts = {}

local NOTIFICATION_NAME = "unicode.nvim"
local function log(msg, level)
    -- Filtering for this plugin only
    if level >= M.opts.notify_min_level then
        vim.notify(NOTIFICATION_NAME.. ": " .. msg, level);
    end
end

local function log_trace(msg)
    log(msg, vim.log.levels.TRACE)
end

local function log_debug(msg)
    log(msg, vim.log.levels.DEBUG)
end

local function log_info(msg)
    log(msg, vim.log.levels.INFO)
end

local function log_warn(msg)
    log(msg, vim.log.levels.WARN)
end

local function log_error(msg)
    log(msg, vim.log.levels.ERROR)
end


function path_exists(rpath)
    local paths = vim.api.nvim_get_runtime_file(rpath, false)
    return #paths > 0
end

function get_path(rpath)
    local paths = vim.api.nvim_get_runtime_file(rpath, false)
    if #paths == 0 then
        error("Error loading: "..rpath)
    end
    return paths[1]
end

function contains(table, value)
  for i = 1,#table do
    if (table[i] == value) then
      return true
    end
  end
  return false
end

function get_lines(data)
    local lines = {}
    for s in data:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end
    return lines
end

function load_categories()

    -- Load Unicode category map
    local categories = {}
    for line in io.lines(get_path(CATEGORIES_PATH)) do
        local _, _, abbr, category = line:find("^(..) (.*)")
        categories[abbr] = category
    end
    return categories
end


function load_characters(categories)
    local utf8 = require 'lua-utf8'

    local options = {}
    for line in io.lines(get_path(CHARACTERS_PATH)) do
        local data = split(line, ";")
        -- print(vim.inspect(split(line, ";")))

        -- Generate Name
        local name = data[2]
        local name_1 = data[11]
        if name_1 ~= nil then
            if name_1 ~= "" then
                if name == "<control>" then
                    -- Nice to use Unicode 1.0 names for characters that have the name: <control>
                    name = name_1
                end
            end
        end

        -- Generate desc from name/category
        local category_abbr = data[3]

        local category = category_abbr

        if categories[category_abbr] ~= nil then
            category = string.format("%s - %s", category_abbr, categories[category_abbr])
        end

        local desc = string.format("%s (%s)", name, category)

        -- Generate fzf_line for fzf (Use tab delimiter instead of ; for generated lines)
        local code = data[1]
        local character = utf8.char(tonumber(code, 16))

        if category_abbr == "Cc" then
            character = " "
        end

        local fzf_line = string.format("%s	%-80s	%s (%s)", code, desc, character, code)
        table.insert(options, fzf_line)
    end

    return options
end



load_unicode = function()
    -- Set the globals in one shot
    categories = load_categories()
    characters = load_characters(categories)
    log_info("Loaded Unicode categories and characters");
end

M.select_unicode = function()
    local utf8 = require 'lua-utf8'

    if characters == nil then
        log_error("Unicode characters not loaded")
        return
    end

    local start_mode = vim.api.nvim_get_mode().mode
    log_trace("Starting in mode: "..start_mode)

    if vim.api.nvim_get_mode().mode == 'i' then
        key = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
        -- n: no remap
        -- x: Execute commands until typeahead is empty (critical)
        vim.api.nvim_feedkeys(key, 'nx', false)
    end

    local mode = vim.api.nvim_get_mode().mode
    log_trace("Starting select in mode: "..mode)

    vim.ui.select(characters, {
        prompt = "Select a character to enter:",
        kind = "unicode_select",
    }, function(choice)
        if choice then
            local s, e, char = string.find(choice, "([^%s]+)	")

            if s == nil then
                log_error("Error parsing choice")
            else
                log_trace(string.format("Found %s at (%d, %d) in %s", char, s, e, choice))
                local code = tonumber(char, 16)
                if code then
                    -- telescope will always be in normal mode (n)
                    -- fzf-lua   will always be in terminal mode (t)
                    local callback_mode = vim.api.nvim_get_mode().mode
                    log_trace("Handling selection in mode: "..callback_mode)

                    if callback_mode == 'n' then
                        -- Handle telescope
                        if start_mode == 'n' then
                            vim.api.nvim_feedkeys("i", "n", true)
                        else
                            if start_mode == 'i' then
                                vim.api.nvim_feedkeys("a", "n", true)
                            end
                        end
                    end

                    if callback_mode == 't' then
                        -- Handle fzf-lua
                        vim.api.nvim_feedkeys("i", "n", true)
                    end

                    vim.api.nvim_feedkeys(utf8.char(code), "n", true)

                    if start_mode == 'n' then
                        key = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
                        vim.api.nvim_feedkeys(key, 'n', false)

                        -- move to the left one char (may not work if we're at the end of a line, but no error)
                        vim.api.nvim_feedkeys("l", "n", true)
                    end

                    -- Move curor over by the byte size of the selected character
                    -- local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                    -- local offset = string.len(utf8.char(code))
                    -- vim.api.nvim_win_set_cursor(0, {row, col + offset})
                else
                    log_error(string.format("Code %s is not a number.", char));
                end
            end
        end
    end)
end

M.setup = function(opts)
    M.opts = vim.tbl_deep_extend('keep', opts, M.default_opts)

    if not path_exists(CATEGORIES_PATH) then
        log_error("Could not find " .. CATEGORIES_PATH)
        return
    end

    if not path_exists(CHARACTERS_PATH) then
        log_error("Could not find " .. CHARACTERS_PATH)
        return
    end

    vim.schedule(load_unicode)
end

return M
