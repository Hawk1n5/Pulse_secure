# Pulse_secure

## Introduction

針對自動化加入Realms,Roles,profile的api

```
#!/usr/bin/env ruby
require './robot.rb'
require 'net/http'

ps = PulseSecure.new("10.254.254.34", 443)
ps.setLoginPage("/dana-na/auth/url_admin/login.cgi")
ps.login("tz_offset=480&username=demo&password=********&realm=Admin+Users&btnSubmit=Sign+In")

ps.roles("demo_profile", "demo_profile_add_by_hawk1n5")
ps.profile("demo RDP", "demo", "127.0.0.1", "demo_profile")
ps.roleMap("demo", "demo_profile")
ps.bookmark("demo RDP")
ps.logout()
```
