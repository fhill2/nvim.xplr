
an xplr plugin that hosts a [msgpack client](https://github.com/neovim/lua-client) to communicate with nvim.



nvim-xplr.xplr provides these features:
1 a simple API that wraps nvim-client API customized for xplr. This makes it possible to send data to nvim API functions or your own lua functions in nvim.  

2 preview hovered file in preview window (using Telescope previewer)


3 open selection in nvim


Installation
1 Install xplr.nvim
install [xplr.nvim](https://github.com/fhill2/xplr.nvim) and `call health#xplr#check()`. This will show info about what needs to be installed. Or read below!

## Install Luarocks and required packages
```bash
luarocks install nvim-client
```

3 install this plugin manually

- Add the following line in `~/.config/xplr/init.lua`

  ```lua
  package.path = os.getenv("HOME") .. '/.config/xplr/plugins/?/src/init.lua'
  ```

- Clone the plugin

  ```bash
  mkdir -p ~/.config/xplr/plugins

  git clone https://github.com/fhill2/nvim.xplr ~/.config/xplr/plugins/nvim-xplr
  ```

- Require the module in `~/.config/xplr/init.lua`

  ```lua
local nvim = require("nvim-xplr").setup{
  open_selection = {
    enabled = true,
    mode = "action",
    key = "o",
  },
  preview = {
    enabled = true,
    mode = "action",
    key = "i",
    fifo_path = "/tmp/nvim-xplr.fifo",
  },
}

  -- Type `:o` to open selected files in nvim.
  -- Type `:i` to toggle nvim preview mode.
  ```


If you don't have luarocks installed and you use Packer.nvim as your plugin manager, you can install Luarocks with it (uses Hererocks to install)
I recommend installing Luarocks with [Hererocks](https://github.com/luarocks/hererocks")

If you are installing without Luarocks, you will have to make sure nvim-client and its dependencies are available within the xplr environment
```lua
package.path = package.path .. ""
```
If using Luarocks, luarocks require paths are appended to xplr require paths at `setup()`


Default behaviour:
When you open xplr inside nvim, this plugin's lua msgpack client will use the server address of the nvim instance (`echo v:servername`) you launched it from (passed down with env variable).
If you launch xplr outside nvim, this plugin won't do/setup anything.




Improvements
Currently communication is unidirectional xplr --> nvim (I haven't set up handlers to receive data from nvim)


Creating your own Commands that interact with nvim:
requiring `nvim-xplr` returns the msgpack client object to `~/.config/xplr/init.lua`.
You can then use the msgpack client within your keybinded functions to trigger and send data to functions in nvim like this:

```lua

xplr.fn.custom.nvim_hello = function(app)
 nvim:exec_lua(
          'return require"xplr.actions".hello_world(...)', app)

  
return { LogSuccess = "combine messages and nvim API calls" }
end 

xplr.config.modes.builtin.action.key_bindings.on_key["u"] = {
      help = "hello nvim",
      messages = {
        { CallLuaSilently = "custom.nvim_hello" },
      },
    }

``` 

msgpack client accepts tables, client will nil all userdata/function refs
prepend return is needed

you can call whatever nvim API method you want, however i've found it easier to send data over to a nvim function and do the work on the nvim side.

```lua

-- call nvim functions from xplr function
 nvim:exec_lua('return require"xplr.actions".hello_world(...)', data)

-- call vimL functions from xplr function
 nvim:command('echo "xplr makes me a better unix chad"')

-- call any nvim API method like this (untested)
nvim:request("nvim_command", "echo v:servername")
```
