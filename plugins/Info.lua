function run(msg, matches , result)
local db = 'https://api.telegram.org/bot236823773:AAHuvA1wudU3hStv2Qq4RjD-MtSZoiTRPf4/getUserProfilePhotos?user_id='..msg.from.id
local path = 'https://api.telegram.org/bot236823773:AAHuvA1wudU3hStv2Qq4RjD-MtSZoiTRPf4/getFile?file_id='  
local img = 'https://api.telegram.org/file/bot236823773:AAHuvA1wudU3hStv2Qq4RjD-MtSZoiTRPf4/'
local res, code = https.request(db)
local jdat = json:decode(res)
if jdat.result == nil then
   return "nil"     
 else
 local fileid = jdat.result.photos[1][3].file_id
 local pt, code = https.request(path..fileid)
 local jdat2 = json:decode(pt)
 local path2 = jdat2.result.file_path  
 local link = img..path2
 local photo = download_to_file(link,"ax"..msg.from.id..".jpg")
     send_photo2(get_receiver(msg), photo, "- نام : "..msg.from.first_name.."\n"
.."- آیدی : "..msg.from.id.."\n"
.."- نام کاربری : @"..msg.from.username.."\n"
.."- نام گروه : "..msg.to.title.."\n"
.."️- کانال :  \n@TeleGold_Team", ok_cb, false)       
end        
end
return {
patterns = {
"^(عکس من)$",
"^(پروفایل من)$"
},
run = run
}
