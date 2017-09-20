#!/bin/bash
echo "==================================================="
echo "starting script to create a seed admin user in authn and starship"
echo 'calling authn to create a new account'
email="initial2@init.com"
curl -X POST -H "Content-Type: application/json" -d '{"email" : "initial2@init.com","password" : "P@ssw0rd","confirmPassword" : "P@ssw0rd","username" : "initial2","acceptedHipaa": true,"acceptedToS": true}' https://accounts.icanhazevolutions.rally-dev.plumbing/auth/v1/register -k -v
echo "authn call finished"
echo "---------------------------------------------------"
echo
echo 'calling psql to get id'
psql -h postgres-rds-icanhazevolutions.cpirb098hibl.us-east-1.rds.amazonaws.com --username=authn -f input.sql -o output.txt
echo
echo 'extracting the id from output'
rallyid=$(grep -E -o [a-z0-9]+-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+ output.txt)
echo "found rally id $rallyid"
echo "---------------------------------------------------"
echo
echo "updating role for user $rallyid"
echo "passing the following query to psql"
echo "update accounts set role='superuser' where id='$rallyid';" | psql -h postgres-rds-icanhazevolutions.cpirb098hibl.us-east-1.rds.amazonaws.com --username=authn
echo "psql call complete"
echo "---------------------------------------------------"
echo
echo "updating starship database to add this rallyid"
echo "generating json command with this rally id and email"
source vars.sh $rallyid $email > jsonScript.json
source rest.sh >> jsonScript.json
echo "json command generated"
cat jsonScript.json
echo "calling mongo with this script"
mongo mongo.icanhazevolutions.rally-dev.plumbing:27017/starship -u starship -p SOh3TbYhyuLiW8ypJPxmt2oOfL jsonScript.json
echo "mongo updated"
echo "---------------------------------------------------"
echo
echo "resetting role to user before ending the script"
echo "NOTE - this step is to be done during development only"
echo "once the script is ready this step should be removed"
echo "update accounts set role='user' where id='$rallyid';" | psql -h postgres-rds-icanhazevolutions.cpirb098hibl.us-east-1.rds.amazonaws.com --username=authn
echo "removing the generated script file"
rm jsonScript.json
echo "script complete"
echo "==================================================="
