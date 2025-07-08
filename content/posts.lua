local top = requirehtml 'top'
local nav = requirehtml 'nav'
local bottom = requirehtml 'bottom'
local site = require 'site'
local G = require 'gen'
local postbox = requirehtml 'postbox'

return function(posts, authors)
  local boxed = {}
  for k,v in ipairs(posts) do
    _G.table.insert(boxed, div { class="box", postbox(v, authors)})
  end

  return html {
    top("Archive", "/posts", site.fs),
    body {
      div { class="wrapper" },
      header { 
        nav(site.fs.navbar),
      },
      main { 
        div(append({ class="grid", }, boxed)),
      },
      bottom(site.fs.name),
    }
  }
end
