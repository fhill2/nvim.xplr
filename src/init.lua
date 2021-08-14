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
    local enabled = false
    local messages = {}
    local home = os.getenv("HOME")
    local root = ("%s%s"):format(home, "/.config/xplr/plugins/nvim-xplr")

    -- workaround for xplr sub modules - can't require
    package.path = package.path .. ";" .. home .. "/.config/xplr/plugins/?.lua"

    --local deps = {}
    local deps_luaclient = ("%s%s"):format(root, "/src/lua-client/?.lua")
    local deps_coxpcall = ("%s%s"):format(root, "/src/coxpcall/src/?.lua")
    local cdeps_mpack = ("%s%s"):format(root, "/src/libmpack/?.so")
    local cdeps_luv = ("%s%s"):format(root, "/src/luv/?.so")
    package.path = package.path .. ";" .. deps_luaclient .. ";" .. deps_coxpcall
    package.cpath = package.cpath .. ";" .. cdeps_mpack .. ";" .. cdeps_luv
    local vim = require("nvim-xplr.vim")

  
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
