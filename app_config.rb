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
end