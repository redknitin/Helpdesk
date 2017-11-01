#
# NOTES
#
# Use rackup and pass command-line parameters for host, port, server instead of set :bind and set :port - see runme.bat for an example
#
# This file is a part of the code repository, so you can define environment-specific config in app_config.env.rb
#

class AppConfig
  #
  # Database settings
  #
  DB_URL = 'mongodb://127.0.0.1:27017/helpdesk'  #mongodb://user:password@127.0.0.1:27017/helpdesk

  #
  # Master data for the application
  #
  MASTER_LOC_STRUCT = [
    {
      :code => 'KATCO',
      :name => 'Kat Corp',
      :type => 'Organization',
      :children => [
        {
          :code => 'DXBBR',
          :name => 'Dubai Branch',
          :type => 'Site',
          :children => [
            {
              :code => 'B01-ADM',
              :name => 'Administration Building',
              :type => 'Building',
              :children => [
                {
                  :code => 'B01-ADM_F01',
                  :name => '1st Floor',
                  :type => 'Floor',
                  :children => [
                    {
                      :code => 'RM101',
                      :name => 'Tech Support Root',
                      :type => 'Room',
                      :children => [] #We don't need assets now; reserve this field for future
                    }
                  ]
                }
              ]
            }
          ]
        },
        {
          :code => 'SHJBR',
          :name => 'Sharjah Branch',
          :type => 'Site'
        },
      ]
    },
    {
      :code => 'REDCO',
      :name => 'Red Corp',
      :type => 'Organization',
      :children => [
        {
          :code => 'DXBBR',
          :name => 'Dubai Branch',
          :type => 'Site'
        },
        {
          :code => 'AUHBR',
          :name => 'Abu Dhabi Branch',
          :type => 'Site'
        },
      ]
    },
  ]

  #Replace MASTER_BLDG_FLOOR with MASTER_LOC_STRUCT
  MASTER_BLDG_FLOOR = [
    {:building => 'Building 01', :floors => ['Roof Top', '2nd Floor (2)', '1st Floor (1)', 'Ground Floor (0)', 'Lower Ground (B1/-1)', 'Basement 1 (B2/-2)', 'Basement 2 (B3/-3)']},
    {:building => 'Building 02', :floors => ['2nd Floor (2)', '1st Floor (1)', 'Ground Floor (0)', 'Lower Ground (B1/-1)', 'Basement 1 (B2/-2)']}
  ]

  MASTER_ORG_DEPT = [
    {:org => 'Apache Foundation', :dept => ['Software Development', 'Quality Control']},
    {:org => 'Canonical', :dept => ['System Administration', 'Marketing']}
  ]
  
  #
  # Email settings
  #
  # MAIL_SMTP_HOST = 'localhost'
  # MAIL_SMTP_PORT = 25
  # MAIL_SMTP_USER = ''
  # MAIL_SMTP_PASS = ''
  # MAIL_SMTP_AUTH = :plain
  # MAIL_SMTP_STARTTLS = true

  # MAIL_SMTP_HOST = 'smtp.mailtrap.io'
  # MAIL_SMTP_PORT = 25
  # MAIL_SMTP_USER = ''
  # MAIL_SMTP_PASS = ''
  # MAIL_SMTP_AUTH = :cram_md5

  # MAIL_SENDER_NAME = 'Helpdesk'
  # MAIL_SENDER_EMAIL = 'nitin@nospam.org'
end
