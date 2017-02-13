-----------
-- Lua Sand Box
-- @author Zhiyuan Wang wzypublic@gmail.com
-- @type LuaSandBox

local LuaSandBox = {}
LuaSandBox.__index = LuaSandBox

local function readOnly(t)
  return setmetatable({}, {
    __metatable = 'Read-only table',
    __index = t,
    __newindex = function() error('Read-only table') end
  })
end

local function clone(a, tbls)
  if type(a) ~= 'table' then
    return a
  else
    tbls = tbls or {}
    local t = tbls[a]
    if not t then
      t = {}
      tbls[a] = t
      for k, v in pairs(a) do
        t[k] = clone(v, tbls)
      end
    end
    return t
  end
end

local basicEnv = {
  _VERSION  = _VERSION,
  assert    = assert,
  error     = error,
  ipairs    = ipairs,
  next      = next,
  pairs     = pairs,
  pcall     = pcall,
  select    = select,
  tonumber  = tonumber,
  tostring  = tostring,
  type      = type,
  unpack    = unpack,
  xpcall    = xpcall,
  string    = {
    byte      = string.byte,
    char      = string.char,
    find      = string.find,
    format    = string.format,
    gmatch    = string.gmatch,
    gsub      = string.gsub,
    len       = string.len,
    lower     = string.lower,
    match     = string.match,
    rep       = string.rep,
    reverse   = string.reverse,
    sub       = string.sub,
    upper     = string.upper
  },
  table     = table,
  math      = math,
  os        = {
    clock     = os.clock,
    date      = os.date,
    difftime  = os.difftime,
    time      = os.time
  }
}

--- Get a table of safe basic lua values to use as a basic env
-- Caller can edit it to get custom env to create new sand box
-- @return A table of safe basic lua values
function LuaSandBox.getBasicEnv()
  return clone(basicEnv)
end

--- Create a new sand box
-- @param env The global env table of the created sand box
-- @return A new LuaSandBox instance
function LuaSandBox.new(env)
  if type(env) ~= 'table' then
    error('Param #1 "env" must be a table')
  end

  return setmetatable({
    env = env
  }, LuaSandBox)
end

--- Eval a string as code within sand box
-- @param code String code
-- @param ... Params for the code
-- @usage
--   true, ... = eval(code, ...)
--   false, msg = eval(code, ...)
function LuaSandBox:eval(code, ...)
  if getmetatable(self) ~= LuaSandBox then
    error('Must be called as instance:eval(code, ...)')
  end

  if type(code) ~= 'string' then
    error('Param #1 "code" must be a string')
  end

  if code:byte(1) == 27 then
    return false, 'Binary bytecode prohibited'
  end

  local func, msg = loadstring(code)
  if not func then
    return false, msg
  end

  setfenv(func, self.env)
  return pcall(func, ...)
end

if true then
  return LuaSandBox
else
  return readOnly(LuaSandBox)
end
