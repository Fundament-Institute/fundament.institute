return function(navbar)
  local navlinks = {}
  for _, v in ipairs(navbar) do
    _G.table.insert(navlinks, li { a { href=v.link, title=v.name, v.icon, p { "&nbsp;"..v.name }}})
  end

  return 
    nav { 
      ul { 
        img { src="/img/research_shadow.svg", style="height: 3em;position:relative;margin-top:-1em;top:1.15em;padding-right:0.5em;" },
        (function() return _G.table.unpack(navlinks) end)()
      }
    }
end