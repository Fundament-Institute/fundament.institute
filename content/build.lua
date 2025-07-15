local source, dest = ...

local html = require 'html'
local rss = require 'rss'
local markdown = require 'markdown'
local G = require 'gen'
local lfs = require 'lfs'
local site = require 'site'

local markdown_elem_mt = {}
function markdown_elem_mt:__render(builder, options)
  builder:emit(markdown(self.content))
end
local function markdown_elem(content)
  return setmetatable({content = content}, markdown_elem_mt)
end
local function markdown_file(name)
  local f = io.open(source.."/"..name..".md", "r")
  local content = f:read "*a"
  f:close()
  return markdown_elem(content)
end

local htmlenv
local sitemap = [[
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">
]]

local function writepage(name, content, path)

  sitemap = sitemap..[[
  <url>
    <loc>]]..site.fs.root.."/"

  if path ~= nil then
    sitemap = sitemap..path.."/"
  end

  if name ~= "index" then
    sitemap = sitemap..name.."/"
  end

  sitemap = sitemap..[[</loc>
    <lastmod>]]..tostring(os.date("%Y-%m-%dT%X+00:00"))..[[</lastmod>
  </url>]]

  if path == nil then
    path = dest
  else
    path = dest.."/"..path
    lfs.mkdir(path)
  end

  local f = io.open(path.."/"..name..".html", "w+")
  f:write(html.render(content, {doctype="html"}))
  f:close()
end

local require_cache = {}
local function requirehtml(name)
  if require_cache[name] then
    return require_cache[name]
  end
  local fname = assert(package.searchpath(name, package.path))
  require_cache[name] = assert(loadfile(fname, "bt", htmlenv()))()
  return require_cache[name]
end

local function append(...)
  local result, offset, list = {}, 0, {...}
  for _, tab in ipairs(list) do
    for k, v in pairs(tab) do
      local t = type(k)
      if t == "number" then
        result[k + offset] = v
      elseif t == "string" then
        result[k] = v
      else
        error "unknown key type in descriptor table"
      end
    end
    offset = offset + #tab
  end
  return result
end

function htmlenv()
  return setmetatable({
      requirehtml = requirehtml,
      markdown = markdown_elem,
      markdown_file = markdown_file,
      append = append
                      }, {
      __index = function(self, key)
        return html[key] or _ENV[key]
      end
  })
end

function rssenv()
  return setmetatable({
      markdown = markdown_elem,
      markdown_file = markdown_file,
      append = append
                      }, {
      __index = function(self, key)
        return rss[key] or _ENV[key]
      end
  })
end

local function loadpage(name, mode)
  return assert(loadfile(source.."/"..name..".lua", mode or "bt", htmlenv()))()
end

local function loadrss(name, mode)
  return assert(loadfile(source.."/"..name..".lua", mode or "bt", rssenv()))()
end

local function genpage(name)
  writepage(name, loadpage(name))
end

function fixdate(f)
  local df = Date.Format()
  if f.date then
    f.date = df:parse(f.date):toLocal()
  end
end

function loadpostinner(results, f, filename)
  fixdate(f)
  if f.content == nil then
    error(filename + " has no content! Make sure it's formated correctly!")
  end
  f.slug = string.gsub(filename, ".lua", "")
  f.description = string.sub(string.gsub(tostring(markdown(f.content.content)), "<[^>]+>", ""), 1, 500)
  table.insert(results, f)
end

function loadpost(path, filename, mode)
  local f = assert(loadfile(path..filename, mode or "bt", htmlenv()))()
  fixdate(f)
  f.slug = string.gsub(filename, ".lua", "")
  return f
end

function loadfiles(path, fn, mode)
  local result = {}
  for filename in lfs.dir(path) do
      if lfs.attributes(path..filename,"mode") == "file" then
        local f = assert(loadfile(path..filename, mode or "bt", htmlenv()))()
        fn(result, f, filename)
      end
  end
  return result
end

function loadauthor(results, f, filename)
  results[f.id] = f
end

function loadjob(results, f, filename)
  fixdate(f)
  table.insert(results, f)
end

local posts = loadfiles([[./posts/]], loadpostinner)
table.sort(posts, function(a, b) return a.date > b.date end)
local authors = loadfiles([[./authors/]], loadauthor)
--local jobs = loadfiles([[./jobs/]], loadjob)
--table.sort(jobs, function(a, b) return a.date > b.date end)

writepage("index", (loadpage "index")(posts, authors))
writepage("index", (loadpage "post")(loadpost("./", "privacy.lua"), authors), "privacy")
writepage("index", (loadpage "post")(loadpost("./", "tos.lua"), authors), "tos")
writepage("index", (loadpage "posts")(posts, authors), "posts")
--writepage("index", (loadpage "careers")(jobs), "careers")

do
  local f = io.open(dest.."/index.xml", "w+")
  f:write(rss.render((loadrss "feed")(posts, authors)))
  f:close()
end

lfs.mkdir(dest .. "/posts/")

for i,v in ipairs(posts) do
  writepage("index", (loadpage "post")(v, authors), "posts/"..v.slug)
end
--for i,v in ipairs(jobs) do
--  writepage("index", (loadpage "job")(v), "careers/"..v.id)
--end

do
  local f = io.open(dest.."/sitemap.xml", "w+")
  f:write(sitemap..[[</urlset>]])
  f:close()
end

--genpage "require_test"
--genpage "merge_test"

