
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
-- workaround for xplr sub modules - can't require
package.path = package.path .. ';' .. os.getenv("HOME") .. '/.config/xplr/plugins/?.lua'

local Client = require'nvim-xplr.client'

  -- if inside nvim, connect
 -- local clienty
  if os.getenv('NVIM_XPLR') == "1" then
    log('NVIM XPLR TRUE')
    log(os.getenv('NVIM_XPLR_SERVERNAME'))
    local socket_path = os.getenv('NVIM_XPLR_SERVERNAME')
    return Client:new(socket_path)
  end
end



-- helper functions 
--
local function get_absolute(selection)
end


return { setup = setup }
