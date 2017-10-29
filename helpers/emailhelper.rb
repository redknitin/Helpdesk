#Send email; the maildata parameter should include receipient_name, recipient_email, subject, body as keys
def send_email(maildata)
	require 'net/smtp'
	require 'socket'

	maildata[:smtp_host] = ((defined? AppConfig::MAIL_SMTP_HOST) == nil) ? nil : AppConfig::MAIL_SMTP_HOST
	maildata[:smtp_port] = ((defined? AppConfig::MAIL_SMTP_PORT) == nil) ? nil : AppConfig::MAIL_SMTP_PORT
	maildata[:smtp_user] = ((defined? AppConfig::MAIL_SMTP_USER) == nil) ? nil : AppConfig::MAIL_SMTP_USER
	maildata[:smtp_pass] = ((defined? AppConfig::MAIL_SMTP_PASS) == nil) ? nil : AppConfig::MAIL_SMTP_PASS
	maildata[:smtp_auth] = ((defined? AppConfig::MAIL_SMTP_AUTH) == nil) ? nil : AppConfig::MAIL_SMTP_AUTH
	maildata[:sender_email] = ((defined? AppConfig::MAIL_SENDER_EMAIL) == nil) ? nil : AppConfig::MAIL_SENDER_EMAIL
	maildata[:sender_name] = ((defined? AppConfig::MAIL_SENDER_NAME) == nil) ? nil : AppConfig::MAIL_SENDER_NAME

	if maildata[:smtp_host] == nil
		return
	end

	if maildata[:smtp_port] == nil
		maildata[:smtp_port] = 25
	end

	if maildata[:sender_email] == nil
		maildata[:sender_email] = ('noreply@' + Socket.gethostname)
	end

	if maildata[:sender_name] == nil
		maildata[:sender_name] = 'Helpdesk'
	end

	message = <<-END.split("\n").map!(&:strip).join("\n")
From: #{maildata[:sender_name]} <#{maildata[:sender_email]}>
To: #{maildata[:recipient_name]} <#{maildata[:recipient_email]}>
Subject: #{maildata[:subject]}

#{maildata[:body]}
END

	s = Net::SMTP.new maildata[:smtp_host], maildata[:smtp_port]

	if  ((defined? AppConfig::MAIL_SMTP_STARTTLS) != nil) && AppConfig::MAIL_SMTP_STARTTLS
		s.enable_starttls
	end

	if maildata[:smtp_user] != nil
		if maildata[:smtp_auth] == nil
			maildata[:smtp_auth] = :plain
		end

		s.start(Socket.gethostname, maildata[:smtp_user], maildata[:smtp_pass], maildata[:smtp_auth]) do |smtp|
			smtp.send_message message, maildata[:sender_email], maildata[:recipient_email]
		end
	else
		s.start(Socket.gethostname) do |smtp|
			smtp.send_message message, maildata[:sender_email], maildata[:recipient_email]
		end
	end
end
