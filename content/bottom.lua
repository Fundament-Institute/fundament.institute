local G = require 'gen'

return function(name)
  return footer { 
    section { 
      "&copy;"..G.getyear().." "..name.." | ",
      a { href="/sitemap.xml", i { class="fa fa-map-marker fa-fw" }, [[Sitemap]]},
      [[ | ]],
      a { href="/index.xml", i { class="fa fa-rss fa-fw" }, [[&nbsp;RSS Feed]]},
      [[ | ]],
      a { href="/privacy", i { class="fa fa-lock fa-fw" }, [[Privacy Policy]]},
    }
  }
end