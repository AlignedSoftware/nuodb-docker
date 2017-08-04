#!/bin/bash
set -x

#create database
/opt/nuodb/bin/nuodbmgr --broker $PEER_ADDRESS --password $DOMAIN_PASSWORD \
        --command "create database dbname ${DB_NAME} template 'Multi Host' dbaUser ${DB_USER} dbaPassword ${DB_PASSWORD} tagConstraints:SMs 'SM_OK ex:' tagConstraints:TEs 'TE_OK ex:'"

#create database schema
/opt/nuodb/bin/nuosql $DB_NAME@$PEER_ADDRESS --user $DB_USER --password $DB_PASSWORD --schema STOREFRONT --file /dbSchema/schema.sql

#load data into db
/opt/nuodb/bin/nuodb-migrator load \
        --target.url=jdbc:com.nuodb://$PEER_ADDRESS/$DB_NAME \
        --target.schema=STOREFRONT \
        --target.username=$DB_USER \
        --target.password=$DB_PASSWORD \
        --input.path=/dbSchema