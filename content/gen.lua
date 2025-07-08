
local lfs = require 'lfs'
local pl = require 'pl'

G = {}

function G.filterposts(posts, tags, author, mindate, maxdate)
  local result = {}
  for post in posts do
    if (author == nil or post.author == author) and
        (tags == nil or post.tags == tags) and
        (mindate == nil or post.date >= mindate) and
        (maxdate == nil or post.date < maxdate) then
      table.insert(result, post)
    end
  end
  return result
end

function G.getyear()
  return Date():year()
end

return G