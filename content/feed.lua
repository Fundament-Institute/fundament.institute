local site = require("site")
local mdfunc = require("markdown")

local function escape(s)
	s = string.gsub(s, "&", "&amp;")
	s = string.gsub(s, "<", "&lt;")
	s = string.gsub(s, ">", "&gt;")
	s = string.gsub(s, "'", "&apos;")
	s = string.gsub(s, '"', "&quot;")
	return s
end

return function(posts, authors)
	local items = channel({
		title({ "Fundament Research Institute News" }),
		link({ site.fs.root }),
		description({ "Latest news and blog posts from the Fundament Research Institute." }),
		generator({ "Fundament Research Institute RSS Generator" }),
		language({ "en-US" }),
		copyright({ "Fundament Research Institute" }),
		lastBuildDate({ tostring(os.date("%a, %d %b %Y %X")) }),
		[[<atom:link href="]] .. site.fs.root .. [[/index.xml" rel="self" type="application/rss+xml"/>]],
	})

	for k, post in ipairs(posts) do
		_G.table.insert(
			items,
			item({
				title({ post.title }),
				link({ site.fs.root .. "/posts/" .. post.slug }),
				pubDate({ tostring(post.date) }),
				guid({ site.fs.root .. "/posts/" .. post.slug }),
				description({ escape(string.gsub(tostring(mdfunc(post.content.content)), "<[^>]+>", "")) }),
			})
		)
	end

	return rss({
		version = "2.0",
		["xmlns:atom"] = "http://www.w3.org/2005/Atom",
		items,
	})
end
