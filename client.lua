-- modified from neovim test/functional/helpers.lua
-- VERSION 1
local Session = require('nvim.session')
local SocketStream = require('nvim.socket_stream')

local inspect = require'inspect'
local function log(msg)
  local outfile = '/home/f1/logs/xplr.log'
  local fp = io.open(outfile, "a")
  fp:write(string.format('\n%s', inspect(msg)))
  fp:close()
end


local Client = {}
Client.__index = Client

function Client:new(socket_path)
local stream = SocketStream.open(socket_path)

return setmetatable({
  _session =  Session.new(stream),
  _stream = stream
}, Client)
end



function Client:request(method, ...)
  local status, rv = self._session.request(method, ...)
  if not status then
    if loop_running then
      last_error = rv[2]
      self._session:stop()
    else
      error(rv[2])
    end
  end
  return rv
end



function Client:create_callindex(func)
  local table = {}
  setmetatable(table, {
    __index = function(tbl, arg1)
      local ret = function(...) return func(arg1, ...) end
      tbl[arg1] = ret
      return ret
    end,
  })
  return table
end


-- module.funcs = module.create_callindex(module.call)
Client.meths = self.create_callindex(module.nvim)
-- module.async_meths = module.create_callindex(module.nvim_async)
-- module.uimeths = module.create_callindex(ui)
-- module.bufmeths = module.create_callindex(module.buffer)
-- module.winmeths = module.create_callindex(module.window)
-- module.tabmeths = module.create_callindex(module.tabpage)
-- module.curbufmeths = module.create_callindex(module.curbuf)
-- module.curwinmeths = module.create_callindex(module.curwin)
-- module.curtabmeths = module.create_callindex(module.curtab)

function Client:exec_lua(code, ...)
  return self.meths.exec_lua(code, {...})
end


-- Executes an ex-command. VimL errors manifest as client (lua) errors, but
-- v:errmsg will not be updated.
function Client:command(cmd)
  log(self._session.request)
  self._session:request('nvim_command', cmd)
end

return Client
