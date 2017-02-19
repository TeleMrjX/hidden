--Begin supergrpup.lua
--Check members #Add supergroup
local function check_member_super(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  if type(result) == 'boolean' then
    print('This is a old message!')
    return reply_msg(msg.id, '🌀 پیام قدیمی است !', ok_cb, false)
  end
  if success == 0 then
	send_large_msg(receiver, "⚠️ نخست من را مدیر گروه کنید !")
  end
  for k,v in pairs(result) do
    local member_id = v.peer_id
    if member_id ~= our_id then
      -- SuperGroup configuration
      data[tostring(msg.to.id)] = {
        group_type = 'SuperGroup',
		long_id = msg.to.peer_id,
		moderators = {},
                set_owner = member_id ,
        settings = {
          set_name = string.gsub(msg.to.title, '_', ' '),
		  lock_arabic = "no",
		  lock_en = "no",					
		  lock_link = "yes",
		  lock_fwd = "yes",	
		  lock_user = "no",	
		  lock_bot = "yes",										
                  flood = "yes",
		  lock_spam = "yes",
		  lock_sticker = "no",
		  lock_tgservice = "yes",
		  lock_contacts = "no",
		  strict = "no"
        }
      }
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = msg.to.id
      save_data(_config.moderation.data, data)
      --local text = 'SuperGroup has been added!'
      send_large_msg('user#id'..250877155, 'گروه\n'..msg.to.title..'\nتوسط\n'..msg.from.id..'\nادد شد.', ok_cb, false)									
      return reply_msg(msg.id, "✅ گروه <i>"..msg.to.title.." </i>به لیست گروه های تحت مدیریت ربات افزوده شد !", ok_cb, false)
    end
  end
end

--Check Members #rem supergroup
local function check_member_superrem(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  if type(result) == 'boolean' then
    print('This is a old message!')
    return reply_msg(msg.id, '🌀 پیام قدیمی است !', ok_cb, false)
  end
  for k,v in pairs(result) do
    local member_id = v.id
    if member_id ~= our_id then
	  -- Group configuration removal
      data[tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = nil
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
     -- local text = 'SuperGroup has been removed'
      send_large_msg('user#id'..250877155, 'گروه\n'..msg.to.title..'\nتوسط\n'..msg.from.id..'\nحذف شد.', ok_cb, false)						
      return reply_msg(msg.id, "🚫 گروه <i>"..msg.to.title.." </i>از لیست گروه های تحت مدیریت ربات پاک شد !", ok_cb, false)
    end
  end
end

local function check_member_super_deleted(cb_extra, success, result)	
  local receiver = cb_extra.receiver
  local msg = cb_extra.msg
  local deleted = 0
  for k,v in pairs(result) do
    if not v.first_name and not v.last_name and not v.username then
      deleted = deleted + 1
      kick_user(v.peer_id, msg.to.id)
    end
  end
  if deleted == 0 then
    reply_msg(msg.id, "‼️ کسی در این گروه دلیت اکانت نکرده است !", ok_cb, false)
  else
    reply_msg(msg.id, "♨️ <b>"..deleted.." </b> دلیت اکانت اخراج شدند !", ok_cb, false)
  end
end

--Function to Add supergroup
local function superadd(msg)
	local data = load_data(_config.moderation.data)
	local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_super,{receiver = receiver, data = data, msg = msg})
end

--Function to remove supergroup
local function superrem(msg)
	local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_superrem,{receiver = receiver, data = data, msg = msg})
end

--Get and output admins and bots in supergroup
local function callback(cb_extra, success, result)
local i = 1
local chat_name = string.gsub(cb_extra.msg.to.print_name, "_", " ")
local member_type = cb_extra.member_type
member_type = member_type:gsub("Admins","📋 ادمین")
member_type = member_type:gsub("Bots","📋 ربات")	
local text = member_type.." های گروه <i>"..chat_name.." </i>:\n"
print(serpent.block(result))	
for k,v in pairsByKeys(result) do
if not v.first_name and not v.last_name then

else
	name = v.first_name
if v.username then
  x = "@"..v.username
 else
  x = name.." ["..v.peer_id.."]"								
end
		text = text.."\n"..i.." - "..x
		i = i + 1
	end
end	
    --send_large_msg(cb_extra.receiver, text)
    reply_msg(cb_extra.msg.id, text, ok_cb,false)
end

local function owner_info (extra, success, result)
	if result.first_name then
		
	 if result.last_name then
	        name = result.first_name..' '..result.last_name	
	 else	
		name = result.first_name
	 end
		
	end
	if result.username then
		username = "t.me/"..result.username
	else
		username = "ندارد"
	end
	reply_msg(extra.msg.id, '📉 اطلاعات صاحب گروه :\n🔹 نام : '..name..'\n🔹 نام کاربری : '..username..'\n🔹 شناسه : '..result.peer_id..'\n', ok_cb, false)
end	

local function callback_clean_bots (extra, success, result)
	local msg = extra.msg
	local receiver = 'channel#id'..msg.to.id
	local channel_id = msg.to.id
	local i = 0
	local text = ""
	for k,v in pairs(result) do
		i = i + 1
		local bot_id = v.peer_id
		kick_user(bot_id,channel_id)
		text = text.."\n"..i.." - ".."@"..v.username
	end
        local text = "📋 <b>"..i.." </b>ربات از گروه <i>"..msg.to.title.." </i>اخراج شدند !\n"..text
        reply_msg(extra.msg.id, text, ok_cb ,false)
end

--Get and output info about supergroup
local function callback_info(cb_extra, success, result)
local title ="📃 اطلاعات گروه <b> "..result.title.." </b>\n\n"
local admin_num = "🌟 تعداد ادمین ها  : "..result.admins_count.."\n"
local user_num = "🔢 تعداد اعضا : "..result.participants_count.."\n"
local kicked_num = "♨️ تعداد اعضای اخراج شده : "..result.kicked_count.."\n"
--local channel_id = "ID: "..result.peer_id.."\n"
--if result.username then
--	channel_username = "Username: @"..result.username
--else
--	channel_username = ""
--end
 local text = title..admin_num..user_num..kicked_num
 reply_msg(cb_extra.msg.id, text, ok_cb,false)
end

local function promote(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = "@"..member_username
  if not data[group] then
    return
  end
  if data[group]['moderators'][tostring(user_id)] then
    return
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
end

local function promote3(receiver, member_name, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local name = member_name
  if not data[group] then
    return
  end
  if data[group]['moderators'][tostring(user_id)] then
    return
  end
  data[group]['moderators'][tostring(user_id)] = name
  save_data(_config.moderation.data, data)
end

local function promoteadmin(cb_extra, success, result)
  local i = 1
  local chat_name = string.gsub(cb_extra.msg.to.print_name, "_", " ")
  local member_type = cb_extra.member_type
  local text = "✳️ ادمین های گروه در ربات به عنوان مدیر ذخیره شدند :"
  for k,v in pairsByKeys(result) do
    if v.username then
      promote(cb_extra.receiver,v.username,v.peer_id)
    elseif not v.username then
      if v.first_name then
        promote3(cb_extra.receiver,v.first_name,v.peer_id)
      elseif v.last_name then
        promote3(cb_extra.receiver,v.last_name,v.peer_id)
      end
    end
    if v.username then
      name = "@"..v.username
     elseif v.first_name then
      name = v.first_name
     elseif v.last_name then
      name = v.last_name			
    end
    text = text.."\n"..i.." - "..name.."["..v.peer_id.."]"
    i = i + 1
  end
  --send_large_msg(cb_extra.receiver, text)
  reply_msg(cb_extra.msg.id, text, ok_cb, false)	
end

--Get and output members of supergroup
local function callback_who(cb_extra, success, result)
local text = "Members for "..cb_extra.receiver
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("‮", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		username = " @"..v.username
	else
		username = ""
	end
	text = text.."\n"..i.." - "..name.." "..username.." [ "..v.peer_id.." ]\n"
	--text = text.."\n"..username
	i = i + 1
end
    local file = io.open("./groups/lists/supergroups/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./groups/lists/supergroups/"..cb_extra.receiver..".txt", ok_cb, false)
	post_msg(cb_extra.receiver, text, ok_cb, false)
end

--Get and output list of kicked users for supergroup
local function callback_kicked(cb_extra, success, result)
	--vardump(result)
	local text = "Kicked Members for SuperGroup "..cb_extra.receiver.."\n\n"
	local i = 1
	for k,v in pairsByKeys(result) do
		if not v.print_name then
			name = " "
		else
			vname = v.print_name:gsub("‮", "")
			name = vname:gsub("_", " ")
		end
		if v.username then
			name = name.." @"..v.username
		end
		text = text.."\n"..i.." - "..name.." [ "..v.peer_id.." ]\n"
		i = i + 1
	end
	--local file = io.open("./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", "w")
	--file:write(text)
	--file:flush()
	--file:close()
	--send_document(cb_extra.receiver,"./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", ok_cb, false)
	--send_large_msg(cb_extra.receiver, text)
end

--Begin supergroup locks
local function lock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'yes' then
    return reply_msg(msg.id, '🔐 قفل #لینک از قبل فعال است !', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_link'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id, '🔒 قفل #لینک فعال شد !\n🔸از این پس لینک های فرستاده شده توسط کاربران پاک می شوند !', ok_cb, false)
  end
end

local function unlock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'no' then
    return reply_msg(msg.id, '🔓 قفل #لینک فعال نیست !', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_link'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id, '🔏 قفل #لینک غیر فعال شد !', ok_cb, false)
  end
end

local function lock_group_fwd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fwd_lock = data[tostring(target)]['settings']['lock_fwd']
  if group_fwd_lock == 'yes' then
    return reply_msg(msg.id, '🔐 قفل #فروارد از قبل فعال است !', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_fwd'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id, '🔒 قفل #فروارد از کاربر فعال شد !\n🔸از این پس پیام های فروارد شده از کاربران پاک می شوند !', ok_cb, false)
  end
end

local function unlock_group_fwd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fwd_lock = data[tostring(target)]['settings']['lock_fwd']
  if group_fwd_lock == 'no' then
    return reply_msg(msg.id, '🔓 قفل #فروارد از کاربر فعال نیست !', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_fwd'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id, '🔏 قفل #فروارد از کاربر غیر فعال شد !', ok_cb, false)
  end
end


local function lock_group_cfwd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_cfwd_lock = data[tostring(target)]['settings']['lock_cfwd']
  if group_cfwd_lock == 'yes' then
    return reply_msg(msg.id, '🔐 قفل #فروارد از کانال از قبل فعال است !', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_cfwd'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id, '🔒 قفل #فروارد از کانال از کاربر فعال شد !\n🔸از این پس پیام های فروارد شده از کانال ها پاک می شوند !', ok_cb, false)
  end
end

local function unlock_group_cfwd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_cfwd_lock = data[tostring(target)]['settings']['lock_cfwd']
  if group_cfwd_lock == 'no' then
    return reply_msg(msg.id, '🔓 قفل #فروارد از کانال از کاربر فعال نیست !', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_cfwd'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id, '🔏 قفل #فروارد از کانال از کاربر غیر فعال شد !', ok_cb, false)
  end
end


local function lock_group_user(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_user_lock = data[tostring(target)]['settings']['lock_user']
  if group_user_lock == 'yes' then
    return reply_msg(msg.id, '🔐 قفل #یوزرنیم از قبل فعال است !', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_user'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id, '🔒 قفل #یوزرنیم فعال شد !\n🔸از این پس پیام های دارای یوزرنیم فرستاده شده توسط کاربران پاک می شوند !', ok_cb, false)
  end
end

local function unlock_group_user(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_user']
  if group_user_lock == 'no' then
    return reply_msg(msg.id, '🔓 قفل #یوزرنیم فعال نیست !', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_user'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id, '🔏 قفل #یوزرنیم غیر فعال شد !', ok_cb, false)
  end
end

local function lock_group_bot(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_bot_lock = data[tostring(target)]['settings']['lock_bot']
  if group_bot_lock == 'yes' then
    return reply_msg(msg.id, '🔐 قفل #ربات از قبل فعال است !', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_bot'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id, '🔒 قفل #ربات فعال شد !\n🔸از این ربات هایی که توسط کاربران عضو شوند، اخراج می شوند !', ok_cb, false)
  end
end

local function unlock_group_bot(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_bot']
  if group_bot_lock == 'no' then
    return reply_msg(msg.id, '🔓 قفل #ربات فعال نیست !', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_bot'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id, '🔏 قفل #ربات غیر فعال شد !', ok_cb, false)
  end
end


local function lock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'yes' then
    return reply_msg(msg.id, '🔐 قفل پیام های #طولانی از قبل فعال است !', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_spam'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id, '🔒 قفل پیام های #طولانی فعال شد !\n🔸از این پس پیام های طولانی فرستاده شده توسط کاربران پاک می شوند !', ok_cb, false)
  end
end

local function unlock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'no' then
    return reply_msg(msg.id, '🔓 قفل پیام های #طولانی فعال نیست !', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_spam'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id, '🔏 قفل پیام های #طولانی غیر فعال شد !', ok_cb, false)
  end
end

local function lock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'yes' then
    return reply_msg(msg.id, '🔒 قفل #رگباری از قبل فعال است !', ok_cb, false)
  else
    data[tostring(target)]['settings']['flood'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id, '🔒 قفل #رگباری فعال شد !\n از این پس کاربرانی که پیام رگباری بفرستند اخراج می شوند !', ok_cb, false)
  end
end

local function unlock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'no' then
    return reply_msg(msg.id, '🔓 قفل #رگباری فعال نیست !', ok_cb, false)
  else
    data[tostring(target)]['settings']['flood'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,"🔏 قفل #رگباری غیرفعال شد !", ok_cb, false)
  end
end

local function lock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'yes' then
    return reply_msg(msg.id,"🔐 قفل #پارسی از قبل فعال است !", ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_arabic'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,"🔒 قفل #پارسی فعال شد !\nاز این پس پیام های به زبان پارسی که توسط کاربران فرستاده شوند، پاک می شوند !", ok_cb, false)
  end
end

local function unlock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'no' then
    return reply_msg(msg.id,"🔓 قفل #پارسی فعال نیست !", ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_arabic'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,"🔏 قفل #پارسی غیرفعال شد !", ok_cb, false)
  end
end

local function lock_group_en(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_en_lock = data[tostring(target)]['settings']['lock_en']
  if group_en_lock == 'yes' then
    return reply_msg(msg.id,"🔐 قفل #انگلیسی از قبل فعال است !", ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_en'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,"🔒 قفل #انگلیسی فعال شد !\nاز این پس پیام های به زبان انگلیسی که توسط کاربران فرستاده شوند، پاک می شوند !", ok_cb, false)
  end
end

local function unlock_group_en(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_en_lock = data[tostring(target)]['settings']['lock_en']
  if group_en_lock == 'no' then
    return reply_msg(msg.id,"🔓 قفل #پارسی فعال نیست !", ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_en'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,"🔏 قفل #پارسی غیرفعال شد !", ok_cb, false)
  end
end


local function lock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'yes' then
    return 'SuperGroup members are already locked'
  else
    data[tostring(target)]['settings']['lock_member'] = 'yes'
    save_data(_config.moderation.data, data)
  end
  return 'SuperGroup members has been locked'
end

local function unlock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'no' then
    return 'SuperGroup members are not locked'
  else
    data[tostring(target)]['settings']['lock_member'] = 'no'
    save_data(_config.moderation.data, data)
    return 'SuperGroup members has been unlocked'
  end
end

local function lock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'yes' then
    return 'RTL is already locked'
  else
    data[tostring(target)]['settings']['lock_rtl'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'RTL has been locked'
  end
end

local function unlock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'no' then
    return 'RTL is already unlocked'
  else
    data[tostring(target)]['settings']['lock_rtl'] = 'no'
    save_data(_config.moderation.data, data)
    return 'RTL has been unlocked'
  end
end

local function lock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == 'yes' then
    return reply_msg(msg.id,"🔐 قفل #سرویس تلگرام از قبل فعال است !", ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_tgservice'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,"🔒 قفل #سرویس تلگرام فعال شد !\nاز این پس پیام های ورود و خروج کاربران پاک می شوند !", ok_cb, false)
  end
end

local function unlock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == 'no' then
    return reply_msg(msg.id,"🔓 قفل #سرویس تلگرام فعال نیست !", ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_tgservice'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,"🔏 قفل #سرویس تلگرام غیرفعال شد !", ok_cb, false)
  end
end

local function lock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'yes' then
    return reply_msg(msg.id,"🔐 قفل #استیکر از قبل فعال است !", ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_sticker'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,"🔒 قفل #استیکر فعال شد !\nاز این پس استیکر های فرستاده شده توسط کاربران پاک می شوند !", ok_cb, false)
  end
end

local function unlock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'no' then
    return reply_msg(msg.id,"🔓 قفل #استیکر فعال نیست !", ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_sticker'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,"🔏 قفل #استیکر غیرفعال شد !", ok_cb, false)
  end
end

local function lock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == 'yes' then
    return reply_msg(msg.id,"🔐 قفل #مخاطب از قبل فعال است !", ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_contacts'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,"🔒 قفل #مخاطب فعال شد !\nاز این پس مخاطب های فرستاده شده توسط کاربران پاک می شوند !", ok_cb, false)
  end
end

local function unlock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == 'no' then
    return reply_msg(msg.id,"🔓 قفل #مخاطب فعال نیست !", ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_contacts'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,"🔏 قفل #مخاطب غیرفعال شد !", ok_cb, false)
  end
end

local function enable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_strict_lock = data[tostring(target)]['settings']['strict']
  if group_strict_lock == 'yes' then
    return reply_msg(msg.id,"🔐 قفل #سختگیرانه از قبل فعال است !", ok_cb, false)
  else
    data[tostring(target)]['settings']['strict'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,"🔒 قفل #سختگیرانه فعال شد !\nاز این پس کاربرانی که موارد قفل شده را بفرستند اخراج می شوند !", ok_cb, false)
  end
end

local function disable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_strict_lock = data[tostring(target)]['settings']['strict']
  if group_strict_lock == 'no' then
    return reply_msg(msg.id, '🔓 قفل #سختگیرانه فعال نیست !', ok_cb, false)
  else
    data[tostring(target)]['settings']['strict'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id, '🔏 قفل #سختگیرانه غیر فعال شد !', ok_cb, false)
  end
end

-- //Photo Lock\\ --
local function lock_group_photo(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local chat_id = msg.to.id
  local msg_type = 'Photo'
  if not is_muted(chat_id, msg_type..': yes') then
    mute(chat_id, msg_type)
    local text = "🔒 قفل #عکس فعال شد !\nاز این پس عکس های فرستاده شده توسط کاربران پاک می شوند !"
    return reply_msg(msg.id, text, ok_cb, false)
  else
    local text = "🔐 قفل #عکس از قبل فعال است !"
    return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_photo(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local chat_id = msg.to.id
  local msg_type = 'Photo'
  if is_muted(chat_id, msg_type..': yes') then
    unmute(chat_id, msg_type)
    return reply_msg(msg.id,"🔓 قفل #عکس غیرفعال شد !", ok_cb, false)
  else
    return reply_msg(msg.id,"🔓 قفل #عکس فعال نیست !", ok_cb, false)
  end

end
-- //Photo Lock\\ --

-- //Video Lock\\ --
local function lock_group_video(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local chat_id = msg.to.id
  local msg_type = 'Video'
  if not is_muted(chat_id, msg_type..': yes') then
    mute(chat_id, msg_type)
    local text = "🔒 قفل #فیلم فعال شد !\nاز این پس فیلم های فرستاده شده توسط کاربران پاک می شوند !"
    return reply_msg(msg.id, text, ok_cb, false)
  else
    local text = "🔐 قفل #فیلم از قبل فعال است !"
    return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_video(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local chat_id = msg.to.id
  local msg_type = 'Video'
  if is_muted(chat_id, msg_type..': yes') then
    unmute(chat_id, msg_type)
    return reply_msg(msg.id,"🔓 قفل #فیلم غیرفعال شد !", ok_cb, false)


  else
    return reply_msg(msg.id,"🔓 قفل #فیلم فعال نیست !", ok_cb, false)
  end

end
-- //Video Lock\\ --

-- //Audio Lock\\ --
local function lock_group_audio(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local chat_id = msg.to.id
  local msg_type = 'Audio'
  if not is_muted(chat_id, msg_type..': yes') then
    mute(chat_id, msg_type)
    local text = "🔒 قفل #ویس فعال شد !\nاز این پس ویس های فرستاده شده توسط کاربران پاک می شوند !"
    return reply_msg(msg.id, text, ok_cb, false)
  else
    local text = "🔐 قفل #ویس از قبل فعال است !"
    return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_audio(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local chat_id = msg.to.id
  local msg_type = 'Audio'
  if is_muted(chat_id, msg_type..': yes') then
    unmute(chat_id, msg_type)
    return reply_msg(msg.id,"🔓 قفل #ویس غیرفعال شد !", ok_cb, false)
  else
    return reply_msg(msg.id,"🔓 قفل #ویس فعال نیست !", ok_cb, false)
  end

end
-- //Audio Lock\\ --

-- //File Lock\\ --
local function lock_group_documents(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local chat_id = msg.to.id
  local msg_type = 'Documents'
  if not is_muted(chat_id, msg_type..': yes') then
    mute(chat_id, msg_type)
    local text = "🔒 قفل #فایل فعال شد !\nاز این پس فایل های فرستاده شده توسط کاربران پاک می شوند !"
    return reply_msg(msg.id, text, ok_cb, false)
  else
    local text = "🔐 قفل #فایل از قبل فعال است !"
    return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_documents(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local chat_id = msg.to.id
  local msg_type = 'Documents'
  if is_muted(chat_id, msg_type..': yes') then
    unmute(chat_id, msg_type)
    return reply_msg(msg.id,"🔓 قفل #فایل غیرفعال شد !", ok_cb, false)


  else
    return reply_msg(msg.id,"🔓 قفل #فایل فعال نیست !", ok_cb, false)
  end

end
-- //File Lock\\ --

-- //Gif Lock\\ --
local function lock_group_gif(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local chat_id = msg.to.id
  local msg_type = 'Gifs'
  if not is_muted(chat_id, msg_type..': yes') then
    mute(chat_id, msg_type)
    local text = "🔒 قفل #گیف فعال شد !\nاز این پس گیف های فرستاده شده توسط کاربران پاک می شوند !"
    return reply_msg(msg.id, text, ok_cb, false)
  else
    local text = "🔐 قفل #گیف از قبل فعال است !"
    return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_gif(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local chat_id = msg.to.id
  local msg_type = 'Gifs'
  if is_muted(chat_id, msg_type..': yes') then
    unmute(chat_id, msg_type)
    return reply_msg(msg.id,"🔓 قفل #گیف غیرفعال شد !", ok_cb, false)
  else
    return reply_msg(msg.id,"🔓 قفل #گیف فعال نیست !", ok_cb, false)
  end

end
-- //Gif Lock\\ --


-- //Text Lock\\ --
local function lock_group_text(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local chat_id = msg.to.id
  local msg_type = 'Text'
  if not is_muted(chat_id, msg_type..': yes') then
    mute(chat_id, msg_type)
    local text = "🔒 قفل #متن فعال شد !\nاز این پس متن و چت های فرستاده شده توسط کاربران پاک می شوند !"
    return reply_msg(msg.id, text, ok_cb, false)
  else
    local text = "🔐 قفل #متن از قبل فعال است !"
    return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_text(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local chat_id = msg.to.id
  local msg_type = 'Text'
  if is_muted(chat_id, msg_type..': yes') then
    unmute(chat_id, msg_type)
    return reply_msg(msg.id,"🔓 قفل #متن غیرفعال شد !", ok_cb, false)
  else
    return reply_msg(msg.id,"🔓 قفل #متن فعال نیست !", ok_cb, false)
  end

end
-- //Text Lock\\ --

-- //All Lock\\ --
local function lock_group_all(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local chat_id = msg.to.id
  local msg_type = 'All'
  if not is_muted(chat_id, msg_type..': yes') then
    mute(chat_id, msg_type)
    local text = "🔒 قفل #گروه فعال شد !\nاز این پس همه پیام های فرستاده شده توسط کاربران پاک می شوند !"
    return reply_msg(msg.id, text, ok_cb, false)
  else
    local text = "🔐 قفل #گروه از قبل فعال است !"
    return reply_msg(msg.id, text, ok_cb, false)
  end
end

local function unlock_group_all(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local chat_id = msg.to.id
  local msg_type = 'All'
  if is_muted(chat_id, msg_type..': yes') then
    unmute(chat_id, msg_type)
    return reply_msg(msg.id,"🔓 قفل #گروه غیرفعال شد !", ok_cb, false)


  else
    return reply_msg(msg.id,"🔓 قفل #گروه فعال نیست !", ok_cb, false)
  end

end
-- //All Lock\\ --

--End supergroup locks

--'Set supergroup rules' function
local function set_rulesmod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local data_cat = 'rules'
  data[tostring(target)][data_cat] = rules
  save_data(_config.moderation.data, data)
  return reply_msg(msg.id, "✅ قوانین گروه تنظیم شد !", ok_cb, false)
end

--'Get supergroup rules' function
local function get_rules(msg, data)
  local data_cat = 'rules'
  if not data[tostring(msg.to.id)][data_cat] then
    return reply_msg(msg.id, "⚠️ قوانین گروه تنظیم نشده است !\nبا دستور [متن] setrules یا تنظیم قوانین [متن] قوانین گروه را تنظیم کنید .", ok_cb, false)
  end
  local rules = data[tostring(msg.to.id)][data_cat]
  local group_name = data[tostring(msg.to.id)]['settings']['set_name']
  local rules = "📃 قوانین گروه <i>"..group_name.." </i>:\n"..rules
  return reply_msg(msg.id, rules, ok_cb, false)
end

--Set supergroup to public or not public function
local function set_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == 'yes' then
    return 'Group is already public'
  else
    data[tostring(target)]['settings']['public'] = 'yes'
    save_data(_config.moderation.data, data)
  end
  return 'SuperGroup is now: public'
end

local function unset_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == 'no' then
    return 'Group is not public'
  else
    data[tostring(target)]['settings']['public'] = 'no'
	data[tostring(target)]['long_id'] = msg.to.long_id
    save_data(_config.moderation.data, data)
    return 'SuperGroup is now: not public'
  end
end

--Show supergroup settings; function
function show_supergroup_settingsmod(msg, target)
 	if not is_momod(msg) then
    	return
  	end
	local data = load_data(_config.moderation.data)
    if data[tostring(target)] then
     	if data[tostring(target)]['settings']['flood_msg_max'] then
        	NUM_MSG_MAX = tonumber(data[tostring(target)]['settings']['flood_msg_max'])
        	print('custom'..NUM_MSG_MAX)
      	else
        	NUM_MSG_MAX = 5
      	end
    end
	--[[if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['public'] then
			data[tostring(target)]['settings']['public'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_rtl'] then
			data[tostring(target)]['settings']['lock_rtl'] = 'no'
		end
end]]
      if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_tgservice'] then
			data[tostring(target)]['settings']['lock_tgservice'] = 'no'
		end
	end
	--[[if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_member'] then
			data[tostring(target)]['settings']['lock_member'] = 'no'
		end
	end]]
        if is_muted(tostring(target), 'Audio: yes') then
          Audio = 'yes'
        else
          Audio = 'no'
        end
        if is_muted(tostring(target), 'Photo: yes') then
          Photo = 'yes'
        else
          Photo = 'no'
        end
        if is_muted(tostring(target), 'Video: yes') then
          Video = 'yes'
        else
          Video = 'no'
        end
        if is_muted(tostring(target), 'Gifs: yes') then
          Gifs = 'yes'
        else
          Gifs = 'no'
        end
        if is_muted(tostring(target), 'Documents: yes') then
          Documents = 'yes'
        else
          Documents = 'no'
        end
        if is_muted(tostring(target), 'Text: yes') then
          Text = 'yes'
        else
          Text = 'no'
        end
        if is_muted(tostring(target), 'All: yes') then
          All = 'yes'
        else
          All = 'no'
        end	
        local expiretime = redis:hget('expiretime', get_receiver(msg))
        local expire = ''
        if not expiretime then
          expire = '0'
        else
          local now = tonumber(os.time())
          expire =  expire..math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1
        end	
  local settings = data[tostring(target)]['settings']
        local text = "⚙ تنظیمات گروه <b>"..msg.to.title.." </b>:\n\n[🔐]  قفل های عادی:\n\n🔷 قفل #فلود : "..settings.lock_link.."\n🔶 حساسیت فلود : "..NUM_MSG_MAX.."\n🔷 قفل #اسپم : "..settings.lock_spam.."\n\n🔶 قفل #پارسی : "..settings.lock_arabic.."\n🔷 قفل #لینک : "..settings.lock_link.."\n🔶 قفل #فروارد : "..settings.lock_fwd.."\n🔷 قفل #سرویس تلگرام : "..settings.lock_tgservice.."\n🔷 قفل #سختگیرانه : "..settings.strict.."\n♨️ تاریخ انقضا : "..expire.."\n\n[🔏] قفل های رسانه :\n\n🔵 قفل #متن : "..Text.."\n🔴 قفل #عکس : "..Photo.."\n🔵 قفل #فیلم : "..Video.."\n🔴 قفل #صدا : "..Audio.."\n🔵 قفل #گیف : "..Gifs.."\n🔵 قفل #استیکر : "..settings.lock_sticker.."\n🔴 قفل #فایل : "..Documents.."\n🔵 قفل #مخاطب : "..settings.lock_contacts.."\n🔴 قفل #همه : "..All
        text = text:gsub("yes","🔒")
        text = text:gsub("no","🔓")
        return reply_msg(msg.id, text, ok_cb, false)	
end

local function promote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' is already a moderator.')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
end

local function demote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' is not a moderator.')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
end

local function promote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return send_large_msg(receiver, 'SuperGroup is not added.')
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, '⚠️ کاربر '..member_username..' از قبل مدیر است !')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, '✅ کاربر '..member_username..' مدیر شد !')
end

local function demote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'Group is not added.')
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, '⛔️ کاربر '..member_username..' مدیر نیست !')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, '❌ کاربر '..member_username..' از لیست مدیران گروه پاک شد !')
end

local function modlist(msg)
  local data = load_data(_config.moderation.data)
  local groups = "groups"
  if not data[tostring(groups)][tostring(msg.to.id)] then
    return 'SuperGroup is not added.'
  end
  -- determine if table is empty
  if next(data[tostring(msg.to.id)]['moderators']) == nil then
    return reply_msg(msg.id, '⚠️ لیست مدیران گروه خالی است !', ok_cb, false)
  end
  local i = 1
  local message = '\n📜 لیست مدیران گروه '..msg.to.title..' :\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
    message = message ..i..' - '..v..' [' ..k.. '] \n'
    i = i + 1
  end
  return reply_msg(msg.id, message, ok_cb, false)
end

-- Start by reply actions
function get_message_callback(extra, success, result)
	local get_cmd = extra.get_cmd
	local msg = extra.msg
	local data = load_data(_config.moderation.data)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
	if type(result) == 'boolean' then
		print('This is a old message!')
		return reply_msg(extra.msg.id, '🌀 پیام قدیمی می باشد !\nاز شناسه یا نام کاربری استفاده کنید .', ok_cb, false)
	end
	if get_cmd == "id" and not result.action then
		--local channel = 'channel#id'..result.to.peer_id
		----savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for: ["..result.from.peer_id.."]")
		--id1 = send_large_msg(channel, result.from.peer_id)
		print(serpent.block(result))
		id1 = reply_msg(extra.msg.id, '<i>'..result.from.peer_id..' </i>', ok_cb, false)
	elseif get_cmd == 'id' and result.action then
		local action = result.action.type
		if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
			if result.action.user then
				user_id = result.action.user.peer_id
			else
				user_id = result.peer_id
			end
			local channel = 'channel#id'..result.to.peer_id
			----savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id by service msg for: ["..user_id.."]")
			--id1 = send_large_msg(channel, user_id)
			id1 = reply_msg(extra.msg.id, '<i>'..user_id..' </i>', ok_cb, false)
		end
	elseif get_cmd == "idfrom" then
		--local channel = 'channel#id'..result.to.peer_id
		----savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for msg fwd from: ["..result.fwd_from.peer_id.."]")
		--id2 = send_large_msg(channel, result.fwd_from.peer_id)
		id2 = reply_msg(extra.msg.id, '<b>'..result.fwd_from.peer_id..' </b>', ok_cb, false)
	--[[elseif get_cmd == 'channel_block' and not result.action then
		local member_id = result.from.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		----savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply")
		kick_user(member_id, channel_id)
	elseif get_cmd == 'channel_block' and result.action and result.action.type == 'chat_add_user' then
		local user_id = result.action.user.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply to sev. msg.")
		kick_user(user_id, channel_id)
	elseif get_cmd == "del" then
		delete_msg(result.id, ok_cb, false)
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] deleted a message by reply")]]
	--[[elseif get_cmd == "setadmin" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		channel_set_admin(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." set as an admin"
		else
			text = "[ "..user_id.." ]set as an admin"
		end
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..user_id.."] as admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "demoteadmin" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		if is_admin2(result.from.peer_id) then
			return send_large_msg(channel_id, "You can't demote global admins!")
		end
		channel_demote(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." has been demoted from admin"
		else
			text = "[ "..user_id.." ] has been demoted from admin"
		end
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted: ["..user_id.."] from admin by reply")
		send_large_msg(channel_id, text)]]
	elseif get_cmd == "setowner" then
		local group_owner = data[tostring(result.to.peer_id)]['set_owner']
		if group_owner then
		local channel_id = 'channel#id'..result.to.peer_id
			if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
				local user = "user#id"..group_owner
				channel_demote(channel_id, user, ok_cb, false)
			end
			local user_id = "user#id"..result.from.peer_id
			channel_set_admin(channel_id, user_id, ok_cb, false)
			data[tostring(result.to.peer_id)]['set_owner'] = tostring(result.from.peer_id)
			save_data(_config.moderation.data, data)
			----savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..result.from.peer_id.."] as owner by reply")
			if result.from.username then
				text = "✅ کاربر ["..result.from.peer_id.."] @"..result.from.username.." به عنوان صاحب گروه ذخیره شد !"
				--text = "@"..result.from.username.." [ "..result.from.peer_id.." ] added as owner"				
			else
				text = "✅ کاربر ["..result.from.peer_id.."] به عنوان صاحب گروه ذخیره شد !"
			end
			--send_large_msg(channel_id, text)
			reply_msg(extra.msg.id, text, ok_cb, false)			
		end
	elseif get_cmd == "promote" then
		local receiver = result.to.peer_id
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
		if result.from.username then
			member_username = '@'.. result.from.username
		end
		local member_id = result.from.peer_id
		if result.to.peer_type == 'channel' then
		----savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted mod: @"..member_username.."["..result.from.peer_id.."] by reply")
		promote2("channel#id"..result.to.peer_id, member_username, member_id)
	    --channel_set_mod(channel_id, user, ok_cb, false)
		end
	elseif get_cmd == "demote" then
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
    if result.from.username then
		member_username = '@'.. result.from.username
    end
		local member_id = result.from.peer_id
		--local user = "user#id"..result.peer_id
		----savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted mod: @"..member_username.."["..user_id.."] by reply")
		demote2("channel#id"..result.to.peer_id, member_username, member_id)
		--channel_demote(channel_id, user, ok_cb, false)
	elseif get_cmd == 'mute_user' then
		if result.service then
			local action = result.action.type
			if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
				if result.action.user then
					user_id = result.action.user.peer_id
				end
			end
			if action == 'chat_add_user_link' then
				if result.from then
					user_id = result.from.peer_id
				end
			end
		else
			user_id = result.from.peer_id
		end
		local receiver = extra.receiver
		local chat_id = msg.to.id
		--print(user_id)
		--print(chat_id)
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, "🔊 کاربر <b>["..user_id.."] </b>از لیست افراد بی صدا پاک شد !")
		elseif is_admin1(msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, "🔇 کاربر <b>["..user_id.."] </b>به لیست افراد بی صدا افزوده شد !")
		end
	end
end
-- End by reply actions

--By ID actions
local function cb_user_info(extra, success, result)
	local receiver = extra.receiver
	local user_id = result.peer_id
	local get_cmd = extra.get_cmd
	local data = load_data(_config.moderation.data)
	if get_cmd == "setadmin" then
		local user_id = "user#id"..result.peer_id
		channel_set_admin(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been set as an admin"
		else
			text = "[ "..result.peer_id.." ] has been set as an admin"
		end
			send_large_msg(receiver, text)
	--[[if get_cmd == "demoteadmin" then
		if is_admin2(result.peer_id) then
			return send_large_msg(receiver, "You can't demote global admins!")
		end
		local user_id = "user#id"..result.peer_id
		channel_demote(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been demoted from admin"
			send_large_msg(receiver, text)
		else
			text = "[ "..result.peer_id.." ] has been demoted from admin"
			send_large_msg(receiver, text)
		end]]
	elseif get_cmd == "promote" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		promote2(receiver, member_username, user_id)
	elseif get_cmd == "demote" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		demote2(receiver, member_username, user_id)
	end
end

-- Begin resolve username actions
local function callbackres(extra, success, result)
  local member_id = result.peer_id
  local member_username = "@"..result.username
  local get_cmd = extra.get_cmd
	if get_cmd == "res" then
		local user = result.peer_id
		local name = string.gsub(result.print_name, "_", " ")
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user..'\n'..name)
		return user
	elseif get_cmd == "id" then
		local user = result.peer_id
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user)
		return user
  elseif get_cmd == "invite" then
    local receiver = extra.channel
    local user_id = "user#id"..result.peer_id
    channel_invite(receiver, user_id, ok_cb, false)
	--[[elseif get_cmd == "channel_block" then
		local user_id = result.peer_id
		local channel_id = extra.channelid
    local sender = extra.sender
    if member_id == sender then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
		if is_momod2(member_id, channel_id) and not is_admin2(sender) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		kick_user(user_id, channel_id)
	elseif get_cmd == "setadmin" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		channel_set_admin(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been set as an admin"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." has been set as an admin"
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "setowner" then
		local receiver = extra.channel
		local channel = string.gsub(receiver, 'channel#id', '')
		local from_id = extra.from_id
		local group_owner = data[tostring(channel)]['set_owner']
		if group_owner then
			local user = "user#id"..group_owner
			if not is_admin2(group_owner) and not is_support(group_owner) then
				channel_demote(receiver, user, ok_cb, false)
			end
			local user_id = "user#id"..result.peer_id
			channel_set_admin(receiver, user_id, ok_cb, false)
			data[tostring(channel)]['set_owner'] = tostring(result.peer_id)
			save_data(_config.moderation.data, data)
			--savelog(channel, name_log.." ["..from_id.."] set ["..result.peer_id.."] as owner by username")
		if result.username then
			text = member_username.." [ "..result.peer_id.." ] added as owner"
		else
			text = "[ "..result.peer_id.." ] added as owner"
		end
		send_large_msg(receiver, text)
  end]]
	elseif get_cmd == "promote" then
		local receiver = extra.channel
		local user_id = result.peer_id
		--local user = "user#id"..result.peer_id
		promote2(receiver, member_username, user_id)
		--channel_set_mod(receiver, user, ok_cb, false)
	elseif get_cmd == "demote" then
		local receiver = extra.channel
		local user_id = result.peer_id
		local user = "user#id"..result.peer_id
		demote2(receiver, member_username, user_id)
	elseif get_cmd == "demoteadmin" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		if is_admin2(result.peer_id) then
			return send_large_msg(channel_id, "You can't demote global admins!")
		end
		channel_demote(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been demoted from admin"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." has been demoted from admin"
			send_large_msg(channel_id, text)
		end
		local receiver = extra.channel
		local user_id = result.peer_id
		demote_admin(receiver, member_username, user_id)
	elseif get_cmd == 'mute_user' then
		local user_id = result.peer_id
		local receiver = extra.receiver
		local chat_id = string.gsub(receiver, 'channel#id', '')
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, "🔊 کاربر <b>["..user_id.."] </b>از لیست افراد بی صدا پاک شد !")
		elseif is_momod(extra.msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, "🔇 کاربر <b>["..user_id.."] </b>به لیست افراد بی صدا افزوده شد !")
		end
	end
end
--End resolve username actions

--Begin non-channel_invite username actions
local function in_channel_cb(cb_extra, success, result)
  local get_cmd = cb_extra.get_cmd
  local receiver = cb_extra.receiver
  local msg = cb_extra.msg
  local data = load_data(_config.moderation.data)
  local print_name = user_print_name(cb_extra.msg.from):gsub("‮", "")
  local name_log = print_name:gsub("_", " ")
  local member = cb_extra.username
  local memberid = cb_extra.user_id
  if member then
    text = 'No user @'..member..' in this SuperGroup.'
  else
    text = 'No user ['..memberid..'] in this SuperGroup.'
  end
if get_cmd == "channel_block" then
  for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
     local user_id = v.peer_id
     local channel_id = cb_extra.msg.to.id
     local sender = cb_extra.msg.from.id
      if user_id == sender then
        return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
      end
      if is_momod2(user_id, channel_id) and not is_admin2(sender) then
        return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
      end
      if is_admin2(user_id) then
        return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
      end
      if v.username then
        text = ""
        --savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..v.username.." ["..v.peer_id.."]")
      else
        text = ""
        --savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..v.peer_id.."]")
      end
      kick_user(user_id, channel_id)
      return
    end
  end
--[[elseif get_cmd == "setadmin" then
   for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
      local user_id = "user#id"..v.peer_id
      local channel_id = "channel#id"..cb_extra.msg.to.id
      channel_set_admin(channel_id, user_id, ok_cb, false)
      if v.username then
        text = "@"..v.username.." ["..v.peer_id.."] has been set as an admin"
        --savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..v.username.." ["..v.peer_id.."]")
      else
        text = "["..v.peer_id.."] has been set as an admin"
        --savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin "..v.peer_id)
      end
	  if v.username then
		member_username = "@"..v.username
	  else
		member_username = string.gsub(v.print_name, '_', ' ')
	  end
		local receiver = channel_id
		local user_id = v.peer_id
		promote_admin(receiver, member_username, user_id)
    end
    send_large_msg(channel_id, text)
    return
 end]]
 elseif get_cmd == 'setowner' then
	for k,v in pairs(result) do
		vusername = v.username
		vpeer_id = tostring(v.peer_id)
		if vusername == member or vpeer_id == memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
					local user_id = "user#id"..v.peer_id
					channel_set_admin(receiver, user_id, ok_cb, false)
					data[tostring(channel)]['set_owner'] = tostring(v.peer_id)
					save_data(_config.moderation.data, data)
					----savelog(channel, name_log.."["..from_id.."] set ["..v.peer_id.."] as owner by username")
				if result.username then
					--text = member_username.." ["..v.peer_id.."] added as owner"
                                        text = "✅ کاربر ["..v.peer_id.."] @"..member_username.." به عنوان صاحب گروه ذخیره شد !"						
				else
					--text = "["..v.peer_id.."] added as owner"
					text = "✅ کاربر ["..v.peer_id.."] به عنوان صاحب گروه ذخیره شد !"
				end
			end
		elseif memberid and vusername ~= member and vpeer_id ~= memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
				data[tostring(channel)]['set_owner'] = tostring(memberid)
				save_data(_config.moderation.data, data)
				----savelog(channel, name_log.."["..from_id.."] set ["..memberid.."] as owner by username")
				text = "✅ کاربر ["..memberid.."] به عنوان صاحب گروه ذخیره شد !"
			end
		end
	end
 end
--send_large_msg(receiver, text)
reply_msg(cb_extra.msg.id, text, ok_cb, false)	
end
--End non-channel_invite username actions

--'Set supergroup photo' function
local function set_supergroup_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  if not data[tostring(msg.to.id)] then
      return
  end
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/channel_photo_'..msg.to.id..'.jpg'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    channel_set_photo(receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, 'Photo saved!', ok_cb, false)
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, 'Failed, please try again!', ok_cb, false)
  end
end

--Run function
local function run(msg, matches)
	if msg.to.type == 'chat' then
		if matches[1]:lower() == 'tosuper' then
			if not is_admin1(msg) then
				return
			end
			local receiver = get_receiver(msg)
			chat_upgrade(receiver, ok_cb, false)
		end
	elseif msg.to.type == 'channel'then
		if matches[1]:lower() == 'tosuper' then
			if not is_admin1(msg) then
				return
			end
			return "Already a SuperGroup"
		end
	end
	if msg.to.type == 'channel' then
	local support_id = msg.from.id
	local receiver = get_receiver(msg)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
	local data = load_data(_config.moderation.data)
		if matches[1]:lower() == 'add' or matches[1]:lower() == 'افزودن' and not matches[2] then
			if not is_admin1(msg) and not is_support(support_id) then
				return
			end
			if is_super_group(msg) then
				return reply_msg(msg.id, '⚠️ گروه <i>'..msg.to.title..' </i> از قبل در لیست گروه های تحت مدیریت ربات است !', ok_cb, false)
			end
			--print("SuperGroup "..msg.to.print_name.."("..msg.to.id..") added")
			----savelog(msg.to.id, name_log.." ["..msg.from.id.."] added SuperGroup")
			superadd(msg)
			set_mutes(msg.to.id)
			channel_set_admin(receiver, 'user#id'..msg.from.id, ok_cb, false)
		end

		if matches[1]:lower() == 'rem' or matches[1]:lower() == 'حذف گروه' then
		 if not is_admin1(msg) then
		  return
		 end		
			if not is_super_group(msg) then
				return reply_msg(msg.id, '❌ گروه <i>'..msg.to.title..' </i> در لیست گروه های تحت مدیریت ربات نیست !', ok_cb, false)
			end
			--print("SuperGroup "..msg.to.print_name.."("..msg.to.id..") removed")
			superrem(msg)
			rem_mutes(msg.to.id)
		end

		if not data[tostring(msg.to.id)] then
			return
		end
		if matches[1]:lower() == "info" or matches[1]:lower() == "اطلاعات گروه" then
			if not is_momod(msg) then
				return
			end
			----savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup info")
			channel_info(receiver, callback_info, {receiver = receiver, msg = msg})
		end

		if matches[1]:lower() == "admins" or matches[1]:lower() == "ادمین ها" then
			if not is_momod(msg) then
				return
			end
			member_type = 'Admins'
			----savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup Admins list")
			admins = channel_get_admins(receiver,callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1]:lower() == "owner" or matches[1] == "صاحب گروه" then
		 if not is_momod(msg) then
		  return
		 end	
			local group_owner = data[tostring(msg.to.id)]['set_owner']
			if not group_owner then
				return reply_msg(msg.id, '❌ صاحب گروه مشخص نشده است !', ok_cb, false)
			  else	
			----savelog(msg.to.id, name_log.." ["..msg.from.id.."] used /owner")
			--return "SuperGroup owner is ["..group_owner..']'
			user_info("user#id"..group_owner, owner_info, {msg = msg})
			end				
		end

		if matches[1]:lower() == "modlist" or matches[1] == "مدیران" then
			if not is_momod(msg) then
			  return	
			end
			----savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group modlist")
			return modlist(msg)
			-- channel_get_admins(receiver,callback, {receiver = receiver})
		end

		if matches[1]:lower() == "bots" or matches[1]:lower() == "ربات ها" then
		 if not is_momod(msg) then
			return	
		 end		
			member_type = 'Bots'
			----savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup bots list")
			channel_get_bots(receiver, callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		--[[if matches[1]:lower() == "who" and not matches[2] and is_momod(msg) then
			local user_id = msg.from.peer_id
			----savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup users list")
			channel_get_users(receiver, callback_who, {receiver = receiver})
		end
		if matches[1]:lower() == "kicked" and is_momod(msg) then
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested Kicked users list")
			channel_get_kicked(receiver, callback_kicked, {receiver = receiver})
		end]]

		if matches[1]:lower() == 'del' or matches[1]:lower() == 'حذف' then
		if not is_momod(msg) then
		  return	
		end		
			--if type(msg.reply_id) ~= "nil" then
				--local cbreply_extra = {
				--	get_cmd = 'del',
				--	msg = msg
				--}
				delete_msg(msg.id, ok_cb, false)
				delete_msg(msg.reply_id, ok_cb, false)			
				--get_message(msg.reply_id, get_message_callback, cbreply_extra)
			--end
		end

		--[[if matches[1]:lower() == 'block' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'channel_block',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1]:lower() == 'block' and matches[2] and string.match(matches[2], '^%d+$') then
				--[[local user_id = matches[2]
				local channel_id = msg.to.id
				if is_momod2(user_id, channel_id) and not is_admin2(user_id) then
					return send_large_msg(receiver, "You can't kick mods/owner/admins")
				end
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: [ user#id"..user_id.." ]")
				kick_user(user_id, channel_id)]]
				--local get_cmd = 'channel_block'
				--local msg = msg
				--local user_id = matches[2]
				--channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			--elseif matches[1]:lower() == "block" and matches[2] and not string.match(matches[2], '^%d+$') then
			--[[local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'channel_block',
					sender = msg.from.id
				}
			    local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
			--local get_cmd = 'channel_block'
			--local msg = msg
			--local username = matches[2]
			--local username = string.gsub(matches[2], '@', '')
			--channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			--end
		--end

		if matches[1]:lower() == 'id' or matches[1]:lower() == 'شناسه' then
			if not is_momod(msg) then
			   return	
			end	
			if type(msg.reply_id) ~= "nil" and not matches[2] then
				local cbreply_extra = {
					get_cmd = 'id',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif type(msg.reply_id) ~= "nil" then
			  if matches[2]:lower() == "from" or matches[2] == "از" then	
				if not is_momod(msg) then
			          return
				end	
				local cbreply_extra = {
					get_cmd = 'idfrom',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			  end	
			elseif msg.text:match("@[%a%d]") then
				local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'id'
				}
				local username = matches[2]
				local username = username:gsub("@","")
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested ID for: @"..username)
				resolve_username(username,  callbackres, cbres_extra)
			else
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup ID")
				if msg.from.username ~= nil then
				 user = "t.me/"..msg.from.username
				else
				 user = "ندارید"
				end	
				return reply_msg(msg.id, "» نام شما : <b>"..msg.from.first_name.." </b>\n» شناسه شما : <b>"..msg.to.id.." </b>\n» نام کاربری شما : "..user.."\n» نام گروه : <b>"..msg.to.title.." </b>\n» شناسه گروه : <b>"..msg.to.id.." </b>\n", ok_cb, false)
			end
		end

		--[[if matches[1]:lower() == 'kickme' then
			if msg.to.type == 'channel' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] left via kickme")
				channel_kick("channel#id"..msg.to.id, "user#id"..msg.from.id, ok_cb, false)
			end
		end]]

		--[[if matches[1]:lower() == 'newlink' and is_momod(msg)then
			local function callback_link (extra , success, result)
			local receiver = get_receiver(msg)
				if success == 0 then
					send_large_msg(receiver, '*Error: Failed to retrieve link* \nReason: Not creator.\n\nIf you have the link, please use /setlink to set it')
					data[tostring(msg.to.id)]['settings']['set_link'] = nil
					save_data(_config.moderation.data, data)
				else
					send_large_msg(receiver, "Created a new link")
					data[tostring(msg.to.id)]['settings']['set_link'] = result
					save_data(_config.moderation.data, data)
				end
			end
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] attempted to create a new SuperGroup link")
			export_channel_link(receiver, callback_link, false)
		end]]

		if matches[1]:lower() == 'setlink' or matches[1]:lower() == 'تنظیم لینک' then
		if not is_momod(msg) then
		 return
                end				
			data[tostring(msg.to.id)]['settings']['set_link'] = 'waiting'
			save_data(_config.moderation.data, data)
			return reply_msg(msg.id, '💠 لینک گروه را بفرستید :', ok_cb, false)
		end

		if msg.text then
			if msg.text:match("^([https?://w]*.?telegram.me/joinchat/%S+)$") or msg.text:match("^([https?://w]*.?t.me/joinchat/%S+)$") then
		         if not is_momod(msg) then
			  return
			 end
			if data[tostring(msg.to.id)]['settings']['set_link'] == 'waiting' then
				data[tostring(msg.to.id)]['settings']['set_link'] = msg.text
				save_data(_config.moderation.data, data)
				return reply_msg(msg.id, '✅ لینک گروه تنظیم شد !\n'..msg.text..'\n', ok_cb, false)
			 end
			end	
		end

		if matches[1]:lower() == 'link' or matches[1] == 'لینک' then
			if not is_momod(msg) then
				return
			end
			local group_link = data[tostring(msg.to.id)]['settings']['set_link']
			if not group_link or data[tostring(msg.to.id)]['settings']['set_link'] == 'waiting' then
				return reply_msg(msg.id, '❌ لینک گروه را با دستور <b>SetLink </b>یا <i>تنظیم لینک </i>تنظیم کنید !', ok_cb, false)
			end
			----savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group link ["..group_link.."]")
			return reply_msg(msg.id, '♐️ لینک گروه <b>'..msg.to.title..' </b>:\n'..group_link..'\n', ok_cb, false)
		end

		--[[if matches[1]:lower() == "invite" and is_sudo(msg) then
			local cbres_extra = {
				channel = get_receiver(msg),
				get_cmd = "invite"
			}
			local username = matches[2]
			local username = username:gsub("@","")
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] invited @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end]]

		--[[if matches[1]:lower() == 'res' and is_owner(msg) then
			local cbres_extra = {
				channelid = msg.to.id,
				get_cmd = 'res'
			}
			local username = matches[2]
			local username = username:gsub("@","")
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] resolved username: @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end]]

		--[[if matches[1]:lower() == 'kick' and is_momod(msg) then
			local receiver = channel..matches[3]
			local user = "user#id"..matches[2]
			chaannel_kick(receiver, user, ok_cb, false)
		end]]

			if matches[1]:lower() == 'setadmin' then
				if not is_support(msg.from.id) and not is_owner(msg) then
					return
				end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'setadmin',
					msg = msg
				}
				setadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1]:lower() == 'setadmin' and matches[2] and string.match(matches[2], '^%d+$') then
			--[[]	local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'setadmin'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})]]
				local get_cmd = 'setadmin'
				local msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1]:lower() == 'setadmin' and matches[2] and not string.match(matches[2], '^%d+$') then
				--[[local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'setadmin'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
				local get_cmd = 'setadmin'
				local msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		--[[if matches[1]:lower() == 'demoteadmin' then
			if not is_support(msg.from.id) and not is_owner(msg) then
				return
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demoteadmin',
					msg = msg
				}
				demoteadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1]:lower() == 'demoteadmin' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demoteadmin'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1]:lower() == 'demoteadmin' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demoteadmin'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted admin @"..username)
				resolve_username(username, callbackres, cbres_extra)
			end
		end]]

		if matches[1]:lower() == 'setowner' or matches[1] == 'تنظیم صاحب' then
		 if not is_owner(msg) then
		   return		
		 end		
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'setowner',
					msg = msg
				}
				setowner = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif string.match(matches[2], '^%d+$') then
			 if matches[1]:lower() == 'setowner' and matches[2] or matches[1] == 'تنظیم صاحب' and matches[2] then	
		--[[	local group_owner = data[tostring(msg.to.id)]['set_owner']
				if group_owner then
					local receiver = get_receiver(msg)
					local user_id = "user#id"..group_owner
					if not is_admin2(group_owner) and not is_support(group_owner) then
						channel_demote(receiver, user_id, ok_cb, false)
					end
					local user = "user#id"..matches[2]
					channel_set_admin(receiver, user, ok_cb, false)
					data[tostring(msg.to.id)]['set_owner'] = tostring(matches[2])
					save_data(_config.moderation.data, data)
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set ["..matches[2].."] as owner")
					local text = "[ "..matches[2].." ] added as owner"
					return text
				end]]
				local get_cmd = 'setowner'
				local msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			      end	
			elseif not string.match(matches[2], '^%d+$') then
				if matches[1]:lower() == 'setowner' or matches[1] == 'تنظیم صاحب' and matches[2] then
				local get_cmd = 'setowner'
				local msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
				end	
			end
		end

		if matches[1]:lower() == 'promote' or matches[1] == 'ترفیع' then
			if not is_owner(msg) then
				return
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'promote',
					msg = msg
				}
				promote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif string.match(matches[2], '^%d+$') then
				if matches[1]:lower() == 'promote' and matches[2] or matches[1] == 'ترفیع' and matches[2] then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'promote'
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd, msg = msg})
				end	
			elseif not string.match(matches[2], '^%d+$') then
				if matches[1]:lower() == 'promote' and matches[2] or matches[1] == 'ترفیع' and matches[2] then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'promote',
					msg = msg
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
				end	
			end
		end

		--[[if matches[1]:lower() == 'mp' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_set_mod(channel, user_id, ok_cb, false)
			return "ok"
		end
		if matches[1]:lower() == 'md' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_demote(channel, user_id, ok_cb, false)
			return "ok"
		end]]

		if matches[1]:lower() == 'demote' then
			if not is_owner(msg) then
				return 
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demote',
					msg = msg
				}
				demote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1]:lower() == 'demote' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demote'
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1]:lower() == 'demote' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demote'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1]:lower() == "setname" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local set_name = string.gsub(matches[2], '_', '')
			----savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..matches[2])
			rename_channel(receiver, set_name, ok_cb, false)
		end

		if msg.service and msg.action.type == 'chat_rename' then
			----savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..msg.to.title)
			data[tostring(msg.to.id)]['settings']['set_name'] = msg.to.title
			save_data(_config.moderation.data, data)
		end

		if matches[1]:lower() == "setabout" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local about_text = matches[2]
			local data_cat = 'description'
			local target = msg.to.id
			data[tostring(target)][data_cat] = about_text
			save_data(_config.moderation.data, data)
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup description to: "..about_text)
			channel_set_about(receiver, about_text, ok_cb, false)
			return "Description has been set.\n\nSelect the chat again to see the changes."
		end

		if matches[1]:lower() == "setusername" and is_admin1(msg) then
			local function ok_username_cb (extra, success, result)
				local receiver = extra.receiver
				if success == 1 then
					send_large_msg(receiver, "SuperGroup username Set.\n\nSelect the chat again to see the changes.")
				elseif success == 0 then
					send_large_msg(receiver, "Failed to set SuperGroup username.\nUsername may already be taken.\n\nNote: Username can use a-z, 0-9 and underscores.\nMinimum length is 5 characters.")
				end
			end
			local username = string.gsub(matches[2], '@', '')
			channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
		end

		if matches[1]:lower() == 'setrules' or matches[1]:lower() == 'تنظیم قوانین' then
		if not is_momod(msg) then
		 return		
		end		
			rules = matches[2]
			local target = msg.to.id
			----savelog(msg.to.id, name_log.." ["..msg.from.id.."] has changed group rules to ["..matches[2].."]")
			return set_rulesmod(msg, data, target)
		end

		if msg.media then
			if msg.media.type == 'photo' and data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' and is_momod(msg) then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] set new SuperGroup photo")
				load_photo(msg.id, set_supergroup_photo, msg)
				return
			end
		end
		if matches[1]:lower() == 'setphoto' and is_momod(msg) then
			data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
			save_data(_config.moderation.data, data)
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] started setting new SuperGroup photo")
			return 'Please send the new group photo now'
		end

		if matches[1]:lower() == 'clean' then
			if not is_momod(msg) then
				return
			end
			if matches[2] == 'modlist' or matches[2] == 'لیست مدیران' then
				if next(data[tostring(msg.to.id)]['moderators']) == nil then
					return reply_msg(msg.id, '⚠️ لیست مدیران گروه خالی است !', ok_cb, false)
				end
				for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
					data[tostring(msg.to.id)]['moderators'][tostring(k)] = nil
					save_data(_config.moderation.data, data)
				end
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned modlist")
				return reply_msg(msg.id, '🗑 لیست مدیران گروه خالی شد !', ok_cb, false)
			end
			if matches[2] == 'rules' or matches[2] == 'قوانین' then
				local data_cat = 'rules'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return reply_msg(msg.id, '⚠️ قوانین گروه تنظیم نشده است !', ok_cb, false)
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned rules")
				return 'Rules have been cleaned'
			end
			if matches[2] == 'about' then
				local receiver = get_receiver(msg)
				local about_text = ' '
				local data_cat = 'description'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return 'About is not set'
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned about")
				channel_set_about(receiver, about_text, ok_cb, false)
				return "About has been cleaned"
			end
                      if matches[2]:lower() == 'deleted' and is_momod(msg) then
                        local receiver = get_receiver(msg)
                        channel_get_users(receiver, check_member_super_deleted, {receiver = receiver, msg = msg})
                      end			
			if matches[2] == 'mutelist' then
				chat_id = msg.to.id
				local hash =  'mute_user:'..chat_id
					redis:del(hash)
				return "Mutelist Cleaned"
			end
			--[[if matches[2] == 'username' and is_admin1(msg) then
				local function ok_username_cb (extra, success, result)
					local receiver = extra.receiver
					if success == 1 then
						send_large_msg(receiver, "SuperGroup username cleaned.")
					elseif success == 0 then
						send_large_msg(receiver, "Failed to clean SuperGroup username.")
					end
				end
				local username = ""
				channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
			end]]
			if matches[2] == "bots" and is_momod(msg) then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked all SuperGroup bots")
				channel_get_bots(receiver, callback_clean_bots, {msg = msg})
			end
		end

		if matches[1]:lower() == 'lock' then
			
		if not is_momod(msg) then
		 return
		end		
			local target = msg.to.id
			
                      if matches[2]:lower() == 'photo' or matches[2]:lower() == 'عکس' then
                        return lock_group_photo(msg, data, target)
                      end
                      if matches[2]:lower() == 'video' or matches[2]:lower() == 'فیلم' then
                        return lock_group_video(msg, data, target)
                      end
                      if matches[2]:lower() == 'gif' or matches[2]:lower() == 'گیف' then
                        return lock_group_gif(msg, data, target)
                      end
                      if matches[2]:lower() == 'audio' or matches[2]:lower() == 'صدا' then
                        return lock_group_audio(msg, data, target)
                      end
                      if matches[2]:lower() == 'file' or matches[2]:lower() == 'فایل' then
                        return lock_group_documents(msg, data, target)
                      end
                      if matches[2]:lower() == 'text' or matches[2]:lower() == 'متن' then
                        return lock_group_text(msg, data, target)
                      end
                      if matches[2]:lower() == 'all' or matches[2]:lower() == 'گروه' then
                        return lock_group_all(msg, data, target)
                      end			
			
			if matches[2]:lower() == 'links' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return lock_group_links(msg, data, target)
			end
			if matches[2]:lower() == 'bots' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return lock_group_bot(msg, data, target)
			end			
			if matches[2]:lower() == 'fwd' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return lock_group_fwd(msg, data, target)
			end	
			if matches[2]:lower() == 'cfwd' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return lock_group_cfwd(msg, data, target)
			end				
			if matches[2]:lower() == 'username' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return lock_group_user(msg, data, target)
			end			
			if matches[2]:lower() == 'spam' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked spam ")
				return lock_group_spam(msg, data, target)
			end
			if matches[2]:lower() == 'flood' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked flood ")
				return lock_group_flood(msg, data, target)
			end
			if matches[2]:lower() == 'arabic' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked arabic ")
				return lock_group_arabic(msg, data, target)
			end
			if matches[2]:lower() == 'english' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked arabic ")
				return lock_group_en(msg, data, target)
			end			
			--[[if matches[2]:lower() == 'member' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked member ")
				return lock_group_membermod(msg, data, target)
			end
			if matches[2]:lower():lower() == 'rtl' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked rtl chars. in names")
				return lock_group_rtl(msg, data, target)
			end]]
			if matches[2]:lower() == 'tgservice' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked Tgservice Actions")
				return lock_group_tgservice(msg, data, target)
			end
			if matches[2]:lower() == 'sticker' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked sticker posting")
				return lock_group_sticker(msg, data, target)
			end
			if matches[2]:lower() == 'contacts' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked contact posting")
				return lock_group_contacts(msg, data, target)
			end
			if matches[2]:lower() == 'strict' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked enabled strict settings")
				return enable_strict_rules(msg, data, target)
			end
		end

		if matches[1]:lower() == 'unlock' then
		if not is_momod(msg) then
		 return
		end
			local target = msg.to.id
			
		    if matches[2]:lower() == 'photo' or matches[2]:lower() == 'عکس' then
                        return unlock_group_photo(msg, data, target)
                      end
                      if matches[2]:lower() == 'video' or matches[2]:lower() == 'فیلم' then
                        return unlock_group_video(msg, data, target)
                      end
                      if matches[2]:lower() == 'gif' or matches[2]:lower() == 'گیف' then
                        return unlock_group_gif(msg, data, target)
                      end
                      if matches[2]:lower() == 'audio' or matches[2]:lower() == 'صدا' then
                        return unlock_group_audio(msg, data, target)
                      end
                      if matches[2]:lower() == 'file' or matches[2]:lower() == 'فایل' then
                        return unlock_group_documents(msg, data, target)
                      end
                      if matches[2]:lower() == 'text' or matches[2]:lower() == 'متن' then
                        return unlock_group_text(msg, data, target)
                      end
                      if matches[2]:lower() == 'all' or matches[2]:lower() == 'گروه' then
                        return unlock_group_all(msg, data, target)
                      end
			
			if matches[2]:lower() == 'links' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
				return unlock_group_links(msg, data, target)
			end
			if matches[2]:lower() == 'bots' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
				return unlock_group_bot(msg, data, target)
			end			
			if matches[2]:lower() == 'fwd' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
				return unlock_group_fwd(msg, data, target)
			end	
			if matches[2]:lower() == 'cfwd' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
				return unlock_group_cfwd(msg, data, target)
			end			
			if matches[2]:lower() == 'username' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
				return unlock_group_user(msg, data, target)
			end						
			if matches[2]:lower() == 'spam' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked spam")
				return unlock_group_spam(msg, data, target)
			end
			if matches[2]:lower() == 'flood' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked flood")
				return unlock_group_flood(msg, data, target)
			end
			if matches[2]:lower() == 'arabic' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked Arabic")
				return unlock_group_arabic(msg, data, target)
			end
			if matches[2]:lower() == 'english' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked Arabic")
				return unlock_group_en(msg, data, target)
			end			
			--[[if matches[2]:lower() == 'member' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked member ")
				return unlock_group_membermod(msg, data, target)
			end
			if matches[2]:lower():lower() == 'rtl' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked RTL chars. in names")
				return unlock_group_rtl(msg, data, target)
			end]]
			if matches[2]:lower() == 'tgservice' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tgservice actions")
				return unlock_group_tgservice(msg, data, target)
			end
			if matches[2]:lower() == 'sticker' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked sticker posting")
				return unlock_group_sticker(msg, data, target)
			end
			if matches[2]:lower() == 'contacts' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked contact posting")
				return unlock_group_contacts(msg, data, target)
			end
			if matches[2]:lower() == 'strict' then
				----savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked disabled strict settings")
				return disable_strict_rules(msg, data, target)
			end
		end
		
		if matches[1]:lower() == 'setflood' then
			if not is_momod(msg) then
				return
			end
			if tonumber(matches[2]) < 5 or tonumber(matches[2]) > 20 then
				return "Wrong number,range is [5-20]"
			end
			local flood_max = matches[2]
			data[tostring(msg.to.id)]['settings']['flood_msg_max'] = flood_max
			save_data(_config.moderation.data, data)
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set flood to ["..matches[2].."]")
			return 'Flood has been set to: '..matches[2]
		end
		if matches[1]:lower() == 'public' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'yes' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: public")
				return set_public_membermod(msg, data, target)
			end
			if matches[2] == 'no' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: not public")
				return unset_public_membermod(msg, data, target)
			end
		end

		if matches[1]:lower() == 'mute' and is_owner(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'audio' then
			local msg_type = 'Audio'
				if not is_muted(chat_id, msg_type..': yes') then
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." has been muted"
				else
					return "SuperGroup mute "..msg_type.." is already on"
				end
			end
			if matches[2] == 'photo' then
			local msg_type = 'Photo'
				if not is_muted(chat_id, msg_type..': yes') then
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." has been muted"
				else
					return "SuperGroup mute "..msg_type.." is already on"
				end
			end
			if matches[2] == 'video' then
			local msg_type = 'Video'
				if not is_muted(chat_id, msg_type..': yes') then
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." has been muted"
				else
					return "SuperGroup mute "..msg_type.." is already on"
				end
			end
			if matches[2] == 'gifs' then
			local msg_type = 'Gifs'
				if not is_muted(chat_id, msg_type..': yes') then
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." have been muted"
				else
					return "SuperGroup mute "..msg_type.." is already on"
				end
			end
			if matches[2] == 'documents' then
			local msg_type = 'Documents'
				if not is_muted(chat_id, msg_type..': yes') then
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." have been muted"
				else
					return "SuperGroup mute "..msg_type.." is already on"
				end
			end
			if matches[2] == 'text' then
			local msg_type = 'Text'
				if not is_muted(chat_id, msg_type..': yes') then
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." has been muted"
				else
					return "Mute "..msg_type.." is already on"
				end
			end
			if matches[2] == 'all' then
			local msg_type = 'All'
				if not is_muted(chat_id, msg_type..': yes') then
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "Mute "..msg_type.."  has been enabled"
				else
					return "Mute "..msg_type.." is already on"
				end
			end
		end
		if matches[1]:lower() == 'unmute' and is_momod(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'audio' then
			local msg_type = 'Audio'
				if is_muted(chat_id, msg_type..': yes') then
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." has been unmuted"
				else
					return "Mute "..msg_type.." is already off"
				end
			end
			if matches[2] == 'photo' then
			local msg_type = 'Photo'
				if is_muted(chat_id, msg_type..': yes') then
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." has been unmuted"
				else
					return "Mute "..msg_type.." is already off"
				end
			end
			if matches[2] == 'video' then
			local msg_type = 'Video'
				if is_muted(chat_id, msg_type..': yes') then
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." has been unmuted"
				else
					return "Mute "..msg_type.." is already off"
				end
			end
			if matches[2] == 'gifs' then
			local msg_type = 'Gifs'
				if is_muted(chat_id, msg_type..': yes') then
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." have been unmuted"
				else
					return "Mute "..msg_type.." is already off"
				end
			end
			if matches[2] == 'documents' then
			local msg_type = 'Documents'
				if is_muted(chat_id, msg_type..': yes') then
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." have been unmuted"
				else
					return "Mute "..msg_type.." is already off"
				end
			end
			if matches[2] == 'text' then
			local msg_type = 'Text'
				if is_muted(chat_id, msg_type..': yes') then
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute message")
					unmute(chat_id, msg_type)
					return msg_type.." has been unmuted"
				else
					return "Mute text is already off"
				end
			end
			if matches[2] == 'all' then
			local msg_type = 'All'
				if is_muted(chat_id, msg_type..': yes') then
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "Mute "..msg_type.." has been disabled"
				else
					return "Mute "..msg_type.." is already disabled"
				end
			end
		end


		if matches[1]:lower() == "muteuser" and is_momod(msg) then
			local chat_id = msg.to.id
			local hash = "mute_user"..chat_id
			local user_id = ""
			if type(msg.reply_id) ~= "nil" then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				muteuser = get_message(msg.reply_id, get_message_callback, {receiver = receiver, get_cmd = get_cmd, msg = msg})
			elseif matches[1]:lower() == "muteuser" and matches[2] and string.match(matches[2], '^%d+$') then
				local user_id = matches[2]
				if is_muted_user(chat_id, user_id) then
					unmute_user(chat_id, user_id)
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] removed ["..user_id.."] from the muted users list")
					return "["..user_id.."] removed from the muted users list"
				elseif is_owner(msg) then
					mute_user(chat_id, user_id)
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] added ["..user_id.."] to the muted users list")
					return "["..user_id.."] added to the muted user list"
				end
			elseif matches[1]:lower() == "muteuser" and matches[2] and not string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				resolve_username(username, callbackres, {receiver = receiver, get_cmd = get_cmd, msg=msg})
			end
		end

		if matches[1]:lower() == "muteslist" and is_momod(msg) then
			local chat_id = msg.to.id
			if not has_mutes(chat_id) then
				set_mutes(chat_id)
				return mutes_list(chat_id)
			end
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup muteslist")
			return mutes_list(chat_id)
		end
		if matches[1]:lower() == "mutelist" and is_momod(msg) then
			local chat_id = msg.to.id
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup mutelist")
			return muted_user_list(chat_id)
		end

		if matches[1]:lower() == 'settings' and is_momod(msg) then
			local target = msg.to.id
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup settings ")
			return show_supergroup_settingsmod(msg, target)
		end
		
		if matches[1]:lower() == 'config' or matches[1] == 'ارتقا ادمین ها' then
		 if not is_owner(msg) then
		   return		
		 end		
                  member_type = 'Admins'
                  admins = channel_get_admins(receiver,promoteadmin, {receiver = receiver, msg = msg, member_type = member_type})
		end
		
		if matches[1]:lower() == 'rules' or matches[1] == 'قوانین' then
			if not is_momod(msg) then
			   return	
			end	
			----savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group rules")
			return get_rules(msg, data)
		end

		if matches[1]:lower() == 'help' and not is_owner(msg) then
			text = "Message /superhelp to @Teleseed in private for SuperGroup help"
			--reply_msg(msg.id, text, ok_cb, false)
		elseif matches[1]:lower() == 'help' and is_owner(msg) then
			local name_log = user_print_name(msg.from)
			----savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /superhelp")
			--return super_help()
		end

		if matches[1]:lower() == 'peer_id' and is_admin1(msg)then
			text = msg.to.peer_id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		if matches[1]:lower() == 'msg.to.id' and is_admin1(msg) then
			text = msg.to.id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		--Admin Join Service Message
		if msg.service then
		local action = msg.action.type
			if action == 'chat_add_user_link' then
				if is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					--savelog(msg.to.id, name_log.." Admin ["..msg.from.id.."] joined the SuperGroup via link")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.from.id) and not is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					--savelog(msg.to.id, name_log.." Support member ["..msg.from.id.."] joined the SuperGroup")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
			if action == 'chat_add_user' then
				if is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					--savelog(msg.to.id, name_log.." Admin ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.action.user.id) and not is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					--savelog(msg.to.id, name_log.." Support member ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
		end
		--if matches[1]:lower() == 'msg.to.peer_id' then
			--post_large_msg(receiver, msg.to.peer_id)
		--end
	end
end

local function pre_process(msg)
  if not msg.text and msg.media then
    msg.text = '['..msg.media.type..']'
  end
  return msg
end

return {
  patterns = {
	"^([Aa][Dd][Dd])$",
	"^([Rr][Ee][Mm])$",
	"^(افزودن)$",
	"^(حذف گروه)$",
		
	--"^([Mm]ove) (.*)$",
		
	"^([Ii][Nn][Ff][Oo])$",
	"^(اطلاعات گروه)$",
		
	"^([Aa][Dd][Mm][Ii][Nn][Ss])$",
	"^(ادمین ها)$",
		
	"^([Oo][Ww][Nn][Ee][Rr])$",
	"^(صاحب گروه)$",
		
	"^([Mm][Oo][Dd][Ll][Ii][Ss][Tt])$",
	"^(مدیران)$",
		
	"^([Bb][Oo][Tt][Ss])$",
	"^(ربات ها)$",
		
	--"^([Ww]ho)$",
	--"^([Kk]icked)$",
		
	"^([Cc][Oo][Nn][Ff][Ii][Gg])$",	
	"^(ارتقا ادمین ها)$",				
		
        --"^([Bb]lock) (.*)",
	--"^([Bb]lock)",
		
	"^([Tt]osuper)$",
		
	"^([Ii][Dd])$",
	"^([Ii][Dd]) (.*)$",
		
	"^(شناسه)$",
	"^(شناسه) (.*)$",		
		
	--"^([Kk]ickme)$",
	--"^([Kk]ick) (.*)$",
	--"^([Nn]ewlink)$",
		
	"^([Ss][Ee][Tt][Ll][Ii][Nn][Kk])$",
	"^(تنظیم لینک)$",
		
	"^([Ll][Ii][Nn][Kk])$",		
	"^(لینک)$",
		
	--"^([Rr]es) (.*)$",
		
	--"^([Ss]etadmin) (.*)$",
	--"^([Ss]etadmin)",
	--"^([Dd]emoteadmin) (.*)$",
	--"^([Dd]emoteadmin)",
		
	"^([Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]) (.*)$",
	"^([Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr])$",
	"^(تنظیم صاحب) (.*)$",
	"^(تنظیم صاحب)$",
		
	"^([Pp][Rr][Oo][Mm][Oo][Tt][Ee]) (.*)$",
	"^([Pp][Rr][Oo][Mm][Oo][Tt][Ee])",
	"^(ترفیع) (.*)$",
	"^(ترفیع)",
		
	"^([Dd][Ee][Mm][Oo][Tt][Ee]) (.*)$",
	"^([Dd][Ee][Mm][Oo][Tt][Ee])",
	"^(تنزل) (.*)$",
	"^(تنزل)",
		
	"^([Ss]etname) (.*)$",
	"^([Ss]etabout) (.*)$",
	"^([Ss]etrules) (.*)$",
	"^([Ss]etphoto)$",
		
	--"^([Ss]etusername) (.*)$",
	"^([Dd]el)$",
		
	"^([Ll]ock) (.*)$",
	"^([Uu]nlock) (.*)$",
		
	--"^([Mm]ute) ([^%s]+)$",
	--"^([Uu]nmute) ([^%s]+)$",
	"^([Mm]uteuser)$",
	"^([Mm]uteuser) (.*)$",
	--"^([Pp]ublic) (.*)$",
	"^([Ss]ettings)$",
	"^([Rr]ules)$",
	"^([Ss]etflood) (%d+)$",
	"^([Cc]lean) (.*)$",
	--"^([Hh]elp)$",
	--"^([Mm]uteslist)$",
	--"^([Mm]utelist)$",
       -- "(mp) (.*)",
	--"(md) (.*)",

        "^([https?://w]*.?telegram.me/joinchat/%S+)$",
        "^([https?://w]*.?t.me/joinchat/%S+)$",	
		
	--"msg.to.peer_id",
	--"%[(document)%]",
	"%[(photo)%]",
	--"%[(video)%]",
	--"%[(audio)%]",
	--"%[(contact)%]",
	--"^!!tgservice (.+)$",
  },
  run = run,
  pre_process = pre_process
}
--End supergrpup.lua
--By @Rondoozle
