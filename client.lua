-- modified from neovim test/functional/helpers.lua
-- VERSION 1
local Session = require('nvim.session')
local SocketStream = require('nvim.socket_stream')
local vim = require('nvim-xplr.vim')

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

-- stream:read_start(function(chunk) 
-- print(chunk)
-- log(chunk)
-- end)

return setmetatable({
  _session =  Session.new(stream),
  _stream = stream
}, Client)
end



-- convert userdata and function references to strings before sending lua tables over msgpack
local function deepnil(orig) end
deepnil = (function()
  local function _id(v)
    return v
  end

  local deepnil_funcs = {
    table = function(orig)
      local copy = {}

     --  if vim._empty_dict_mt ~= nil and getmetatable(orig) == vim._empty_dict_mt then
     --    copy = vim.empty_dict()
     -- end

      for k, v in pairs(orig) do
        copy[deepnil(k)] = deepnil(v)
      end
      return copy
    end,
    number = _id,
    string = _id,
    ['nil'] = _id,
    boolean = _id,
    ['function'] = function() return "<function>" end,
    ['userdata'] = function() return "<userdata>" end,
  }

  return function(orig)
    local f = deepnil_funcs[type(orig)]
    if f then
      return f(orig)
    else
    --error("Cannot deepcopy object of type "..type(orig))
    end
  end
end)()







--higher level

-- accepts {{}, {}} and sends data for every file selected
function Client:open_selection(selection)
client:exec_lua([[return require'xplr.actions'.open_selection(...)]], app.selection)
end


-- lower level
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


function Client:exec_lua(code, t)
self._session:request('nvim_exec_lua', code, { deepnil(t) })
end


-- Executes an ex-command. VimL errors manifest as client (lua) errors, but
-- v:errmsg will not be updated.
function Client:command(cmd)
 -- log(self._session.request)
  self._session:request('nvim_command', cmd)
end

return Client
