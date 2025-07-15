local top = requirehtml 'top'
local nav = requirehtml 'nav'
local bottom = requirehtml 'bottom'
local site = require 'site'
local G = require 'gen'
local pathbox = requirehtml 'pathbox'

return function(post, authors)
  local author = authors[post.author]
  local df = Date.Format("")
  local timestamp = nil
  local comments = nil

  if author then
    timestamp = h2 { i { class="fa fa-pencil-square-o fa-fw" }, "&nbsp;"..author.name, " on ", time { i { class="fa fa-clock-o fa-fw" }, post.date:month_name(true).." "..post.date:day()..", "..post.date:year()}}
    if author.avatar then
      author = aside { 
        img { src=author.avatar, alt="Avatar", title=author.name }, 
      }
    else
      author = nil
    end
  end

  if not post.tags["site"] then
    --comments = h5 { a { href="/posts/"..post.slug.."#comments", i { class="fa fa-comments fa-fw" }, "&nbsp;"..[[0 comments]] }}
  end

  return html {
    top(post.title, "/posts/" .. post.slug, site.fs),
    body {
      header { 
        nav(site.fs.navbar),
      },
      main { 
        section { 
          --author,
          h1{a{ href="/posts/"..post.slug, post.title}},
          hr{},
          article { post.content },
          hr{},
          comments,
          timestamp,
        }
      },
      bottom(site.fs.name),
    }
  }
end