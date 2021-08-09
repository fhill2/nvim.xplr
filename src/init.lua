
local inspect = require'inspect'
local function log(msg)
  local outfile = '/home/f1/logs/xplr.log'
  local fp = io.open(outfile, "a")
  fp:write(string.format('\n%s', inspect(msg)))
  fp:close()
end



-- local function testit()
  
-- end

local function setup(opts)
  log('nvim-xplr setup ran!')
  local xplr = xplr
  local enabled = false
  local messages = {}

-- workaround for xplr sub modules - can't require
package.path = package.path .. ';' .. os.getenv("HOME") .. '/.config/xplr/plugins/?.lua'

local Client = require'nvim-xplr.client'

local client
  if os.getenv('NVIM_XPLR') == "1" then
    log('NVIM XPLR TRUE')
    log(os.getenv('NVIM_XPLR_SERVERNAME'))
    local socket_path = os.getenv('NVIM_XPLR_SERVERNAME')
    client = Client:new(socket_path)
  end





-- open selection in nvim
if opts.open_selection then
xplr.fn.custom.nvim_open_selection = function(app)
client:exec_lua([[return require'xplr.actions'.open_selection(...)]], app.selection)
end

xplr.config.modes.builtin[opts.open_selection.mode].key_bindings.on_key[opts.open_selection.key] = {
    help = "nvim_selection",
    messages = {
      "PopMode",
      { CallLua = "custom.nvim_open_selection" },
    },
  }
end


-- start/stop preview
if opts.preview then
os.execute("[ ! -p '" .. opts.preview.fifo_path .."' ] && mkfifo '" .. opts.preview.fifo_path .. "'")

xplr.fn.custom.nvim_preview = function(app)

    if enabled then
      enabled = false
      client:exec_lua([[return require'xplr.manager'._toggle_preview(...)]], { fifo_path = opts.preview.fifo_path, enabled = enabled })
      messages = { "StopFifo" }
    else
      os.execute("NNN_FIFO='" .. opts.preview.fifo_path .. "' '".. opts.preview.previewer .. "' & ")
      enabled = true
      client:exec_lua([[return require'xplr.manager'._toggle_preview(...)]], { fifo_path = opts.preview.fifo_path, enabled = enabled })
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





return { setup = setup }
