return function(navbar)
  local navlinks = {}
  for _, v in ipairs(navbar) do
    _G.table.insert(navlinks, li { a { href=v.link, title=v.name, i { class="fa "..v.icon.." fa-fw" }, p { "&nbsp;"..v.name }}})
  end

  return 
    nav { 
      ul { 
        (function() return _G.table.unpack(navlinks) end)()
      }
    }
end