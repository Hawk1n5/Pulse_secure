#!/usr/bin/env ruby
require 'net/http'
require 'net/https'
require 'openssl'

class PulseSecure
	def initialize(host, port)
		@http 		  = Net::HTTP.new(host, port)
		@http.use_ssl	  = true
		@http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		
		@header 			    = {}
		@header["Host"] 		    = host
		@header["User-Agent"] 		    = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:52.0) Gecko/20100101 Firefox/52.0.1 Waterfox/52.0.1" 
		@header["Accept"] 		    = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
		@header["Accept-Language"]	    = "en-US,en;q=0.5"
		@header["Cookie"] 		    = "DSSignInURL=/admin/;"
		@header["Connection"] 		    = "keep-alive" 
		@header["Upgrade-Insecure-Requests"]="1"
	end
	def setLoginPage(page)
		@loginPage = page
	end
	def login(data)
		page = @http.post(@loginPage, data, @header)
	
		location = page.response['location'].match(/https:\/\/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(.*)/).captures()[0]
		if page.response['set-cookie']
			page.response['set-cookie'].split(" ").each do |cookie|
				@header["Cookie"] << "#{cookie}" if cookie[/DS/]
			end
		end
		page = @http.post(location, '', @header) if location[/dashboard/]
	end
	def setCookie(response)
		response.split(" ").each do |cookie|
			@header["Cookie"] << "#{cookie};" if cookie[/DS/]
		end
	end
	def getResponse(page)
		page.response.each do |k, v|
			puts "[!] #{k} : #{v}"
		end
	end
	def roles(txtName, txtDescription)
		page = "/dana-admin/roles/roles.cgi"
		role_page = @http.post("#{page}?btnNew=1", '', @header)
		xsauth = role_page.body.match(/name="xsauth" type="hidden" value="(.*)"\/>/).captures()[0]
		
		post_data = "xsauth=#{xsauth}&txtName=#{txtName}&txtDescription=#{txtDescription}&chkSession=on&chkUI=on&chkWinTermServ=on&optSamType=jsam&btnCreate=Save%2bChanges"
		
		@header["Referer"] = "https://10.254.254.34/dana-admin/roles/roles.cgi?btnNew=1"
		page = @http.post(page, post_data, @header)
		@header["Referer"] = ""
		location = page.response['location']
		page = @http.post(location, '', @header) if location[/overview/]
	end
	def logout()
		page = @http.post('/dana-na/auth/logout.cgi', '', @header)
		if page.response['set-cookie']
                        page.response['set-cookie'].split(" ").each do |cookie|
                                @header["Cookie"] << "#{cookie}" if cookie[/DS/]
                        end
                end
		location = page.response['location']
		@header["Referer"] = "https://10.254.254.34/dana-admin/realm/rules.cgi?realmType=user&PolicyRealm=3"
		@http.post(location, '', @header)
		@header["Referer"] = ""
	end
	def profile(txtName, txtDescription, host, roleName)
		page = "/dana-admin/objects/new_object.cgi" 

		@header["Referer"] = "https://10.254.254.34/dana-admin/objects/resource_objects.cgi?object_type=term"
		profile_page = @http.post(page, '', @header)
		xsauth = profile_page.body.match(/type="hidden" name="xsauth" value="(.*)"\/>/).captures()[0]
		profile_page = @http.post(page, "object_type=term&profile_version=&before=end&xsauth=#{xsauth}", @header)
		@header["Referer"] = ""	

		policy_version = profile_page.body.match(/name="policy_version" id="policy_version" value="(.*)">/).captures()[0] 
		applet_archive = profile_page.body.match(/name="applet_archives" id="applet_archives" value="(.*)">/).captures()[0]

		post_data = %{
-----------------------------3219279969941\r\nContent-Disposition: form-data; name="xsauth"\r\n\r\n#{xsauth}\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="policy_version"\r\n\r\n#{policy_version}\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="applet_archives"\r\n\r\n#{applet_archive}\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="optType"\r\n\r\n0\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="ica_file"; filename=""\r\nContent-Type: application/octet-stream\r\n\r\n\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="txtName"\r\n\r\n#{txtName}\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="txtDescription"\r\n\r\n#{txtDescription}\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="txtServer"\r\n\r\n#{host}\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="txtServerPort"\r\n\r\n3389\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="chkCreateACLPolicy"\r\n\r\nON\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="txtServers"\r\n\r\n\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="txtXMLUsername"\r\n\r\n\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="txtXMLPasswordVar"\r\n\r\n\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="txtXMLPassword"\r\n\r\n\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="txtXMLDomain"\r\n\r\n\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="term_acl_input1txt"\r\n\r\n\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="term_acl_input2select"\r\n\r\nAllow\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="term_acl_tblEditVal_1txt"\r\n\r\n\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="term_acl_tblEditVal_2select"\r\n\r\nAllow\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="term_acl_results"\r\n\r\n-1||Allow\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="term_acl_backupValue"\r\n\r\n\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="term_acl_cmd"\r\n\r\n\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="term_acl_insertbefore"\r\n\r\n\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="chkJava"\r\n\r\nON\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="applet_id"\r\n\r\napplet_10000\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="oldapplet_id"\r\n\r\n\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="txtAppletHTML"\r\n\r\n\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="chkJavaFallBack"\r\n\r\njavaFall\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="object_type"\r\n\r\nterm\r\n-----------------------------3219279969941\r\nContent-Disposition: form-data; name="btnSave"\r\n\r\nSave and Continue >\r\n-----------------------------3219279969941--\r\n
		}

		@header["Content-Type"] = "multipart/form-data; boundary=---------------------------3219279969941"
		@header["Referer"]	= "https://10.254.254.34/dana-admin/objects/new_object.cgi" 
		page = @http.post(page, post_data, @header)
		@header["Content-Type"] = ""
		@header["Referer"]	= ""

		location = page.response['location']

		@header["Referer"] = "https://10.254.254.34#{location}"
		role_page = @http.post(location, '', @header)

		role_id        = role_page.body.match(/<option id="option_select_roles.*" value="(.*)">#{roleName}<\/option>/).captures()[0]
		policy_version = role_page.body.match(/type="hidden" name="policy_version" value="(.*)">/).captures()[0]
		object_id      = role_page.body.match(/type="hidden" name="object_id" value="(.*)">/).captures()[0]

		post_data = "xsauth=#{xsauth}&selectedRoles=#{role_id}&policy_version=#{policy_version}&object_type=term&subtype=&object_id=#{object_id}&create=&optRoles=selected&btnSave=Save+Changes"

		page = @http.post(location, post_data, @header)
		return page["location"].match(/&object_id=(.*)/).captures()[0]
	end
	def roleMap(txtRuleName, selectRoles)
		page = "/dana-admin/realm/rolemapping.cgi?newPolicyRoleMapping=1&PolicyRealm=3&realmType=user"
		@header["Referer"] = "https://10.254.254.34/dana-admin/realm/rules.cgi?realmType=user&PolicyRealm=3"
        
		mapping_page = @http.post(page, '', @header)
        	xsauth       = mapping_page.body.match(/type="hidden" name="xsauth" value="(.*)"\/>/).captures()[0]
		serverName   = "5"#mapping_page.body.match(/type="hidden" name="serverName" value="(.*)">/).captures()[0] 

		publicRoles  = "1490931687.106313.0"#mapping_page.body.match(/value="(.*)">public_profile<\/option>/).captures()[0]

		@header["Referer"] = "https://10.254.254.34/dana-admin/realm/rolemapping.cgi?newPolicyRoleMapping=1&PolicyRealm=3&realmType=user"
		post_data = "PolicyRealm=3&realmType=user&RuleId=&RuleCondition=username&RuleUpdateVersion=&serverName=#{serverName}&xsauth=#{xsauth}&cmbRuleCondition=username&txtRuleName=#{txtRuleName}&cmbRelationOperator=is&txtUserNamePatterns=#{txtRuleName}&lstSelectedRoles=#{selectRoles}&lstSelectedRoles=#{publicRoles}&chkStopProcessing=ON&btnSaveRuleMapping=Save+Changes"
		page = @http.post(page, post_data, @header)	
	
		selectedRoles= page.body.match(/value="(.*)">#{selectRoles}<\/option>/).captures()[0]
		serverName   = page.body.match(/type="hidden" name="serverName" value="(.*)">/).captures()[0]
		xsauth       = page.body.match(/type="hidden" name="xsauth" value="(.*)"\/>/).captures()[0]
	
		page = "/dana-admin/realm/rolemapping.cgi?newPolicyRoleMapping=1&PolicyRealm=3&realmType=user"
		post_data = "PolicyRealm=3&realmType=user&RuleId=&RuleCondition=username&RuleUpdateVersion=&serverName=#{serverName}&xsauth=#{xsauth}&cmbRuleCondition=username&txtRuleName=#{txtRuleName}&cmbRelationOperator=is&txtUserNamePatterns=#{txtRuleName}&lstSelectedRoles=#{selectedRoles}&lstSelectedRoles=#{publicRoles}&chkStopProcessing=ON&btnSaveRuleMapping=Save+Changes"
		page = @http.post(page, post_data, @header)	
		@header["Referer"] = ""
	end
	def bookmark(profile_name)
		page = "/dana-admin/objects/resource_objects.cgi?object_type=term"
		@header["Referer"] = "https://10.254.254.34/dana-admin/misc/dashboard.cgi"
		objects_page = @http.post(page, '',@header)		
		
		href = objects_page.body.match(/<a href="(.*bm_id.*)">#{profile_name}/).captures()[0]

		page = "/dana-admin/objects/#{href}"
		@header["Referer"] = "https://10.254.254.34/dana-admin/objects/edit_object_bms.cgi?object_id=1490591498.906614.0&object_type=term&subtype=0"
		
		bookmark_page = @http.post(page, '', @header)
		page = "/dana-admin/objects/edit_object_bm.cgi"
		xsauth          = bookmark_page.body.match(/type="hidden" name="xsauth" value="(.*)"\/>/).captures()[0]
		optType	        = bookmark_page.body.match(/type="hidden" name="optType" value="(.*)">/).captures()[0]
		txtServer       = bookmark_page.body.match(/type="hidden" name="txtServer" value="(.*)">/).captures()[0]
		txtServerPort   = bookmark_page.body.match(/type="hidden" name="txtServerPort" value="(.*)">/).captures()[0]
		applet_id       = bookmark_page.body.match(/type="hidden" name="applet_id" value="(.*)">/).captures()[0]
	
		txtName         = bookmark_page.body.match(/type="text" name="txtName" size="30"  value="(.*)">/).captures()[0]	
		object_id       = bookmark_page.body.match(/type="hidden" name="object_id" value="(.*)">/).captures()[0]
		bm_id           = bookmark_page.body.match(/type="hidden" name="bm_id" value="(.*)">/).captures()[0]
		policy_version  = bookmark_page.body.match(/type="hidden" name="policy_version" value="(.*)">/).captures()[0]
	
		post_data = "xsauth=#{xsauth}&optType=#{optType}&txtServer=#{txtServer}&txtServerPort=#{txtServerPort}&chkJava=ON&chkJavaFallBack=javaFall&applet_id=#{applet_id}&txtName=#{txtName}&txtDescription=&cmbScreenSize=Full+Screen&colorDepth=32&txtUsername=&optPassType=Variable&txtPasswordVariable=&txtPassword=&txtStartApp=&txtStartDir=&chkConnectDrives=ON&chkAllowClipboard=ON&chkMultiMon=ON&soundOptions=local&selectedRoles=%2C&policy_version=#{policy_version}&object_type=term&subtype=0&object_id=#{object_id}&create=&optRoles=all&object_type=term&subtype=0&object_id=#{object_id}&bm_id=#{bm_id}&btnSave=Save+Changes"
		@header["Referer"] = "https://10.254.254.34/dana-admin/objects/edit_object_bm.cgi?object_type=term&subtype=&object_id=#{object_id}&bm_id=#{bm_id}"
		
		@http.post(page, post_data, @header)
	end
end
