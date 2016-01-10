--[[
   Copyleft (Ↄ) Soojin Nam

   Programming Pearls: a sample of brilliance
   Communications of the ACM, 
   Volume 30 Issue 9, Sept. 1987,  
   Pages 754-757 
--]]

local ffi = require "ffi"
local bstree = require "bstree"

local ffi_new = ffi.new
local pairs = pairs
local randint = math.random
local insert = table.insert

ffi.cdef[[
    typedef struct lnode_s lnode_t;
    struct lnode_s {
        uint32_t    value;
        lnode_t    *next;
    };
]]
local lnode_type = ffi.typeof("lnode_t")
local NULL = ffi.null


-- set arguments
local maxn = 1000000000 -- 1000,000,000

local function _set_args (m, n)
   if not m then
      return nil, "numeric arguments should be given."
   end
   local n = n or m
   if n > maxn then
      return nil, n.." should be less than "..maxn.."."
   elseif m > n then
      return nil, m.." should be less than or equal to "..n.."."
   end
   return m, n
end


-- module stuffs

local _M = {}


-- Sampling
function _M.sample (...)
   local m, n = _set_args(...)
   if not m then
      return nil, n
   end

   local s = {}
   local tree = bstree.new()
   
   for j = n-m+1, n do
      local t = randint(j)
      if not s[t] then
         s[t]= tree:tnode(t)
         tree:insert(s[t])
      else
         s[j]= tree:tnode(j)
         tree:insert(s[j])
      end
   end

   return tree:walk()
end


-- Floyd's random permutation generator
local function _rand_permgen (...)
   local m, n = _set_args(...)
   if not m then
      return nil, n
   end

   local s, head = {}, NULL
   for j = n-m+1, n do
      local t = randint(j)
      if not s[t] then
         -- prefix t to s
         head = ffi_new(lnode_type, t, head)
         s[t] = head
      else
         -- insert j in s after t
         local curr = ffi_new(lnode_type, j, s[t].next)
         s[t].next = curr
         s[j] = curr
      end
   end

   s = {}
   while head ~= NULL do
      insert(s, head.value)
      head = head.next
   end
   
   return s
end

_M.shuffle = _rand_permgen
_M.permgen = _rand_permgen

math.randomseed(os.time())

return _M
