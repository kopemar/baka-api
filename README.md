# Bachelor Thesis Backend

A part of bachelor thesis Mobile app for human resource planning at FEE CTU in Prague. 
## Ruby version

2.7.1

## Dependencies

* Postgres
* Redis
* Ruby 2.7.1
* Ruby on Rails 

## Running the app

Obtaining `master.key` might be necessary.

```
docker-compose build && docker-compose up  
docker-compose run baka_api db:create
docker-compose run baka_api db:migrate
```

## Deployment

```
git push heroku master
```