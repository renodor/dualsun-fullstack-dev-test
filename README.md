# README

# Setup Development Environment
To setup server and client apps please refer to the README files of both folders.
Then launch client and server and visit client app at `http://localhost:5173/`

# Database Structure
I decided to split the "PVMES" data into different models:
- `Company`: storing company `name` and `siren`
- `Customer`: storing customer `name`, `email` and `telephone`
- `Installation`: storing installation `address`, `city` and `date`
- `Panel`: storing a `code` and a `flavor`

Each `Installation` record belongs to a `Company` and a `Customer`, and can have many panels.