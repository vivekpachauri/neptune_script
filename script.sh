#!/bin/bash
#echo 'calling authn to create a new account'
#curl -X POST -H "Content-Type: application/json" -d '{"email" : "initial1@init.com","password" : "P@ssw0rd","confirmPassword" : "P@ssw0rd","username" : "initial","acceptedHipaa": true,"acceptedToS": true}' https://accounts.icanhazevolutions.rally-dev.plumbing/auth/v1/register -k -v
echo 'calling psql to get id'
psql -h postgres-rds-icanhazevolutions.cpirb098hibl.us-east-1.rds.amazonaws.com --username=authn -f input.sql -o output.txt
echo
echo 'extracting the id from output'
rallyid=$(grep -E -o [a-z0-9]+-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+ output.txt)
echo "found rally id $rallyid"
echo
echo "updating role for user $rallyid"
echo "passing the following query to psql"
echo "update accounts set role='superuser' where id='$rallyid';" | psql -h postgres-rds-icanhazevolutions.cpirb098hibl.us-east-1.rds.amazonaws.com --username=authn
echo
echo "updating starship database to add this rallyid"
echo "-----------------"
email="initial1@init.com"
echo "calling external script"
source vars.sh $rallyid $email > jsonScript.json
source rest.sh >> jsonScript.json
#echo "var adminIds = [$1];var adminEmails = [$2];"
#echo 'var roles = ["default.starship", "SuperAdmin"];for (var i = 0; i < roles.length; i++) {     print({"role": roles[i]}, {"$addToSet": {"users": {"$each": adminIds}}}.toString());}for (var j = 0; j < adminIds.length; j++) {   print({"adminId": adminIds[j]},        {$set: {            "adminId": adminIds[j],            "email": adminEmails[j]        }},        {upsert: true});}'
cat jsonScript.json
#psql -h postgres-rds-icanhazevolutions.cpirb098hibl.us-east-1.rds.amazonaws.com --username=authn starship jsonScript.json
echo
echo "resetting role to user before ending the script"
echo "update accounts set role='user' where id='$rallyid';" | psql -h postgres-rds-icanhazevolutions.cpirb098hibl.us-east-1.rds.amazonaws.com --username=authn
echo "printing value of rally id before end of script"
echo "rally id is $rallyid"
mongo mongo.icanhazevolutions.rally-dev.plumbing:27017/starship -u starship -p SOh3TbYhyuLiW8ypJPxmt2oOfL jsonScript.json
#psql -h postgres-rds-icanhazevolutions.cpirb098hibl.us-east-1.rds.amazonaws.com/starship --username=authn starship jsonScript.json
rm jsonScript.json
