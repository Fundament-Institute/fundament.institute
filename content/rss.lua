local g = require 'lpeg'
local l = g.locale()

local function split(pat, str)
    return g.Ct(g.C((1-pat)^1) * (pat^1 * g.C((1-pat)^1))^0)
end

local builder_mt = {__index = {}}

function builder_mt.__index:emit(val)
    if getmetatable(val) == builder_mt then
        for i = 1, #val do
            self[#self+1] = val[i]
        end
    else
        self[#self+1] = tostring(val)
    end
    return self
end

local defaultRenderers = {
    string = function(s, build, options) build:emit(s) end,
    number = function(x, build, options) build:emit(x) end,
    table = function(f, build, options) error "invalid table without __render metamethod" end,
}

function builder_mt.__index:render(val, options)
    if val ~= nil then
      local render = (getmetatable(val) and getmetatable(val).__render) or defaultRenderers[type(val)]
      if render then
          render(val, self, options)
      else
          print(val)
          error "Unable to find a renderer for a value in the render tree"
      end
    end
    return self
end

function builder_mt:__tostring()
    return table.concat(self)
end

local function new_builder()
    return setmetatable({}, builder_mt)
end

local rssElements = split(l.space):match [[rss channel title link description generator language copyright lastBuildDate item pubDate guid]]


local function getName(element)
    return getmetatable(element).__elemname
end

local function rssRender(tree, build, options)
    local tag = getName(tree)
    build:emit("<"):emit(tag)
    for k, v in pairs(tree) do
        if type(k) == "string" then
            build:emit ' '
                :emit(k)
                :emit '="'
                :render(v, options)
                :emit '"' 
        end
    end
    build:emit">"
    for i = 1, #tree do
        build:render(tree[i], options)
    end
    build:emit '</'
        :emit(tag)
        :emit('>')
end

local rssCompile

local function makeElementMT(name)
    return {
        __elemname = name,
        __render = rssRender,
        __compile = rssCompile,
    }
end

local rssConstructors = {}

for i, name in ipairs(rssElements) do
    local mt = makeElementMT(name)
    rssConstructors[name] = function(val)
        if type(val) == "string" then
            val = {val}
        end
        if type(val) ~= "table" then
            error "invalid argument type for RSS constructor. Argument must be a table or a string"
        end
        return setmetatable(val, mt)
    end
end

local M = {}

local foreach_mt = {
  __render = function(self, build, options)
    local shadow = options.env[self.var]
    local idxshadow
    if self.idx then
      idxshadow = options.env[self.idx]
    end
    for i, v in ipairs(options.env[self.collection]) do
      options.env[self.var] = v
      if self.idx then
        options.env[self.idx] = i
      end
      for _, tree in ipairs(self) do
        build:render(tree, options)
      end
    end
    options.env[self.var] = shadow
    if self.idx then
      options.env[self.idx] = idxshadow
    end
  end,
  __compile = nil
}

function M.forEach(tree)
  return setmetatable(tree, foreach_mt)
end

local function forrange_resolve(value, options, default)
  local res = default
  if type(value) == "number" then
    res = value
  elseif type(value) == "string" then
    res = options.env[value]
  end
  if type(res) ~= "number" then
    error "invalid type of range value"
  end
  return res
end

local forrange_mt = {
  __render = function(self, build, options)
    local shadow = options.env[self.var]
    local start = forrange_resolve(self.start, options)
    local stop = forrange_resolve(self.stop, options)
    local step = forrange_resolve(self.step, options, 1)
    for i = start, stop, step do
      options.env[self.var] = i
      for _, tree in ipairs(self) do
        build:render(tree, options)
      end
    end
    options.env[self.var] = shadow
  end,
  __compile = nil
}

function M.forRange(tree)
  return setmetatable(tree, forrange_mt)
end

local cond_mt = {
  __render = function(self, build, options)
    if options.env[self.cond] then
      for _, tree in ipairs(self) do
        build:render(tree, options)
      end
    end
  end,
  __compile = nil
}

function M.cond(tree)
  return setmetatable(tree, cond_mt)
end

local S_mt = {
  __render = function(self, build, options)
    build:render(tostring(options.env[self[1]]), options)
  end,
  __compile = nil
}

function M.S(name)
  return setmetatable({name}, S_mt)
end

function M.render(template, options)
    if not options then options = {env = {}} end
    local build = new_builder()
    build:emit [[<?xml version="1.0" encoding="utf-8" standalone="yes"?>]]
    build:render(template, options)
    return tostring(build)
end

function M.compile(template, options)
    error "Compilation not yet implemented"
end

for k, v in pairs(rssConstructors) do
    M[k] = v
end

return M
