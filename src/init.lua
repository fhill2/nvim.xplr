-- debug
-- local inspect = require("inspect")
-- local function log(msg)
--   local outfile = ("%s/logs/xplr.log"):format(os.getenv("HOME"))
--   local fp = io.open(outfile, "a")
--   fp:write(string.format("\n%s", inspect(msg)))
--   fp:close()
-- end

local function setup(opts)
  if os.getenv("NVIM_XPLR") then
    log("nvim-xplr setup")
    local enabled = false
    local messages = {}

    -- workaround for xplr sub modules - can't require
    package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/xplr/plugins/?.lua"

    local vim = require("nvim-xplr.vim")
    -- add luarocks to path
    local handle = io.popen("luarocks path --lr-path")
    local luarocks_path = handle:read("*a")
    package.path = package.path .. ";" .. luarocks_path

    -- -- add luarocks to cpath (--lr-cpath not exporting correct paths)
    local handle = io.popen("luarocks path")
    local output = handle:read("*a")
    local luarocks_cpath = vim.split(output, "\n")
    local luarocks_cpath = luarocks_cpath[2]:gsub([[export LUA_CPATH=%']], "")
    local luarocks_cpath = luarocks_cpath:sub(1, #luarocks_cpath - 1)
    package.cpath = package.cpath .. ";" .. luarocks_cpath

    local client
       if pcall(require, "nvim.session") then
      local Client = require("nvim-xplr.client")
      local socket_path = os.getenv("NVIM_XPLR_SERVERNAME")
      client = Client:new(socket_path)
    end

    -- open selection in nvim
    if opts.open_selection.enabled then
      xplr.fn.custom.nvim_open_selection = function(app)
        client:exec_lua([[return require'xplr.actions'.open_selection(...)]], app.selection)
      end

      xplr.config.modes.builtin[opts.open_selection.mode].key_bindings.on_key[opts.open_selection.key] = {
        help = "open in nvim",
        messages = {
          "PopMode",
          { CallLua = "custom.nvim_open_selection" },
        },
      }
    end

    -- start/stop preview
    if opts.preview.enabled then
      os.execute("[ ! -p '" .. opts.preview.fifo_path .. "' ] && mkfifo '" .. opts.preview.fifo_path .. "'")

      xplr.fn.custom.nvim_preview = function(app)
        if enabled then
          enabled = false
          client:exec_lua(
            [[return require'xplr.manager'._toggle_preview(...)]],
            { fifo_path = opts.preview.fifo_path, enabled = enabled }
          )
          messages = { "StopFifo" }
        else
                  enabled = true
          client:exec_lua(
            [[return require'xplr.manager'._toggle_preview(...)]],
            { fifo_path = opts.preview.fifo_path, enabled = enabled }
          )
          messages = {
            { StartFifo = opts.preview.fifo_path },
          }
        end
        return messages
      end

      xplr.config.modes.builtin[opts.preview.mode].key_bindings.on_key[opts.preview.key] = {
        help = "toggle nvim preview",
        messages = {
          "PopMode",
          { CallLua = "custom.nvim_preview" },
        },
      }
    end

    return client
  end
end

return { setup = setup }
