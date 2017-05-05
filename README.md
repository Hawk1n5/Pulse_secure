# Pulse_secure

針對自動化加入Realms,Roles,profile的api

```
#!/usr/bin/env ruby
require './robot.rb'

# 建立至 pulse secure 的連線
ps = PulseSecure.new("10.254.254.34", 443) 

# 設定登入page(目前只有做passwd登入方式)
ps.setLoginPage("/dana-na/auth/url_admin/login.cgi")

# login(user, passwd) 帶入username及password即可登入 注意原帳號之session必須是以登出!!!!
ps.login("demo","********")

# roles(name, description)
ps.roles("demo_profile", "demo_profile_add_by_hawk1n5")

# profile(name, AD帳號, ip, 對應上面的roles name)
ps.profile("demo RDP", "demo", "127.0.0.1", "demo_profile")

# roleMap(name, 對應上面的roles name)
ps.roleMap("demo", "demo_profile")

# bookmark(name, mutli_monitor) # mutli_monitor 是否給予多螢幕
ps.bookmark("demo RDP", false)

# Logout
ps.logout()
```
