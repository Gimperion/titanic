#! /bin/sh

su postgres 

psql -c "CREATE DATABASE titanic WITH ENCODING 'UTF8';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE titanic to gimperion;"

## Create db stuff here ## 
psql -c ""