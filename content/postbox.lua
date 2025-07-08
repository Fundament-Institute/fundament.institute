local pathbox = requirehtml 'pathbox'

return function(post, authors, maxed)
  local author = authors[post.author]
  local df = Date.Format("")
  local abody = article { post.content, a { href="/posts/"..post.slug, class="readmore", "Read More" } }

  if maxed then
    abody["style"] = "max-height:15em;"
  end

  local avatar
  if author.avatar then
    avatar = aside { 
      img { src=author.avatar, alt="Avatar", title=author.name }, 
    }
  end

  return section { 
    avatar,
    pathbox(post.path),
    h1{a{ href="/posts/"..post.slug, post.title}},
    hr{},
    abody,
    hr{},
    --h5 { a { href="/posts/"..post.slug.."#comments", i { class="fa fa-comments fa-fw" }, "&nbsp;"..[[0 comments]] }},
    h2 { i { class="fa fa-pencil-square-o fa-fw" }, "&nbsp;"..author.name, " on ", time { i { class="fa fa-clock-o fa-fw" }, post.date:month_name(true).." "..post.date:day()..", "..post.date:year()}},
  }
end