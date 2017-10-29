def send_email(maildata)
	require 'net/smtp'
	require 'socket'

	#Args should include receipient_name, recipient_email, subject, body

	maildata[:smtp_host] = AppConfig::MAIL_SMTP_HOST
	maildata[:smtp_port] = AppConfig::MAIL_SMTP_PORT
	maildata[:smtp_user] = AppConfig::MAIL_SMTP_USER
	maildata[:smtp_pass] = AppConfig::MAIL_SMTP_PASS
	maildata[:smtp_auth] = AppConfig::MAIL_SMTP_AUTH
	maildata[:sender_email] = AppConfig::MAIL_SENDER_EMAIL
	maildata[:sender_name] = AppConfig::MAIL_SENDER_NAME

	message = <<-END.split("\n").map!(&:strip).join("\n")
From: #{maildata[:sender_name]} <#{maildata[:sender_email]}>
To: #{maildata[:recipient_name]} <#{maildata[:recipient_email]}>
Subject: #{maildata[:subject]}

#{maildata[:body]}
END

	s = Net::SMTP.new maildata[:smtp_host], maildata[:smtp_port]

	if AppConfig::MAIL_SMTP_STARTTLS
		s.enable_starttls
	end

	if maildata[:smtp_user] != nil
		s.start(Socket.gethostname, maildata[:smtp_user], maildata[:smtp_pass], maildata[:smtp_auth]) do |smtp|
			smtp.send_message message, maildata[:sender_email], maildata[:recipient_email]
		end
	else
		s.start(Socket.gethostname) do |smtp|
			smtp.send_message message, maildata[:sender_email], maildata[:recipient_email]
		end
	end
end

# def test_email()
# 	send_email({
# 			:receipient_name => 'Anonymous', 
# 			:recipient_email => 'appsmabdxb@gmail.com', 
# 			:subject => 'Test', 
# 			:body => 'Testing'
# 			})
# end
