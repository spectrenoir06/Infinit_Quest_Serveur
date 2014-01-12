-- Copyright (C) 2009 Google Inc.
--
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not
-- use this file except in compliance with the License. You may obtain a copy of
-- the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
-- WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
-- License for the specific language governing permissions and limitations under
-- the License.

json = require "/android/json"
socket = require "socket"
local P = {}
 
if _REQUIREDNAME == nil then
  android = P
else
  _G[_REQUIREDNAME] = P
end
 
local id = 0
 
function rpc(client, method, ...)
  assert(method, 'method param is nil')
  local rpc = {
    ['id'] = id,
    ['method'] = method,
    params = arg
  }
  local request = json.encode(rpc)
  client:send(request .. '\n')
  id = id + 1
  local response = client:receive('*l')
  local result = json.decode(response)
  if result.error ~= nil then
    print(result.error)
  end
  return result
end

if not G_port then
    G_port = "4321"
end

if not G_host then
    G_host = "192.168.10.8"
end

local client = socket.connect(tostring(G_host), tonumber(G_port))
local meta = {
  __index = function(t, key)
    return function(...)
      return rpc(client, key, unpack(arg))
    end
  end
}
 
setmetatable(P, meta)
 
local handshake = os.getenv('AP_HANDSHAKE')
P._authenticate(handshake)
 
-- Workaround for no sleep function in Lua.
function P.sleep(seconds)
  return os.execute('sleep ' .. seconds)
end
 
function P.printDict(d)
  for k, v in pairs(d) do print(k, v) end
end
 
function P.whoami()
  local f = assert(io.popen('id', 'r'))
  local s = assert(f:read('*a'))
  return string.match(s, 'uid=%d+%((.-)%)')
end
 
function P.ps()
  local f = assert(io.popen('ps', 'r'))
  local user = P.whoami()
  local procs = {}
  for line in f:lines() do
    if string.match(line, '^(.-)%s', 1) == user then
      local pid = string.match(line, '^.-%s+(%d+)', 1)
      local cmd = string.match(line, '%s+([^%s]+)$', 1)
      procs[pid] = cmd
    end
  end
  return procs
end
 
function P.kill(pid)
  os.execute('kill ' .. pid)
end
 
function P.killallmine()
  local procs = P.ps()
  local killcmd = 'kill '
  for pid, cmd in pairs(procs) do killcmd = killcmd .. pid end
  os.execute(killcmd)
end
 
return P