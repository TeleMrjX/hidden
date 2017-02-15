local function addword(msg, name)
  local hash = 'chat:'..msg.to.id..':badword'
  redis:hset(hash, name, 'newword')
  local text = "🚫 واژه <b>"..name.." </b>فیلتر شد !"
  return reply_msg(msg.id, text, ok_cb, false)
end

local function get_variables_hash(msg)

  return 'chat:'..msg.to.id..':badword'

end

local function list_variablesbad(msg)
  local hash = get_variables_hash(msg)

  if hash then
    local names = redis:hkeys(hash)
    local text = '💢 لیست واژه های فیلتر شده :\n\n'
    for i=1, #names do
      text = text..'> '..names[i]..'\n'
    end
    return reply_msg(msg.id, text, ok_cb, false)
  else
    return
  end
end

function clear_commandbad(msg, var_name)
  --Save on redis
  local hash = get_variables_hash(msg)
  redis:del(hash, var_name)
  local text = '🗑 لیست واژه های فیلتر شده خالی شد !'
  return reply_msg(msg.id, text, ok_cb, false)
end

local function list_variables2(msg, value)
  local hash = get_variables_hash(msg)

  if hash then
    local names = redis:hkeys(hash)
    local text = ''
    for i=1, #names do
      if string.match(value, names[i]) and not is_momod(msg) then
        if msg.to.type == 'channel' then
          delete_msg(msg.id,ok_cb,false)
        else
          kick_user(msg.from.id, msg.to.id)

        end
        return
      end
      --text = text..names[i]..'\n'
    end
  end
end
local function get_valuebad(msg, var_name)
  local hash = get_variables_hash(msg)
  if hash then
    local value = redis:hget(hash, var_name)
    if not value then
      return
    else
      return value
    end
  end
end
function clear_commandsbad(msg, cmd_name)
  --Save on redis
  local hash = get_variables_hash(msg)
  redis:hdel(hash, cmd_name)
  local text = '♨️ واژه <b>'..cmd_name..' </b>از لیست واژه های فیلتر شده حذف شد !'
  return reply_msg(msg.id, text, ok_cb, false)
end

local function run(msg, matches)
  if matches[1]:lower() == 'filter' or matches[1] == 'فیلتر' then
  if not is_momod(msg) then
   return
  end
    local name = string.sub(matches[2], 1, 50)
    local text = addword(msg, name)
    return text
  end

  if matches[1] == 'filterlist' or matches[1] == 'لیست فیلتر' then
    if not is_momod(msg) then
   return
  end
    return list_variablesbad(msg)
  end

  if matches[1] == 'clean' or matches[1] == 'حذف' and matches[2] == 'filterlist' or matches[2] == 'لیست فیلتر' then
    if not is_momod(msg) then
   return
  end
    local asd = '1'
    return clear_commandbad(msg, asd)
  end

  if matches[1] == 'unfilter' or matches[1] == 'حذف فیلتر' then
    if not is_momod(msg) then
   return
  end
    return clear_commandsbad(msg, matches[2])
  end
  
  if msg.text:match("^(.+)$") then
  return list_variables2(msg, msg.text)
end  
  
end

return {
  patterns = {
    "^([Ff][Ii][Ll][Tt][Ee][Rr]) (.*)$",
    "^(فیلتر) (.*)$",

    "^([Uu][Nn][Ff][Ii][Ll][Tt][Ee][Rr]) (.*)$",
    "^(حذف فیلتر) (.*)$",

    "^([Ff][Ii][Ll][Tt][Ee][Rr][Ll][Ii][Ss][Tt])$",
    "^(لیست فیلتر)$",

    "^([Cc][Ll][Ee][Aa][Nn]) ([Ff][Ii][Ll][Tt][Ee][Rr][Ll][Ii][Ss][Tt])$",
    "^(حذف) (لیست فیلتر)$",
    "^(.+)$",

  },
  run = run
}
