local G = require 'gen'

local cssfiles = List{"main", "prism", "katex.min", "font-awesome.min"}
  :map(function(n) return link { rel = "stylesheet", href = "/css/"..n..".css" } end)

local jsfiles = List{ "syntax-prism", "katex.min", "mathtex-script-type.min", "auto-render.min" }
  :map(function(n) return script { defer="", src="/"..n..".js" } end)

return function(name, canon, site, author, ...)
  local pagetitle = site.name
  if name ~= nil then
    pagetitle = pagetitle.." - "..name
  end
  if author ~= nil then
    author = meta { property="article:author", content=author.name }
  end

 return head(append({
    meta { charset="utf-8" },
    meta { ["http-equiv"]="X-UA-Compatible", content="IE=Edge" },
    meta { name="viewport", content="width=device-width, initial-scale=1.0" },
    
    meta { name="theme-color", content="#"..site.color },
    meta { name="copyright", content="Copyright (c)"..G.getyear().." "..site.name },
    meta { name="keywords", content=site.tags },
    meta { name="robots", content="index,follow" },
    meta { name="googlebot", content="index,follow" },
    meta { name="generator", content="Feather UI" },
    
    link { rel="canonical", href=site.root..canon},
    link { rel="apple-touch-icon", href="/favicon.ico" },
    link { rel="shortcut icon", type="image/x-icon", href="/favicon.ico" },
    link { rel="alternate", type="application/rss+xml", title=site.name.." - RSS", href="/index.xml" },
    link { rel="preload", href="/img/feather.svg", as="image" },
  },
  cssfiles,
  {
    meta { property="og:type", content="website" },
    
    title(pagetitle),
    meta { property='og:title', content=pagetitle },
    meta { name="twitter:title", content=pagetitle },
    meta { itemprop="name", content=pagetitle },
    
    meta { name="description", content=site.description },
    meta { property="og:description", content=site.description },
    meta { name="twitter:description", content=site.description },
    meta { itemprop="description", content=site.description },
  },
  jsfiles,
  {
    ...
  }))
end