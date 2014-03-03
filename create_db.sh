#! /bin/sh

su postgres 

psql -c "CREATE DATABASE titanic WITH ENCODING 'UTF8';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE titanic to gimperion;"

## Create db stuff here ## 
psql -d titanic -c "CREATE TABLE titanic_test (
    passenter_id int NOT NULL primary key,
    passenger_class int,
    name varchar(255),
    gender varchar(7),
    age float4,
    sibsp int,
    parch int,
    ticket varchar(25),
    fare float4,
    cabin varchar(20),
    embarked varchar(4)
)"

psql -d titanic -c "CREATE TABLE titanic_train (
    passenter_id int NOT NULL primary key,
    survived int,
    passenger_class int,
    name varchar(255),
    gender varchar(7),
    age float4,
    sibsp int,
    parch int,
    ticket varchar(25),
    fare float4,
    cabin varchar(20),
    embarked varchar(4)
)"

psql -d titanic -c "\COPY titanic_train 
    FROM './data/train.csv' 
    WITH DELIMITER ',' 
    CSV HEADER;"

psql -d titanic -c "\COPY titanic_test 
    FROM './data/test.csv' 
    WITH DELIMITER ',' 
    CSV HEADER;"
