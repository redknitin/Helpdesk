class Helpdesk < Sinatra::Base
  #Initialize data needed for the application
  def initialize()
    super()

    @datetimefmt = '%Y-%m-%d %H:%M:%S %z'
    @db = Mongo::Client.new((defined? AppConfig::DB_URL != nil) ? AppConfig::DB_URL : 'mongodb://127.0.0.1:27017/helpdesk')
    @departments = (defined? AppConfig::MASTER_ORG_DEPT != nil) ? AppConfig::MASTER_ORG_DEPT : [
        {:org => 'Helpdesk Foundation', :dept => ['Software Development', 'Quality Control', 'Social Media Marketing', 'Training', 'Consulting', 'Administration', 'Human Resources', 'Procurement', 'Information Technology']},
        {:org => 'Mars Habitation Corporation', :dept => ['HVAC', 'MEP (Mechanical-Electrical-Plumbing)', 'QHSE (Quality-Health-Safety-Environment)', 'Cleaning', 'Security', 'Visitor Experience', 'Guest Relations', 'Procurement']}
    ]
    @floors = (defined? AppConfig::MASTER_BLDG_FLOOR != nil) ? AppConfig::MASTER_BLDG_FLOOR : [
        {:building => 'Building A', :floors => ['Roof Top', '2nd Floor (2)', '1st Floor (1)', 'Ground Floor (0)', 'Lower Ground (B1/-1)', 'Basement 1 (B2/-2)', 'Basement 2 (B3/-3)']},
        {:building => 'Building B', :floors => ['2nd Floor (2)', '1st Floor (1)', 'Ground Floor (0)', 'Lower Ground (B1/-1)', 'Basement 1 (B2/-2)']}
    ]
    @pagesize = (defined? AppConfig::UI_PAGE_SIZE != nil) ? AppConfig::UI_PAGE_SIZE : 10
    @roles = (defined? AppConfig::MASTER_ROLES != nil) ? AppConfig::MASTER_ROLES : ['requester', 'helpdesk', 'admin']
    @statuses = (defined? AppConfig::MASTER_STATUSES != nil) ? AppConfig::MASTER_STATUSES : ['New', 'Assigned', 'Suspended', 'Completed', 'Cancelled']

    @email_settings = {
        :smtp_host => (defined? AppConfig::MAIL_SMTP_HOST != nil) ? AppConfig::MAIL_SMTP_HOST : '127.0.0.1',
        :smtp_port => (defined? AppConfig::MAIL_SMTP_PORT != nil) ? AppConfig::MAIL_SMTP_PORT : 25,
        :smtp_user => (defined? AppConfig::MAIL_SMTP_USER != nil) ? AppConfig::MAIL_SMTP_USER : nil,
        :smtp_pass => (defined? AppConfig::MAIL_SMTP_PASS != nil) ? AppConfig::MAIL_SMTP_PASS : nil,
        :smtp_auth => (defined? AppConfig::MAIL_SMTP_AUTH != nil) ? AppConfig::MAIL_SMTP_AUTH : :plain,
    }

    @locstruct = (defined? AppConfig::MASTER_LOC_STRUCT != nil) ? AppConfig::MASTER_LOC_STRUCT : nil
    @uploaddir = (defined? AppConfig::UPLOAD_DIR != nil) ? AppConfig::UPLOAD_DIR : 'public/uploads'
  end
end