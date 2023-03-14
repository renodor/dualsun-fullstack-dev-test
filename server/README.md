# README

# Stack
* Ruby version :  2.7.0p0
* Rails version : 6.1.4.1
* [simplecov](https://github.com/simplecov-ruby/simplecov) as test coverage
* [dotenv](https://github.com/bkeepers/dotenv) as environment variable loader
# Setup Development Environment
Create Database and run migrations :
```
rails db:create
rails db:migrate
```

Install dependencies :
```
bundle install
```

Run development server :
```
rails s
```
# Testing
Run tests with Rspec:
```
bundle exec rspec
```
