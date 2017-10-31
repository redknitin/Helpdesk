#
# NOTES
#
# Use rackup and pass command-line parameters for host, port, server instead of set :bind and set :port - see runme.bat for an example

class AppConfig
  MASTER_ROLES = ['requester', 'helpdesk', 'admin']
  MASTER_STATUSES = ['New', 'In Progress', 'Suspended', 'Completed', 'Cancelled']

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
