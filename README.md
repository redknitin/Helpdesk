# Helpdesk

Helpdesk web application built with Ruby, Sinatra, MongoDB, Bootstrap and jQuery

## Screenshots

### Home Screen

![Home Screen](https://raw.githubusercontent.com/redknitin/Helpdesk/master/docs/img/scr-home-01.png)

The home screen contains shortcuts to common functions and would be the landing page for all users, both logged in and unauthenticated. The shortcuts would differ based on the role of the user logging in.

### Tickets List

![Tickets List](https://raw.githubusercontent.com/redknitin/Helpdesk/master/docs/img/scr-ticketlist-01.png)

The tickets list screen displays all of the helpdesk tickets that were raised; filters can be applied to view specific tickets. Clicking on the ticket ID opens that ticket.

### Ticket Comments

![Ticket Comments](https://raw.githubusercontent.com/redknitin/Helpdesk/master/docs/img/scr-ticketcomments-01.png)

The ticket comments feature enables users to discuss about a specific ticket.

### Contacts Filter

![Contacts Filter](https://raw.githubusercontent.com/redknitin/Helpdesk/master/docs/img/scr-contactfilter-01.png)

The list view pages have filters to enable users to search by values from one or more columns.


## Getting Started

### Option 1

Install Oracle Virtual Box 5.1, install Vagrant, clone the Git repo, run "vagrant up", and go to http://localhost:8000

### Option 2

Get a local install of MongoDB.

Then, install Ruby and Bundler, and run a "bundle install", followed by running app.rb with the Ruby interpreter.

### Notes

The default username is "admin" and the default password is "admin".

Instructions here will get you a copy of the project up and running on your local machine for development and testing purposes. Deployment notes will explain how to deploy the project on a live system.

### Prerequisites

If you are on Debian or Ubuntu Linux, look at bootstrap.sh - it will get you setup in a jiffy (it's used for shell provisioning with Vagrant and the Ubuntu box image).


### Installing

Example 1: Running with Vagrant

```
git clone https://github.com/redknitin/Helpdesk.git
vagrant up
```

The default scripts will get the application running on port 8000 ( http://localhost:8000 )

## Running the tests

TODO: Explain how to run the automated tests for this system

### Break down into end to end tests

TODO: Explain what these tests test and why

```
TODO: Example
```

### TODO: And coding style tests

TODO: Explain what these tests test and why

```
TODO: Example
```

## Deployment

TODO: Add additional notes about how to deploy this on a live system

## Built With

* [Sinatra](https://github.com/sinatra/sinatra) - Web microframework
* [Bundler](https://bundler.io/) - Dependency Management
* [Ruby](https://github.com/ruby/ruby) - Scripting language
* [MongoDB](https://www.mongodb.com/) - Database
* [jQuery](https://jquery.com/) - Javascript library

## Contributing

Please read [CONTRIBUTING.md](https://github.com/redknitin/Helpdesk/blob/master/CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/redknitin/Helpdesk/tags). 

## Contributors

The following individuals contributed code to this project:

* [Kevin Smith](https://github.com/kvsm)
* Nitin Reddy
* _When we accept your pull request or patch, your name will appear here_

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* TODO: Hat tip to anyone whose code was not directly used in this project
* TODO: Inspiration
