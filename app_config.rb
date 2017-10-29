#
# NOTES
#
# Use rackup and pass command-line parameters for host, port, server instead of set :bind and set :port - see runme.bat for an example

class AppConfig
  #
  # Database settings
  #
  DB_URL = 'mongodb://127.0.0.1:27017/helpdesk'  #mongodb://user:password@127.0.0.1:27017/helpdesk

  #
  # Master data for the application
  #
  MASTER_BLDG_FLOOR = [
    {:building => 'Building 01', :floors => ['Roof Top', '2nd Floor (2)', '1st Floor (1)', 'Ground Floor (0)', 'Lower Ground (B1/-1)', 'Basement 1 (B2/-2)', 'Basement 2 (B3/-3)']},
    {:building => 'Building 02', :floors => ['2nd Floor (2)', '1st Floor (1)', 'Ground Floor (0)', 'Lower Ground (B1/-1)', 'Basement 1 (B2/-2)']}
  ]
  MASTER_ORG_DEPT = [
    {:org => 'Apache Foundation', :dept => ['Software Development', 'Quality Control']},
    {:org => 'Canonical', :dept => ['System Administration', 'Marketing']}
  ]
  MASTER_ROLES = ['requester', 'helpdesk', 'admin']
  MASTER_STATUSES = ['New', 'Assigned', 'Suspended', 'Completed', 'Cancelled']

  #
  # UI settings
  #
  UI_PAGE_SIZE = 10
  #UI_LOGO_URL = '/logo.png'
  #UI_LOGO_ALT_TEXT = ''
  #UI_MENU_MODULES = ['Reactive Management', 'Preventive Management', 'Inventory', 'Procurement', 'Personnel']

  if File.exists?('app_config.env.rb')
    require_relative 'app_config.env' 
  else
    require_relative 'app_config.defaults'
  end
end
