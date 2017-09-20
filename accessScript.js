// Add any users you wish to have all the roles defined below here, also each one needs a corresponding email below
var adminIds = [
    $rallyid
];
var adminEmails = [
    $email
];
var roles = ["default.starship", "SuperAdmin"];

// add to roles
for (var i = 0; i < roles.length; i++) {
     print({"role": roles[i]}, {"$addToSet": {"users": {"$each": adminIds}}}.toString());
}

// create the adminUser objects
for (var j = 0; j < adminIds.length; j++) {
   print({"adminId": adminIds[j]},
        {$set: {
            "adminId": adminIds[j],
            "email": adminEmails[j]
        }},
        {upsert: true});
}
