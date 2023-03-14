# README

# Setup Development Environment
To setup server and client apps please refer to the README files of both folders.
Then launch client and server and visit client app at `http://localhost:5173/`

# Database Structure
I decided to split "PVMES" data into different models:
- `Company`: storing company `name` and `siren`
- `Customer`: storing customer `name`, `email` and `phone`
- `Installation`: storing installation `address`, `city` and `date`
- `Panel`: storing a `code` and a `flavor`

Each `Installation` record belongs to a `Company` and a `Customer`, and can have many panels.

## About Company
Company `siren` need to be a 4 digits number. (In the real world SIREN are supposed to be 9 digits number, but I decided to simplify it for the sake of the exercise). Also I was unsure if `siren` are actually "numerical" or not. I decided that yes, which means that SIREN like `0001` are not valid.

## About Installation
In the real world an address will need more informations than just `address` and `city` attribute (things like `address2`, `country`, `zipcode` etc...), but for the sake of the exercise I decided that `address` and `city` was good enough.

## About Panel
I replaced panel "id" by `code` and "type" (photovoltaic/hybrid) by `flavor` because "id" and "type" are reserved keywords in Rails and I wanted to avoid confusion. Also I was unsure if panel `code` are actually "numerical" or not. I decided that yes, which means that code like `000001` are not valid.

## About data validation
I thought it was better to validate data on one unique place, so I didn't use HTML5 validation or front end validation at all. All data validation is done server side directly by ActiveRecord. If there are validation errors when trying to persist data, those errors will be sent back to the client to be displayed.

Generally speaking I didn't know how "unique" some data should be:
- Does a panel `code` represent a unique panel object (Like a barcode)? Or can we have different panel objects with the same `code` ?
- Is a customer unique by company? Or can different companies have the same customer?
- Can different customers have the same `phone` but different emails?
- Can we have different Installation at the same date at the same address but with different panels?
etc...

I decided not to worry much about those questions but in order to limit validation issues I decided to split the "PVMES" form in 4 different steps:
1. First users need to define the company
2. Then users need to define the customer
3. Then users need to define the installation details
4. And finaly users need to add panels to this new installation

This allows to validate mandatory data before actually receiving panels informations and make sure we create installation record for the correct company and customer. This also allows to have a better UX with a simpler form than you validate step by step (instead of having one big form with lot of inputs that can all have different type of errors).

Finally you will see that different controllers have `find_or_create` methods instead of simple `show` or `create`. This is a bit weird and can lead to un-wanted record creation, but again I didn't really know if at the moment of filling "PVMES" form, corresponding companies or customers are already in our database or not? I guess that this solution is good enough for the sake of the exercise.