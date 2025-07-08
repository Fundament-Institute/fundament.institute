local top = requirehtml 'top'
local nav = requirehtml 'nav'
local bottom = requirehtml 'bottom'
local site = require 'site'
local G = require 'gen'
local postbox = requirehtml 'postbox'

return function(posts, authors)
  local max = 2
  max = math.min(#posts, 1+max)
  local boxed = {}
  for k=2,max do
    _G.table.insert(boxed, div { class="box", postbox(posts[k], authors)})
  end

  local archives = {}
  for k=max + 1,math.min(#posts, max + 9) do
    _G.table.insert(archives, li { a { href="/posts/"..posts[k].slug, posts[k].title}})
  end

  return html {
    top("Home", "/", site.fs),
    body {
      div { class="wrapper" },
      header { 
      nav(site.fs.navbar),
      },
      main { 
        section { 
          class = "featurebox",
          div { class="wrapfeather", 
            div { class="toplayer" },
            div{ style="margin: 0 auto;max-width:38em;padding: 0 1em;", img { class="feather", src="/img/feather.svg", alt="Feather UI" } }, 
            h3 { a { href="https://github.com/Fundament-Institute/feathergui", "Universal Interface&nbsp;&#10095;" } },
          },
        },
        section { 
          class = "featurebox",
          div { class="wrapaliciorn", 
            div { class="toplayer" },
            div{ style="margin: 0 auto;max-width:576px;padding: 0 14px;", img { class="alicorn", src="/img/alicorn.png", alt="Alicorn" } },
            h3 { a { href="https://github.com/Fundament-Institute/alicorn", "Next-Generation Coding&nbsp;&#10095;" } },
          },
        },
        postbox(posts[1], authors, true),
        div(append({ class="grid", },
          boxed,
          { 
            div { class="box",
              section { 
                h6 [[/ ARCHIVES]],
                hr{},
                article { 
                  ul(archives)
                },
                hr{},
                a { class="archivebutton", href="/posts/", [[Browse Articles ...]] }
              }
            }
          })),
      },
      bottom(site.fs.name),
    }
  }
end
