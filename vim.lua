local vim = {}



--- Splits a string at each instance of a separator.
---
--@see |vim.split()|
--@see https://www.lua.org/pil/20.2.html
--@see http://lua-users.org/wiki/StringLibraryTutorial
---
--@param s String to split
--@param sep Separator string or pattern
--@param plain If `true` use `sep` literally (passed to String.find)
--@returns Iterator over the split components
function vim.gsplit(s, sep, plain)
  --vim.validate{s={s,'s'},sep={sep,'s'},plain={plain,'b',true}}

  local start = 1
  local done = false

  local function _pass(i, j, ...)
    if i then
      assert(j+1 > start, "Infinite loop detected")
      local seg = s:sub(start, i - 1)
      start = j + 1
      return seg, ...
    else
      done = true
      return s:sub(start)
    end
  end

  return function()
    if done or (s == '' and sep == '') then
      return
    end
    if sep == '' then
      if start == #s then
        done = true
      end
      return _pass(start+1, start)
    end
    return _pass(s:find(sep, start, plain))
  end
end

--- Splits a string at each instance of a separator.
---
--- Examples:
--- <pre>
---  split(":aa::b:", ":")     --> {'','aa','','b',''}
---  split("axaby", "ab?")     --> {'','x','y'}
---  split(x*yz*o, "*", true)  --> {'x','yz','o'}
--- </pre>
--
--@see |vim.gsplit()|
---
--@param s String to split
--@param sep Separator string or pattern
--@param plain If `true` use `sep` literally (passed to String.find)
--@returns List-like table of the split components.
function vim.split(s,sep,plain)
  local t={} for c in vim.gsplit(s, sep, plain) do table.insert(t,c) end
  return t
end

return vim
