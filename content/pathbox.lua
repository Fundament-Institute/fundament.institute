return function(path)
  if path == nil then
    path = { "fundament" }
  end
  local l = { span("/ "..string.upper(path[1])) }
  for k=2,#path do
    _G.table.insert(l, " / "..string.upper(path[k]))
  end

  return h6(l)
end