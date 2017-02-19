do

  local function tosticker(msg, success, result)
    if success then
      if msg.media and msg.media.caption:match("photo") then
        local file = './data/photos/'..msg.from.id..'.webp'
        os.rename(result, file)
        reply_document(msg.id, file, ok_cb, false)
      else
        reply_msg(msg.id, 'ax', ok_cb, false)
      end
    else
      reply_msg(msg.id, '❌ دوباره تلاش کنید !', ok_cb, false)
    end
  end
---------------
    local function tophoto(msg, success, result)
    if success then
      if msg.media then
        local file = './data/photos/'..msg.from.id..'.jpeg'
        os.rename(result, file)
        reply_photo(msg.id, file, ok_cb, false)
      else
        reply_msg(msg.id, 'ax', ok_cb, false)
      end
    else
      reply_msg(msg.id, '❌ دوباره تلاش کنید !', ok_cb, false)
    end
  end
  -------------------------------------
  local function get_variables_hash2(msg)
    if msg.to.type == 'channel' then
      return 'chat:bot'..msg.to.id..':variables'
    end
  end
  -------------------------------------
  local function get_value(msg, var_name)
    local hash = get_variables_hash2(msg)
    if hash then
      local value = redis:hget(hash, var_name)
      if not value then
        return
      else
        reply_msg(msg.id, value, ok_cb, true)
      end
    end
  end
  -------------------------------------
  local function addword(msg, name)
    local hash = 'chat:'..msg.to.id..':badword'
    redis:hset(hash, name, 'newword')
    local text = "🚫 واژه <b>"..name.." </b>فیلتر شد !"
    return reply_msg(msg.id, text, ok_cb, false)
  end

  local function get_variables_hash(msg)
    if msg.to.type == 'channel' then
    return 'chat:'..msg.to.id..':badword'
    end
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
  -------------------------------------
  local function chat_list(msg)
    local data = load_data(_config.moderation.data)
    local groups = 'groups'
    if not data[tostring(groups)] then
      return
    end
    local message = '🔹 لیست گروه های ربات :\n\n '
    local i = 0
    for k,v in pairs(data[tostring(groups)]) do

      local settings = data[tostring(v)]['settings']
      for m,n in pairsByKeys(settings) do
        if m == 'set_name' then
          i = i + 1
          name = n
        end
      end

      message = message .. '️ '..i..' - '.. name .. ' [' .. v .. ']\n\n '
    end
    local file = io.open("./groups/lists/listed_groups.txt", "w")
    file:write(message)
    file:flush()
    file:close()
    return message
  end

  local function list_chats(msg)
    local hash = get_variables_hash2(msg)

    if hash then
      local names = redis:hkeys(hash)
      local text = '♦️ دستورات تنظیم شده ربات :'
      m = 1
      for i=1, #names do
        text = text..m..' > '..names[i]..'\n'
        m = m + 1
      end
      reply_msg(msg['id'], text, ok_cb, true)
    else
      return
    end
  end

  local function save_value(msg, name, value)
    if (not name or not value) then
      reply_msg(msg['id'], "", ok_cb, true)
    end
    local hash = nil
    if msg.to.type == 'chat' or msg.to.type == 'channel'  then
      hash = 'chat:bot'..msg.to.id..':variables'

    end
    if hash then
      redis:hset(hash, name, value)
      reply_msg(msg['id'], "✅ دستور <b>"..name.." </b>ذخیره شد !", ok_cb, true)
    end
  end
  local function del_value(msg, name)
    if not name then
      return
    end
    local hash = nil
    if msg.to.type == 'chat' or msg.to.type == 'channel'  then
      hash =  'chat:bot'..msg.to.id..':variables'
    end
    if hash then
      redis:hdel(hash, name)
      reply_msg(msg['id'],  "❌ دستور <b>"..name.." </b>پاک شد !", ok_cb, true)
    end
  end

  local function delallchats(msg)
    local hash =  'chat:bot'..msg.to.id..':variables'

    if hash then
      local names = redis:hkeys(hash)
      for i=1, #names do
        redis:hdel(hash,names[i])
      end
      reply_msg(msg['id'],"❌ همه دستورات پاک شد !", ok_cb, true)
    else
      return
    end
  end

  --------------------------
  local function get_msgs_user_chat(user_id, chat_id)
    local user_info = {}
    local uhash = 'user:'..user_id
    local user = redis:hgetall(uhash)
    local um_hash = 'msgs:'..user_id..':'..chat_id
    user_info.msgs = tonumber(redis:get(um_hash) or 0)
    user_info.name = user_print_name(user)..' ['..user_id..']'
    return user_info
  end
  --------------------------
  local function chat_stat(chat_id, typee)
    -- Users on chat
    local hash = ''
    if typee == 'channel' then
      hash = 'channel:'..chat_id..':users'
    else
      hash = 'chat:'..chat_id..':users'
    end
    local users = redis:smembers(hash)
    local users_info = {}

    -- Get user info
    for i = 1, #users do
      local user_id = users[i]
      local user_info = get_msgs_user_chat(user_id, chat_id)
      table.insert(users_info, user_info)
    end

    -- Sort users by msgs number
    table.sort(users_info, function(a, b)
    if a.msgs and b.msgs then
      return a.msgs > b.msgs
    end
    end)

    local arian = '0'
    for k,user in pairs(users_info) do
      arian = arian + user.msgs
    end
    return arian
  end
  --------------------------
  local function rsusername_cb(extra, success, result)
    if success == 1 then
      local user = result.peer_id
      local chatid = get_receiver(extra.msg)
      local username = result.username
      function round2(num, idp)
        return tonumber(string.format("%." .. (idp or 0) .. "f", num))
      end

      local r = tonumber(chat_stat(extra.msg.to.id, extra.msg.to.type) or 0)

      local hashs = 'msgs:'..result.peer_id..':'..extra.msg.to.id
      local msgss = redis:get(hashs)
      local percent = msgss / r * 100
      --return send_large_msg(chatid, "🔢 تعداد پیام های شما : <b>"..msgss.." </b>\n💱 تعداد پیام های گروه : <b>"..r.."  </b>")
      return reply_msg(extra.msg.id, "🔢 تعداد پیام های شما : <b>"..msgss.." </b>\n💱 تعداد پیام های گروه : <b>"..r.."  </b>",ok_cb,false)
    end
  end
  --------------------------
  local function urlencode(str)
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
    function (c) return string.format ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
      return str
    end
    --------------------------
    -- Returns the key (index) in the config.enabled_plugins table
    local function plugin_enabled( name )
      for k,v in pairs(_config.enabled_plugins) do
        if name == v then
          return k
        end
      end
      -- If not found
      return false
    end

    -- Returns true if file exists in plugins folder
    local function plugin_exists( name )
      for k,v in pairs(plugins_names()) do
        if name..'.lua' == v then
          return true
        end
      end
      return false
    end

    local function list_all_plugins(only_enabled)
      local tmp = '\n\n'
      local text = ''
      local nsum = 0
      for k, v in pairs( plugins_names( )) do
        --  ✔ enabled, ❌ disabled
        local status = '/Disable➣'
        nsum = nsum+1
        nact = 0
        -- Check if is enabled
        for k2, v2 in pairs(_config.enabled_plugins) do
          if v == v2..'.lua' then
            status = '/Enable➣'
          end
          nact = nact+1
        end
        if not only_enabled or status == '/Enable➣' then
          -- get the name
          v = string.match (v, "(.*)%.lua")
          text = text..nsum..'.'..status..' '..v..' \n'
        end
      end
      local text = text..'\n\n'..nsum..' plugins installed\n\n'..nact..' plugins enabled\n\n'..nsum-nact..' plugins disabled'..tmp
      return text
    end

    local function list_plugins(only_enabled)
      local text = ''
      local nsum = 0
      for k, v in pairs( plugins_names( )) do
        --  ✔ enabled, ❌ disabled
        local status = '/Disable➣'
        nsum = nsum+1
        nact = 0
        -- Check if is enabled
        for k2, v2 in pairs(_config.enabled_plugins) do
          if v == v2..'.lua' then
            status = '/Enable➣'
          end
          nact = nact+1
        end
        if not only_enabled or status == '/Enable➣' then
          -- get the name
          v = string.match (v, "(.*)%.lua")
          -- text = text..v..'  '..status..'\n'
        end
      end
      local text = text.."\nAll Plugins Reloaded\n\n"..nact.." Plugins Enabled\n"..nsum.." Plugins Installed"
      return text
    end

    local function reload_plugins( )
      plugins = {}
      load_plugins()
      return list_plugins(true)
    end


    local function enable_plugin( plugin_name )
      print('checking if '..plugin_name..' exists')
      -- Check if plugin is enabled
      if plugin_enabled(plugin_name) then
        return ''..plugin_name..' is enabled'
      end
      -- Checks if plugin exists
      if plugin_exists(plugin_name) then
        -- Add to the config table
        table.insert(_config.enabled_plugins, plugin_name)
        print(plugin_name..' added to _config table')
        save_config()
        -- Reload the plugins
        return reload_plugins( )
      else
        return ''..plugin_name..' does not exists'
      end
    end

    local function disable_plugin( name, chat )
      -- Check if plugins exists
      if not plugin_exists(name) then
        return ' '..name..' does not exists'
      end
      local k = plugin_enabled(name)
      -- Check if plugin is enabled
      if not k then
        return ' '..name..' not enabled'
      end
      -- Disable and reload
      table.remove(_config.enabled_plugins, k)
      save_config( )
      return reload_plugins(true)
    end

    local function disable_plugin_on_chat(receiver, plugin)
      if not plugin_exists(plugin) then
        return "Plugin doesn't exists"
      end

      if not _config.disabled_plugin_on_chat then
        _config.disabled_plugin_on_chat = {}
      end

      if not _config.disabled_plugin_on_chat[receiver] then
        _config.disabled_plugin_on_chat[receiver] = {}
      end

      _config.disabled_plugin_on_chat[receiver][plugin] = true

      save_config()
      return ' '..plugin..' disabled on this chat'
    end

    local function reenable_plugin_on_chat(receiver, plugin)
      if not _config.disabled_plugin_on_chat then
        return 'There aren\'t any disabled plugins'
      end

      if not _config.disabled_plugin_on_chat[receiver] then
        return 'There aren\'t any disabled plugins for this chat'
      end

      if not _config.disabled_plugin_on_chat[receiver][plugin] then
        return 'This plugin is not disabled'
      end

      _config.disabled_plugin_on_chat[receiver][plugin] = false
      save_config()
      return ' '..plugin..' is enabled again'
    end
    -----------------------
    local function clean_msg(extra, success, result)
      --print(serpent.block(result))
      for i=1, #result do
        if result.service then
        else
          delete_msg(result[i].id, ok_cb, false)
          delete_msg(result[i].temp_id, ok_cb, false)
        end
      end
        reply_msg(extra.msg.id, '🗑 '..extra.con..' پیام پاک شد !', ok_cb, false)
    end
    --------------------------
    local function calc(exp)
      url = 'http://api.mathjs.org/v1/'
      url = url..'?expr='..URL.escape(exp)
      b,c = http.request(url)
      text = nil
      if c == 200 then
        text = '✴️ پاسخ : \n'..b
      elseif c == 400 then
        text = b
      else
        --text = 'Unexpected error\n'
        --..'Is api.mathjs.org up?'
      end
      return text
    end
    --------------------------

    function run(msg, matches, callback, extra)
      if msg.from.username ~= nil then
       uname = '@'..msg.from.username
      else
       uname = msg.from.first_name..' ['..msg.from.id..']'
      end
      --------------------------
      if matches[1]:lower()== "rmsg" and msg.to.type == "channel" or matches[1]:lower() == "حذف" and msg.to.type == "channel" then
      if not is_momod(msg) then
        return
      end  
        if redis:get("rmsg:"..msg.to.id..":"..msg.from.id) and not is_sudo(msg) then
          local n = redis:get("rmsg:"..msg.to.id..":"..msg.from.id)
          local date = redis:ttl("rmsg:"..msg.to.id..":"..msg.from.id)
          local text = "⚠️ کاربر "..uname.."، شما <b>"..date.." </b>ثانیه دیگر میتوانید پیام ها را پاک کنید !"
          return reply_msg(msg.id, text, ok_cb, false)
        end
        if tonumber(matches[2]) > 50000 or tonumber(matches[2]) < 1 then
          local text = "⚠️ عددی بین <b>1 </b>تا <b>50000 </b>وارد کنید !"
          return reply_msg(msg.id, text, ok_cb, false)
        end
        redis:setex("rmsg:"..msg.to.id..":"..msg.from.id, 30, true)
        get_history(msg.to.peer_id, matches[2] + 1 , clean_msg , { msg = msg,con = matches[2]})
      end
      --------------------------
      if matches[1]:lower() == "serverinfo" and is_sudo(msg) then
        local text = io.popen("sh ./data/cmd.sh"):read("*all")
        return text
      end
      --------------------------
      if matches[1]:lower() == "addme" and is_sudo(msg) then
        local user = 'user#id'..250877155
        local channel = 'channel#id'..matches[2]
        channel_invite(channel, user, ok_cb, false)
      end
      --------------------------
      if matches[1]:lower() == 'block' and is_sudo(msg) or matches[1]:lower() == 'مسدود' and is_sudo(msg) then
        block_user("user#id"..matches[2],ok_cb,false)
        reply_msg(msg.id, '🚫 کاربر مسدود شد !', ok_cb, false)
      end
      if matches[1]:lower() == 'unblock' and is_sudo(msg) or matches[1]:lower() == 'حذف مسدود' and is_sudo(msg) then
        unblock_user("user#id"..matches[2], ok_cb,false)
        reply_msg(msg.id, '✅ کاربر از مسدودی در آمد !', ok_cb, false)
      end
      --------------------------

      if matches[1]:lower() == 'chat_add_user' or matches[1]:lower() == 'chat_add_user_link' or matches[1]:lower() == 'channel_invite' and redis:hget('group:'..msg.to.id,'welcome') then

        if not msg.service then
          return reply_msg(msg.id,"داداچ کرم نریز 😐",ok_cb,false)
        end

        --local url , res = http.request('http://api.gpmod.ir/time/')
        --if res ~= 200 then
        --  return
       -- end
       -- local jdat = json:decode(url)
        local hash = 'group:'..msg.to.id
        local group_welcome = redis:hget(hash,'welcome')
        return reply_msg(msg.id, group_welcome, ok_cb, false)
      end
      --------------------------
      if matches[1]:lower()== 'setwlc' and matches[2] and is_momod(msg) or matches[1] == 'تنظیم خوشامد گویی' and matches[2] and is_momod(msg) then
        local hash = 'group:'..msg.to.id
        local group_welcome = redis:hget(hash,'welcome')
        redis:hset(hash,'welcome', matches[2])
        local text = '📋 متن خوش آمد گویی گروه تنظیم شد !\n<b>'..matches[2]..' </b>\n'
        return reply_msg(msg.id,text, ok_cb, false)
      end
      --------------------------
      if matches[1]:lower()== 'clean' and matches[2] == 'welcome' or matches[1] == 'حذف' and matches[1] == 'خوشامد گویی' then
      if not is_momod(msg) then
       return
      end  
        local hash = 'group:'..msg.to.id
        local group_welcome = redis:hget(hash,'welcome')
        redis:hdel(hash,'welcome')
        local text = '🗑 متن خوش آمد گویی حذف شد !'
        return reply_msg(msg.id,text, ok_cb, false)
      end
      --------------------------
      if matches[1]:lower()== 'filter' or matches[1]:lower() == 'فیلتر' then
        if not is_momod(msg) then
          return
        end
        local name = string.sub(matches[2], 1, 50)
        local text = addword(msg, name)
        return text
      end

      if matches[1]:lower() == 'filterlist' or matches[1]:lower() == 'لیست فیلتر' then
        if not is_momod(msg) then
          return
        end
        return list_variablesbad(msg)
      end

      if matches[1]:lower() == 'clean' or matches[1]:lower() == 'حذف' and matches[2] == 'filterlist' or matches[2] == 'لیست فیلتر' then
        if not is_momod(msg) then
          return
        end
        local asd = '1'
        return clear_commandbad(msg, asd)
      end

      if matches[1]:lower() == 'unfilter' or matches[1]:lower() == 'حذف فیلتر' then
        if not is_momod(msg) then
          return
        end
        return clear_commandsbad(msg, matches[2])
      end
      -----------------

      if matches[1]:lower()== "calc" or matches[1] == "ماشین حساب" then
        if redis:get("calc:"..msg.to.id..":"..msg.from.id) and not is_momod(msg) then
          return reply_msg(msg.id, "⚠️ کاربر "..uname.."، شما می توانید <b>30 </b>ثانیه دیگر از این دستور استفاده کنید !", ok_cb, false)
        end
        redis:setex("calc:"..msg.to.id..":"..msg.from.id, 30, true)
        local text = calc(matches[2])
        return reply_msg(msg.id, text, ok_cb, false)
      end
      ---------------------
      if matches[1]:lower()== 'me' or matches[1] == 'اطلاعات من' then
        if redis:get("me:"..msg.to.id..":"..msg.from.id) and not is_sudo(msg) then
          return reply_msg(msg.id, "⚠️ کاربر "..uname.."، خواهشمند است <b>1 </b>دقیقه دیگر از این دستور استفاده کنید !", ok_cb, false)
        end
        local chat_id = msg.to.id
        resolve_username(msg.from.username, rsusername_cb, {msg=msg})
         if is_sudo(msg) then
           tt = "سازنده ربات"
          elseif is_admin1(msg) then
          tt = "ادمین ربات"
          elseif is_owner(msg) then
           tt = "صاحب گروه"
          elseif is_momod(msg) then
           tt = "مدیر گروه"
          else
          tt = "کاربر"
         end        
          local modes = {'comics-logo','water-logo','3d-logo','blackbird-logo','runner-logo','graffiti-burn-logo','electric','standing3d-logo','style-logo','steel-logo','fluffy-logo','surfboard-logo','orlando-logo','fire-logo','clan-logo','chrominium-logo','harry-potter-logo','amped-logo','inferno-logo','uprise-logo','winner-logo','star-wars-logo'}
          local text = URL.escape(tt)
          local url = 'http://www.flamingtext.com/net-fu/image_output.cgi?_comBuyRedirect=false&script='..modes[math.random(#modes)]..'&text='..text..'&symbol_tagname=popular&fontsize=70&fontname=futura_poster&fontname_tagname=cool&textBorder=15&growSize=0&antialias=on&hinting=on&justify=2&letterSpacing=0&lineSpacing=0&textSlant=0&textVerticalSlant=0&textAngle=0&textOutline=off&textOutline=false&textOutlineSize=2&textColor=%230000CC&angle=0&blueFlame=on&blueFlame=false&framerate=75&frames=5&pframes=5&oframes=4&distance=2&transparent=off&transparent=false&extAnim=gif&animLoop=on&animLoop=false&defaultFrameRate=75&doScale=off&scaleWidth=240&scaleHeight=120&&_=1469943010141'
          local title , res = http.request(url)
          local jdat = json:decode(title)
          local gif = jdat.src
          local file = download_to_file(gif,'sticker.webp') 
          reply_document(msg.id, file, ok_cb, false)
          redis:setex("me:"..msg.to.id..":"..msg.from.id, 30, true)      
      end
      ---------------------
      if matches[1]:lower()== 'time' or matches[1] == 'زمان' then
        if redis:get("time:"..msg.to.id..":"..msg.from.id) and not is_sudo(msg) then
          return reply_msg(msg.id, "⚠️ کاربر "..uname.."،خواهشمند است <b>1 </b>دقیقه دیگر از این دستور استفاده کنید !", ok_cb, false)
        end
        redis:setex("time:"..msg.to.id..":"..msg.from.id, 60, true)
        local url , res = http.request('http://api.gpmod.ir/time/')
        if res ~= 200 then
          return
        end
        local colors = {'blue','green','yellow','magenta','Orange','DarkOrange','red'}
        local fonts = {'mathbf','mathit','mathfrak','mathrm'}
        local jdat = json:decode(url)
        local url = 'http://latex.codecogs.com/png.download?'..'\\dpi{600}%20\\huge%20\\'..fonts[math.random(#fonts)]..'{{\\color{'..colors[math.random(#colors)]..'}'..jdat.ENtime..'}}'
        local file = download_to_file(url,'time.jpeg')
        local a = '▪️ ساعت : '..jdat.FAtime..'\n🔹 تاریخ شمسی : '..jdat.FAdate..'\n🔸 تاریخ میلادی : '..jdat.ENdate..'\n'
        send_photo2(get_receiver(msg), file, a, ok_cb, false)
        --send_document(get_receiver(msg) , file, ok_cb, false)
        --reply_document(msg.id , file, ok_cb, false)      
      end
      --------------------
      if matches[1]:lower()== "sticker" and msg.reply_id then
        load_photo(msg.reply_id, tosticker, msg)
      end
      if matches[1]:lower()== "photo" and msg.reply_id then
        load_document(msg.reply_id, tophoto, msg)
      end    
      ---------------------
      if matches[1]:lower()== "chats" and is_sudo(msg) then
        return chat_list(msg)
      end

      --------------------
      if matches[1]:lower()== 'voice' then
        if string.len(matches[2]) > 20 and not is_momod(msg) then
          return reply_msg(msg.id, "داداچ داری اشتباه میزنی", ok_cb, false)
        end

        if redis:get("voice:"..msg.to.id..":"..msg.from.id) and not is_sudo(msg) then
          return reply_msg(msg.id, "⚠️ لطفا <b>1 </b>دقیقه دیگر از این دستور استفاده کنید !", ok_cb, false)
        end
        redis:setex("voice:"..msg.to.id..":"..msg.from.id, 60, true)

        local text = matches[2]
        --local b = 1
        --while b ~= 0 do
          -- textc = text:trim()
          --  text,b = text:gsub(' ','.')

          --local url = "http://tts.baidu.com/text2audio?lan=en&ie=UTF-8&text="..textc
          --local url = "http://translate.google.com/translate_tts?ie=UTF-8&q="..textc.."&tl=en-us"
          local ent = urlencode(text)
          local url = "http://api.farsireader.com/ArianaCloudService/ReadTextGET?APIKey=6RNRDCM1NKEPD74&Text="..ent.."&Speaker=Female1&Format=mp3%2F32%2Fm&GainLevel=0&PitchLevel=0&PunctuationLevel=0&SpeechSpeedLevel=0&ToneLevel=0"
          --local url = "https://irapi.ir/aryana/api.php?text="..matches[2]
          --local file = download_to_file(url,'voice.ogg')
          send_audio('channel#id'..msg.to.id, file, ok_cb , false)
          local file = download_to_file(url, 'voice.ogg')
          --reply_file(msg.id, file, ok_cb,false)
          send_audio(get_receiver(msg), file, ok_cb, false)
          --if not msg.reply_id then
            --reply_file(msg.id, file, ok_cb, false)
            --else
            -- reply_file(msg.reply_id, file, ok_cb, false)
            --end
          end
          --------------------------
          if matches[1]:lower()== "update" and is_sudo(msg) then
            text = io.popen("git pull "):read('*all')
            --return text
            return reply_msg(msg.id, text, ok_cb, false)
          end
          --------------------------
          if matches[1]:lower()== 'leave' and is_admin1(msg) then
            --local bot_id = our_id
            --chat_del_user("chat#id"..msg.to.id, 'user#id'..bot_id, ok_cb, false)
            leave_channel(get_receiver(msg), ok_cb, false)
          end
          --------------------------
          if matches[1]:lower()== 'short' and is_sudo(msg) then
            local yon = http.request('http://api.yon.ir/?url='..URL.escape(matches[2]))
            local jdat = json:decode(yon)
            local bitly = https.request('https://api-ssl.bitly.com/v3/shorten?access_token=f2d0b4eabb524aaaf22fbc51ca620ae0fa16753d&longUrl='..URL.escape(matches[2]))
            local data = json:decode(bitly)
            local yeo = http.request('http://yeo.ir/api.php?url='..URL.escape(matches[2])..'=')
            local opizo = http.request('http://api.gpmod.ir/shorten/?url='..URL.escape(matches[2])..'&username=mersad565@gmail.com')
            local u2s = http.request('http://u2s.ir/?api=1&return_text=1&url='..URL.escape(matches[2]))
            local llink = http.request('http://llink.ir/yourls-api.php?signature=a13360d6d8&action=shorturl&url='..URL.escape(matches[2])..'&format=simple')
            return ' 🌐لینک اصلی :\n'..data.data.long_url..'\n\nلینکهای کوتاه شده با 6 سایت کوتاه ساز لینک : \n》کوتاه شده با bitly :\n___________________________\n'..data.data.url..'\n___________________________\n》کوتاه شده با yeo :\n'..yeo..'\n___________________________\n》کوتاه شده با اوپیزو :\n'..opizo..'\n___________________________\n》کوتاه شده با u2s :\n'..u2s..'\n___________________________\n》کوتاه شده با llink : \n'..llink..'\n___________________________\n》لینک کوتاه شده با yon : \nyon.ir/'..jdat.output..'\n____________________\n'
          end
          --------------------------

          if matches[1]:lower()== "sticker" or matches[1] == "استیکر" then
            local modes = {'comics-logo','water-logo','3d-logo','blackbird-logo','runner-logo','graffiti-burn-logo','electric','standing3d-logo','style-logo','steel-logo','fluffy-logo','surfboard-logo','orlando-logo','fire-logo','clan-logo','chrominium-logo','harry-potter-logo','amped-logo','inferno-logo','uprise-logo','winner-logo','star-wars-logo'}
            local text = URL.escape(matches[2])
            local url = 'http://www.flamingtext.com/net-fu/image_output.cgi?_comBuyRedirect=false&script='..modes[math.random(#modes)]..'&text='..text..'&symbol_tagname=popular&fontsize=70&fontname=futura_poster&fontname_tagname=cool&textBorder=15&growSize=0&antialias=on&hinting=on&justify=2&letterSpacing=0&lineSpacing=0&textSlant=0&textVerticalSlant=0&textAngle=0&textOutline=off&textOutline=false&textOutlineSize=2&textColor=%230000CC&angle=0&blueFlame=on&blueFlame=false&framerate=75&frames=5&pframes=5&oframes=4&distance=2&transparent=off&transparent=false&extAnim=gif&animLoop=on&animLoop=false&defaultFrameRate=75&doScale=off&scaleWidth=240&scaleHeight=120&&_=1469943010141'
            local title , res = http.request(url)
            local jdat = json:decode(title)
            local gif = jdat.src
            local file = download_to_file(gif,'sticker.webp')
            --send_document(get_receiver(msg), file, ok_cb, false)
            if not msg.reply_id then
              reply_document(msg.id, file, ok_cb, false)
            else
              reply_document(msg.reply_id, file, ok_cb, false)
            end
          end
          --------------------------
          -- Show the available plugins
          if matches[1]:lower()== 'p' and is_sudo(msg) then
            local text = list_all_plugins()
            return reply_msg(msg.id, text, ok_cb, false)
          end

          -- Re-enable a plugin for this chat
          if matches[1]:lower()== '+' and matches[3] == 'chat' and is_sudo(msg) then
            local receiver = get_receiver(msg)
            local plugin = matches[2]
            --print("enable "..plugin..' on this chat')
            local text = reenable_plugin_on_chat(receiver, plugin)
            return reply_msg(msg.id, text, ok_cb, false)
          end

          -- Enable a plugin
          if matches[1]:lower()== '+' and is_sudo(msg) then
            local plugin_name = matches[2]
            --print("enable: "..matches[2])
            local text = enable_plugin(plugin_name)
            return reply_msg(msg.id, text, ok_cb, false)
          end

          -- Disable a plugin on a chat
          if matches[1]:lower()== '-' and matches[3] == 'chat' and is_sudo(msg) then
            local plugin = matches[2]
            local receiver = get_receiver(msg)
            --print("disable "..plugin..' on this chat')
            local text = disable_plugin_on_chat(receiver, plugin)
            return reply_msg(msg.id, text, ok_cb, false)
          end

          -- Disable a plugin
          if matches[1]:lower()== '-' and is_sudo(msg) then
            --print("disable: "..matches[2])
            local text = disable_plugin(matches[2])
            return reply_msg(msg.id, text, ok_cb, false)
          end

          -- Reload all the plugins!
          if matches[1]:lower()== 'r' and is_sudo(msg) then
            local text = reload_plugins(true)
            return reply_msg(msg.id, text, ok_cb, false)
          end
          --------------------------
          if matches[1]:lower() == "value" and matches[2] == "+" and is_momod(msg) then
            return save_value(msg, matches[3], matches[4])
          end
          if matches[1]:lower() == "value" and matches[2] == "-" and is_momod(msg) then
            return del_value(msg, matches[3])
          end
          if matches[1]:lower() == "value" and matches[2] == 'clean' and is_owner(msg) then
            return delallchats(msg)
          end
          if matches[1]:lower() == 'value' and matches[2] == "list" and is_momod(msg) then
            return list_chats(msg)
          end
          --[[ if msg.text:match("^(.+)$") then
            return get_value(msg, matches[1]:lower():lower())
            end]]
            --------------------------
            if matches[1]:lower()== "gif" then
              local modes = {'memories-anim-logo','alien-glow-anim-logo','flash-anim-logo','flaming-logo','whirl-anim-logo','highlight-anim-logo','burn-in-anim-logo','shake-anim-logo','inner-fire-anim-logo','jump-anim-logo'}
              local text = URL.escape(matches[2])
              local url2 = 'http://www.flamingtext.com/net-fu/image_output.cgi?_comBuyRedirect=false&script='..modes[math.random(#modes)]..'&text='..text..'&symbol_tagname=popular&fontsize=70&fontname=futura_poster&fontname_tagname=cool&textBorder=15&growSize=0&antialias=on&hinting=on&justify=2&letterSpacing=0&lineSpacing=0&textSlant=0&textVerticalSlant=0&textAngle=0&textOutline=off&textOutline=false&textOutlineSize=2&textColor=%230000CC&angle=0&blueFlame=on&blueFlame=false&framerate=75&frames=5&pframes=5&oframes=4&distance=2&transparent=off&transparent=false&extAnim=gif&animLoop=on&animLoop=false&defaultFrameRate=75&doScale=off&scaleWidth=240&scaleHeight=120&&_=1469943010141'
              local title , res = http.request(url2)
              local jdat = json:decode(title)
              local gif = jdat.src
              local file = download_to_file(gif,'t2g.gif')
              --send_document(get_receiver(msg), file, ok_cb, false)
              reply_document(msg.id, file, ok_cb, false)
            end
            --------------------------
            if matches[1]:lower()== "love" then
              local text1 = matches[2]
              local text2 = matches[3]
              local url = "http://www.iloveheartstudio.com/-/p.php?t="..text1.."%20%EE%BB%AE%20"..text2.."&bc=FFFFFF&tc=000000&hc=ff0000&f=c&uc=true&ts=true&ff=PNG&w=500&ps=sq"
              local file = download_to_file(url,'love.webp')
              --send_document(get_receiver(msg), file, ok_cb, false)
              reply_document(msg.id, file, ok_cb, false)
            end
            ---------------------
            if msg.text:match("(.+)$") then
              --list_variables2(msg, msg.text)
              get_value(msg, matches[1]:lower():lower())
            end
          end
        end
        return {
          patterns = {
            "^([Rr][Mm][Ss][Gg]) (%d*)$",
            "^(پاک) (%d*)$",
    
            "^([Cc][Aa][Ll][Cc]) (.*)$",
            "^(ماشین حساب) (.*)$",

            "^(block) (.*)$",
            "^(unblock) (.*)$",
            "^(addme) (.*)$",
    
            "^([Tt][Ii][Mm][Ee])$",
            "^(زمان)$",
    
            "^([Vv][Oo][Ii][Cc][Ee]) +(.*)$",
            --"^([Mm]ean) (.*)$",
            "^([Ss]hort) (.*)$",
                "^(photo)$",

            "^([Mm][Ee])$",
            "^(اطلاعات من)$",
    
            "^([Gg][Ii][Ff]) (.*)$",
    
            "^([Ss][Tt][Ii][Cc][Kk][Ee][Rr]) (.*)$",
            "^(استیکر) (.*)$",   
    
            "^(love) (.+) (.+)$",
            "^[Uu][Pp][Dd][Aa][Tt][Ee]$",
            "^([Ll][Ee][Aa][Vv][Ee])$",
           -- "^serverinfo$",
            "^[Pp]$",
            "^[Pp]? (+) ([%w_%.%-]+)$",
            "^[Pp]? (-) ([%w_%.%-]+)$",
            "^[Pp]? (+) ([%w_%.%-]+) (chat)",
            "^[Pp]? (-) ([%w_%.%-]+) (chat)",
            "^[Rr]$",

            "^(value) (list)$",
            "^(value) (clean)$",
            "^(value) (+) ([^%s]+) (.+)$",
            "^(value) (-) (.*)$",


            "^([Ss][Ee][Tt][Ww][Ll][Cc]) +(.*)$",
            "^([Cc][Ll][Ee][Aa][Nn]) (welcome)$",

            "^([Cc]hats)$",

            "^([Ff][Ii][Ll][Tt][Ee][Rr]) (.*)$",
            "^(فیلتر) (.*)$",

            "^([Uu][Nn][Ff][Ii][Ll][Tt][Ee][Rr]) (.*)$",
            "^(حذف فیلتر) (.*)$",

            "^([Ff][Ii][Ll][Tt][Ee][Rr][Ll][Ii][Ss][Tt])$",
            "^(لیست فیلتر)$",

            "^([Cc][Ll][Ee][Aa][Nn]) ([Ff][Ii][Ll][Tt][Ee][Rr][Ll][Ii][Ss][Tt])$",
            "^(حذف) (لیست فیلتر)$",


            "^!!tgservice (chat_add_user)$",
            "^!!tgservice (channel_invite)$",
            "^!!tgservice (chat_add_user_link)$",

            "%[(photo)%]",
            --"(.+)$"
          },
          run = run,
          moderated = true, -- set to moderator mode
        }
