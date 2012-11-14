local colors = require("ansicolors")
local insert = table.insert
local flatten_params_helper
flatten_params_helper = function(params, out, sep)
  if out == nil then
    out = { }
  end
  if sep == nil then
    sep = ", "
  end
  insert(out, "{ ")
  for k, v in pairs(params) do
    insert(out, tostring(k))
    insert(out, ": ")
    if type(v) == "table" then
      flatten_params(v, out)
    else
      insert(out, ("%q"):format(v))
    end
    insert(out, sep)
  end
  if out[#out] == sep then
    out[#out] = nil
  end
  insert(out, " }")
  return out
end
local flatten_params
flatten_params = function(params)
  return table.concat(flatten_params_helper(params))
end
local request
request = function(r)
  local req, res = r.req, r.res
  local status
  if res.statusline then
    status = res.statusline:match(" (%d+) ")
  else
    status = "200"
  end
  local t = "[%{green}%s%{reset}] %{bright}%{cyan}%s%{reset} - %s"
  local cmd = tostring(req.cmd_mth) .. " " .. tostring(req.cmd_url)
  return print(colors(t):format(status, cmd, flatten_params(r.url_params)))
end
return {
  request = request
}