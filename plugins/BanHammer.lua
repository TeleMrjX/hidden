
local function pre_process(msg)
  local data = load_data(_config.moderation.data)
  -- SERVICE MESSAGE
  if msg.action and msg.action.type then
    local action = msg.action.type
    -- Check if banned user joins chat by link
    if action == 'chat_add_user_link' then
      local user_id = msg.from.id
      print('Checking invited user '..user_id)
      local banned = is_banned(user_id, msg.to.id)
      if banned or is_gbanned(user_id) then -- Check it with redis
      print('User is banned!')
      local print_name = user_print_name(msg.from):gsub("‮", "")
	  local name = print_name:gsub("_", "")
      --savelog(msg.to.id, name.." ["..msg.from.id.."] is banned and kicked ! ")-- Save to logs				
      kick_user(user_id, msg.to.id)
      end
    end
    -- Check if banned user joins chat
    if action == 'chat_add_user' then
      local user_id = msg.action.user.id
      print('Checking invited user '..user_id)
      local banned = is_banned(user_id, msg.to.id)
      if banned and not is_momod2(msg.from.id, msg.to.id) or is_gbanned(user_id) and not is_admin2(msg.from.id) then -- Check it with redis
        print('User is banned!')
      local print_name = user_print_name(msg.from):gsub("‮", "")
	  local name = print_name:gsub("_", "")
        savelog(msg.to.id, name.." ["..msg.from.id.."] added a banned user >"..msg.action.user.id)-- Save to logs
        kick_user(user_id, msg.to.id)
        local banhash = 'addedbanuser:'..msg.to.id..':'..msg.from.id
        redis:incr(banhash)
        local banhash = 'addedbanuser:'..msg.to.id..':'..msg.from.id
        local banaddredis = redis:get(banhash)
        if banaddredis then
          if tonumber(banaddredis) >= 4 and not is_owner(msg) then
            kick_user(msg.from.id, msg.to.id)-- Kick user who adds ban ppl more than 3 times
          end
          if tonumber(banaddredis) >=  8 and not is_owner(msg) then
            ban_user(msg.from.id, msg.to.id)-- Kick user who adds ban ppl more than 7 times
            local banhash = 'addedbanuser:'..msg.to.id..':'..msg.from.id
            redis:set(banhash, 0)-- Reset the Counter
          end
        end
      end
     if data[tostring(msg.to.id)] then
       if data[tostring(msg.to.id)]['settings'] then
         if data[tostring(msg.to.id)]['settings']['lock_bot'] then
           bots_protection = data[tostring(msg.to.id)]['settings']['lock_bot']
          end
        end
      end
    if msg.action.user.username ~= nil then
      if string.sub(msg.action.user.username:lower(), -3) == 'bot' and not is_momod(msg) and bots_protection == "yes" then --- Will kick bots added by normal users
          --local print_name = user_print_name(msg.from):gsub("‮", "")
		  --local name = print_name:gsub("_", "")
          --savelog(msg.to.id, name.." ["..msg.from.id.."] added a bot > @".. msg.action.user.username)-- Save to logs
	 if msg.from.usrname ~= nil then
	   uname = '@'..msg.from.username
	   else
	   uname = msg.from.first_name..' ['..msg.from.id..']'					
	 end					
	  reply_msg(msg.id, '⚠️ کاربر '..uname..' ربات @'..msg.action.user.username..' را عضو کرد !', ok_cb, false)				
          kick_user(msg.action.user.id, msg.to.id)
      end
    end
  end
    -- No further checks
  return msg
  end
  -- banned user is talking !
  if msg.to.type == 'chat' or msg.to.type == 'channel' then
    local group = msg.to.id
    local texttext = 'groups'
    --if not data[tostring(texttext)][tostring(msg.to.id)] and not is_realm(msg) then -- Check if this group is one of my groups or not
    --chat_del_user('chat#id'..msg.to.id,'user#id'..our_id,ok_cb,false)
    --return
    --end
    local user_id = msg.from.id
    local chat_id = msg.to.id
    local banned = is_banned(user_id, chat_id)
    if banned or is_gbanned(user_id) then -- Check it with redis
      print('Banned user talking!')
      local print_name = user_print_name(msg.from):gsub("‮", "")
	  local name = print_name:gsub("_", "")
     -- savelog(msg.to.id, name.." ["..msg.from.id.."] banned user is talking !")-- Save to logs
      if msg.from.username ~= nil then
	name = msg.from.username
       else
	name = msg.from.first_name				
      end					
      --reply_msg(msg.id, "⭕️ کاربر "..name.." از گروه محروم است و اخراج شد !", ok_cb, false)			
      kick_user(user_id, chat_id)
      msg.text = ''
    end
  end
  return msg
end

function Ban_List(msg, chat_id)
	local hash =  'banned:'..chat_id
	local list = redis:smembers(hash)
	local text = "📃 لیست کاربران محروم شده از گروه <i>"..msg.to.title.." </i>:\n"
	for k,v in pairs(list) do
	local user_info = redis:hgetall('user:'..v)
		if user_info and user_info.print_name then
			local print_name = string.gsub(user_info.print_name, "_", " ")
			local print_name = string.gsub(print_name, "‮", "")
			text = text..k.." - "..print_name.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	return text
end

local function kick_ban_res(extra, success, result)
      local chat_id = extra.chat_id
	  local chat_type = extra.chat_type
	  if chat_type == "chat" then
		receiver = 'chat#id'..chat_id
	  else
		receiver = 'channel#id'..chat_id
	  end
	  if success == 0 then
		return reply_msg(extra.msg.id, "⛔️ نام کاربری اشتباه است !", ok_cb, false)
	  end
      local member_id = result.peer_id
      local user_id = member_id
      local member = result.username
	  local from_id = extra.from_id
      local get_cmd = extra.get_cmd
       if get_cmd == "kick" then
         if member_id == from_id then
	     reply_msg(extra.msg.id, "⛔️ شما نمی توانید خودتان را اخراج کنید !", ok_cb, false)	
	     return
         end
         if is_momod2(member_id, chat_id) or is_admin2(sender) then
	     reply_msg(extra.msg.id, "⛔️ شما نمی توانید مدیران را اخراج کنید !", ok_cb, false)	
			return
         end
		 kick_user(member_id, chat_id)
	         reply_msg(extra.msg.id, "❌ کاربر "..extra.user.." اخراج شد ! ", ok_cb, false)	
      elseif get_cmd == 'ban' then
         if member_id == from_id then
	     reply_msg(extra.msg.id, "⛔️ شما نمی توانید خودتان را محروم کنید !", ok_cb, false)	
	     return
         end
         if is_momod2(member_id, chat_id) or is_admin2(sender) then
	                reply_msg(extra.msg.id, "⛔️ شما نمی توانید مدیران را محروم کنید !", ok_cb, false)	
			return
         end
                reply_msg(extra.msg.id, "❌ کاربر ["..member_id.."] @"..member.." از گروه محروم شد !", ok_cb, false)
		ban_user(member_id, chat_id)
      elseif get_cmd == 'unban' then
        reply_msg(extra.msg.id, "🚫 کاربر ["..member_id.."] @"..member.." از محرومیت در آمد !", ok_cb, false)
        --send_large_msg(receiver, 'User @'..member..' ['..member_id..'] unbanned')
        local hash =  'banned:'..chat_id
        redis:srem(hash, member_id)
        --return 'User '..user_id..' unbanned'
      elseif get_cmd == 'banall' then
                reply_msg(extra.msg.id, "❌ کاربر ["..member_id.."] @"..member.." سوپر بن شد !", ok_cb, false)
		banall_user(member_id)
      elseif get_cmd == 'unbanall' then
            reply_msg(extra.msg.id, "🚫 کاربر ["..member_id.."] @"..member.." از سوپر بن در آمد !", ok_cb, false)
	    unbanall_user(member_id)
    end
end

local function Kick_reply(extra, success, result)
	if type(result) == 'boolean' then
		print('This is a old message!')
		reply_msg(extra.msg.id, "🌀 پیام قدیمی می باشد !\n برای اخراج کاربر از شناسه یا نام کاربری استفاده کنید .", ok_cb, false)
		return
	end
	if is_momod2(result.from.peer_id, result.to.peer_id) or is_admin2(result.from.peer_id) then
	     reply_msg(extra.msg.id, "⛔️ شما نمی توانید مدیران را اخراج کنید !", ok_cb, false)	
	else			
         reply_msg(extra.msg.id, "❌ کاربر اخراج شد !", ok_cb, false)	
         channel_kick('channel#id'..result.to.peer_id, 'user#id'..result.from.peer_id, ok_cb, false)
	end	
end

local function Ban_reply(extra, success, result)
	if type(result) == 'boolean' then
		print('This is a old message!')
		reply_msg(extra.msg.id, "🌀 پیام قدیمی می باشد !\n برای محروم کردن کاربر از شناسه یا نام کاربری استفاده کنید .", ok_cb, false)
		return
	end
	if is_momod2(result.from.peer_id, result.to.peer_id) or is_admin2(result.from.peer_id) then
	     reply_msg(extra.msg.id, "⛔️ شما نمی توانید مدیران را محروم کنید !", ok_cb, false)	
	else			
          reply_msg(extra.msg.id, "❌ کاربر محروم شد !", ok_cb, false)	
	  ban_user(result.from.peer_id, result.to.peer_id)
	end	
end

local function Unban_reply(extra, success, result)
	if type(result) == 'boolean' then
		print('This is a old message!')
		reply_msg(extra.msg.id, "🌀 پیام قدیمی می باشد !\n برای حذف محرومیت کاربر از شناسه یا نام کاربری استفاده کنید .", ok_cb, false)
		return
	end		
          reply_msg(extra.msg.id, "❌ کاربر از محرومیت در آمد !", ok_cb, false)	
	  local hash =  'banned:'..result.to.peer_id
	  redis:srem(hash, result.from.peer_id)		
end

local function Banall_reply(extra, success, result)
	if type(result) == 'boolean' then
		print('This is a old message!')
		reply_msg(extra.msg.id, "🌀 پیام قدیمی می باشد !\n برای سوپر بن کردن کاربر از شناسه یا نام کاربری استفاده کنید .", ok_cb, false)
		return
	end
	if is_momod2(result.from.peer_id, result.to.peer_id) or is_admin2(result.from.peer_id) then
	     reply_msg(extra.msg.id, "⛔️ شما نمی توانید مدیران را سوپر بن کنید !", ok_cb, false)	
	else	
          reply_msg(extra.msg.id, "❌ کاربر سوپر بن شد !", ok_cb, false)	
          banall_user(result.from.peer_id)
	end	
end

local function Unbanall_reply(extra, success, result)
	if type(result) == 'boolean' then
		print('This is a old message!')
		reply_msg(extra.msg.id, "🌀 پیام قدیمی می باشد !\n برای حذف سوپر بن کاربر از شناسه یا نام کاربری استفاده کنید .", ok_cb, false)
		return
	end		
          reply_msg(extra.msg.id, "❌ کاربر از سوپر بن در آمد !", ok_cb, false)	
          banall_user(result.from.peer_id)	
end

local function run(msg, matches)
local support_id = msg.from.id
 if matches[1]:lower() == 'id' and msg.to.type == "chat" or msg.to.type == "user" then
    if msg.to.type == "user" then
      return "Bot ID: "..msg.to.id.. "\n\nYour ID: "..msg.from.id
    end
    if type(msg.reply_id) ~= "nil" then
      local print_name = user_print_name(msg.from):gsub("‮", "")
	  local name = print_name:gsub("_", "")
        savelog(msg.to.id, name.." ["..msg.from.id.."] used /id ")
        id = get_message(msg.reply_id,get_message_callback_id, false)
    elseif matches[1]:lower() == 'id' then
      local name = user_print_name(msg.from)
      savelog(msg.to.id, name.." ["..msg.from.id.."] used /id ")
      return "Group ID for " ..string.gsub(msg.to.print_name, "_", " ").. ":\n\n"..msg.to.id
    end
  end
  if matches[1]:lower() == 'kickme' and msg.to.type == "chat" then-- /kickme
  local receiver = get_receiver(msg)
    if msg.to.type == 'chat' then
      local print_name = user_print_name(msg.from):gsub("‮", "")
	  local name = print_name:gsub("_", "")
      savelog(msg.to.id, name.." ["..msg.from.id.."] left using kickme ")-- Save to logs
      chat_del_user("chat#id"..msg.to.id, "user#id"..msg.from.id, ok_cb, false)
    end
  end

  if not is_momod(msg) then -- Ignore normal users
    return
  end

  if matches[1]:lower() == "banlist" then -- Ban list !
    local chat_id = msg.to.id
    if matches[2] and is_admin1(msg) then
      chat_id = matches[2]
    end
    return Ban_List(msg, chat_id)
  end
	
  if matches[1]:lower() == 'ban' or matches[1] == 'محروم' then-- /ban
    if type(msg.reply_id) ~= "nil" and is_momod(msg) then
     -- if is_admin1(msg) then
	--	msgr = get_message(msg.reply_id,ban_by_reply_admins, false)
      --else
       -- msgr = get_message(msg.reply_id,ban_by_reply, false)
       get_message(msg.reply_id, Ban_reply, {msg=msg})			
      --end
      local user_id = matches[2]
      local chat_id = msg.to.id
    elseif string.match(matches[2], '^%d+$') then
		if is_momod2(tonumber(matches[2]), msg.from.id) or is_admin2(tonumber(matches[2])) then
			return reply_msg(msg.id, "⛔️ شما نمی توانید مدیران را محروم کنید !", ok_cb, false)
		end
		if tonumber(matches[2]) == tonumber(msg.from.id) then
			return reply_msg(msg.id, "⛔️ شما نمی توانید خودتان را محروم کنید !", ok_cb, false)
		end
        local print_name = user_print_name(msg.from):gsub("‮", "")
	    local name = print_name:gsub("_", "")
		local receiver = get_receiver(msg)
        --savelog(msg.to.id, name.." ["..msg.from.id.."] baned user ".. matches[2])
                ban_user(matches[2], msg.to.id)
		reply_msg(msg.id, "❌ کاربر محروم شد !", ok_cb, false)
      else
		local cbres_extra = {
		chat_id = msg.to.id,
		get_cmd = 'ban',
		from_id = msg.from.id,
		chat_type = msg.to.type,
	        msg = msg,
		user = matches[2]			
		}
		local username = string.gsub(matches[2], '@', '')
		resolve_username(username, kick_ban_res, cbres_extra)
    end
  end


  if matches[1]:lower() == 'unban' or matches[1] == 'حذف محروم' then -- /unban
    if type(msg.reply_id) ~= "nil" and is_momod(msg) then
      --local msgr = get_message(msg.reply_id,unban_by_reply, false)
      get_message(msg.reply_id, Unban_reply, {msg=msg})			
      local user_id = matches[2]
      local chat_id = msg.to.id
      local targetuser = matches[2]
      elseif string.match(matches[2], '^%d+$') then
        	local user_id = matches[2]
        	local hash =  'banned:'..chat_id
        	redis:srem(hash, user_id)
        	local print_name = user_print_name(msg.from):gsub("‮", "")
		local name = print_name:gsub("_", "")
        	--savelog(msg.to.id, name.." ["..msg.from.id.."] unbaned user ".. matches[2])
        	return reply_msg(msg.id, "🚫 کاربر از محرومیت در آمد !", ok_cb, false)
      else
		local cbres_extra = {
			chat_id = msg.to.id,
			get_cmd = 'unban',
			from_id = msg.from.id,
			chat_type = msg.to.type,
			msg = msg,
			user = matches[2]
		}
		local username = string.gsub(matches[2], '@', '')
		resolve_username(username, kick_ban_res, cbres_extra)
	end	
 end

if matches[1]:lower() == 'kick' or matches[1] == 'اخراج' then
    if type(msg.reply_id) ~= "nil" and is_momod(msg) then			
      --if is_admin1(msg) then
        --msgr = get_message(msg.reply_id,Kick_by_reply_admins, false)
      --else
        --msgr = get_message(msg.reply_id, Kick_reply, false)
         get_message(msg.reply_id, Kick_reply, {msg = msg})			
      --end
	elseif string.match(matches[2], '^%d+$') then
		if is_momod2(tonumber(matches[2]), msg.from.id) or is_admin2(tonumber(matches[2])) then
			return reply_msg(msg.id, "⛔️ شما نمی توانید مدیران را اخراج کنید !", ok_cb, false)
		end
		if tonumber(matches[2]) == tonumber(msg.from.id) then
			return reply_msg(msg.id, "⛔️ شما نمی توانید خودتان را اخراج کنید !", ok_cb, false)
		end
    local user_id = matches[2]
    local chat_id = msg.to.id
		local print_name = user_print_name(msg.from):gsub("‮", "")
		local name = print_name:gsub("_", "")
		--savelog(msg.to.id, name.." ["..msg.from.id.."] kicked user ".. matches[2])
		kick_user(user_id, chat_id)
                reply_msg(msg.id, "❌ کاربر اخراج شد !", ok_cb, false)			
	else
		local cbres_extra = {
			chat_id = msg.to.id,
			get_cmd = 'kick',
			from_id = msg.from.id,
			chat_type = msg.to.type,
			msg = msg,
			user = matches[2]
		}
		local username = string.gsub(matches[2], '@', '')
		resolve_username(username, kick_ban_res, cbres_extra)
	end
end


	if not is_admin1(msg) and not is_support(support_id) then
		return
	end

 if matches[1]:lower() == 'banall' or matches[1] == 'سوپر بن' then -- Global ban
    if type(msg.reply_id) ~= "nil" and is_admin1(msg) then
       get_message(msg.reply_id, Banall_reply, false)
    local user_id = matches[2]
    local chat_id = msg.to.id
      local targetuser = matches[2]
      if string.match(targetuser, '^%d+$') then
		if is_momod2(tonumber(matches[2]), msg.from.id) or is_admin2(tonumber(matches[2])) then
			return reply_msg(msg.id, "⛔️ شما نمی توانید مدیران را سوپر بن کنید !", ok_cb, false)
		end
		if tonumber(matches[2]) == tonumber(msg.from.id) then
			return reply_msg(msg.id, "⛔️ شما نمی توانید خودتان را سوپر بن کنید !", ok_cb, false)
		end
        	banall_user(targetuser)
       		return reply_msg(msg.id, "❌ کاربر سوپر بن شد !", ok_cb, false)
     else
	local cbres_extra = {
		chat_id = msg.to.id,
		get_cmd = 'banall',
		from_id = msg.from.id,
		chat_type = msg.to.type,
		msg = msg,
		user = matches[2]
	}
		local username = string.gsub(matches[2], '@', '')
		resolve_username(username, kick_ban_res, cbres_extra)
      end
    end			
  end
  if matches[1]:lower() == 'unbanall' or matches[1] == 'حذف سوپر بن' then -- Global unban
    local user_id = matches[2]
    local chat_id = msg.to.id
      if string.match(matches[2], '^%d+$') then
        --if tonumber(matches[2]) == tonumber(our_id) then
        --  	return false
        --end
       		unbanall_user(user_id)
        	return reply_msg(msg.id, "❌ کاربر از سوپر بن در آمد !", ok_cb, false)
    else
		local cbres_extra = {
			chat_id = msg.to.id,
			get_cmd = 'unbanall',
			from_id = msg.from.id,
			chat_type = msg.to.type,
			msg = msg,
			user = matches[2]
		}
		local username = string.gsub(matches[2], '@', '')
		resolve_username(username, kick_ban_res, cbres_extra)
      end
  end
  if matches[1]:lower() == "gbanlist" then -- Global ban list
    return banall_list()
  end
end

return {
  patterns = {
    "^([Ss][Uu][Pp][Ee][Rr][Bb][Aa][Nn]) (.*)$",
    "^(سوپر بن) (.*)$",	
		
    "^([Ss][Uu][Pp][Ee][Rr][Bb][Aa][Nn])$",
    "^(سوپر بن)$",
		
    "^([Bb]anlist) (.*)$",
    "^([Bb]anlist)$",
		
    "^([Gg]banlist)$",
		
    --"^([Kk]ickme)",
    "^([Kk][Ii][Cc][Kk])$",
    "^(اخراج)$",
		
    "^([Bb][Aa][Nn])$",
    "^(محروم)$",
		
    "^([Bb][Aa][Nn]) (.*)$",
    "^(محروم) (.*)$",
		
    "^([Uu][Nn][Bb][Aa][Nn]) (.*)$",
    "^(حذف محروم) (.*)$",
		
    "^([Uu][Nn][Ss][Uu][Pp][Ee][Rr][Bb][Aa][Nn]) (.*)$",
    "^(حذف سوپر بن) (.*)$",
		
    "^([Uu][Nn][Ss][Uu][Pp][Ee][Rr][Bb][Aa][Nn])$",
    "^(حذف سوپر بن)$",
		
    "^([Kk][Ii][Cc][Kk]) (.*)$",
    "^(اخراج) (.*)$",
		
    "^([Uu][Nn][Bb][Aa][Nn])$",
    "^(حذف محروم)$",
		
    --"^([Ii]d)$",
    --"^!!tgservice (.+)$"
    "^!!tgservice (chat_add_user)$",	
    "^!!tgservice (chat_add_user_link)$",				
  },
  run = run,
  pre_process = pre_process
}
