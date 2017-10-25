def send_email(maildata)
	require 'net/smtp'
	require 'socket'

	message = <<-END.split("\n").map!(&:strip).join("\n")
	From: #{maildata[:sender_name]} <#{maildata[:sender_email]}>
	To: #{maildata[:recipient_name]} <#{maildata[:recipient_email]}>
	Subject: #{maildata[:subject]}

	#{maildata[:body]}
	END

	if maildata[:smtp_user] != nil
		Net::SMTP.start(maildata[:smtp_host], maildata[:smtp_port], Socket.gethostname, maildata[:smtp_user], maildata[:smtp_pass], maildata[:smtp_auth]) do |smtp|
			smtp.send_message message, maildata[:sender_email], maildata[:recipient_email]
		end
	else
		Net::SMTP.start(maildata[:smtp_host], maildata[:smtp_port], Socket.gethostname) do |smtp|
			smtp.send_message message, maildata[:sender_email], maildata[:recipient_email]
		end
	end
end
