require "luvit/init" (function(...)

    local port = args[1]
    
local weblit = require "./deps/weblit"

local app = weblit.app

local waitingSockets = {}

local function escape(s)
  local needs_escape = {
    ['-'] = true
  }

  return (s:gsub('.', function(c)
    if needs_escape[c] then
      return '%' .. c
    end
  end))
end

local function multipart(req, res, go)
  if (req.headers['Content-Type'] or ''):match('^' .. escape('multipart/form-data')) then
    req.multipart ={}

    local boundary = req.headers['Content-Type']:match('boundary=(.*)$')
    boundary = escape(boundary)

    local body = req.body:match(boundary .. '(.*)')

    for part in body:gmatch('(..-)' .. boundary) do
      local name = part:match('name="([^";]*)"')
      local filename = part:match('filename="([^\r\n]*)"')
      local contents
      if filename then 
        contents = part:match('Content%-Type[^\r\n]*\r\n\r\n' .. '(.*)' .. '\r\n%-%-$')
      else
        contents = part:match('\r\n\r\n(.*)\r\n%-%-')
      end
      
      if name and contents then
        req.multipart[name] = { filename = filename, contents = contents }
      end
    end
  end

  return go()
end

app.bind(
    {
        host = "0.0.0.0",
        port = tonumber(port) or 8080
    }
)
.use(weblit.logger)
.use(weblit.autoHeaders)
.use(weblit.etagCache)
.use(multipart)

local RESUME_SEQ = 1
app
.use(weblit.static "bundle:static/")
.use(weblit.static "static")
.route({
    method = "POST",
    path = "/submit_resume"
  }, function (req, res, go)
    if req.multipart.comment or req.multipart.resume then
      local prefix = os.date("%Y%m%d_%H%M%S_") .. RESUME_SEQ
      RESUME_SEQ = RESUME_SEQ + 1

      if req.multipart.jobid ~= nil then
        prefix = prefix .. "_job_" .. req.multipart.jobid.contents
      else
        res.headers['Content-Type'] = 'text/plain'
        res.code = 503
        res.body = tostring(err)
        return
      end
      
      if req.multipart.resume then
        local file,err = io.open(prefix .. req.multipart.resume.filename,'w')
        
        if file then
          file:write(req.multipart.resume.contents)
          file:close()
        else
          res.headers['Content-Type'] = 'text/plain'
          res.code = 503
          res.body = tostring(err)
          return
        end
      end
      if req.multipart.comment then
        local file,err = io.open(prefix .. "_comment.txt",'w')
        
        if file then
          file:write(req.multipart.comment.contents)
          file:close()
        else
          res.headers['Content-Type'] = 'text/plain'
          res.code = 503
          res.body = tostring(err)
          return
        end
      end
      res.headers.Location = '/careers/#submit'
    else
      res.headers.Location = '/careers/#error'
    end
    
    res.code = 303
  end)
.start()

                     end, ...)
