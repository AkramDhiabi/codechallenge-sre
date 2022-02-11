db.createUser(
    {
        user: "superb",
        pwd: "superb",
        roles:[
            {
                role: "readWrite",
                db:   "superb"
            }
        ]
    }
);