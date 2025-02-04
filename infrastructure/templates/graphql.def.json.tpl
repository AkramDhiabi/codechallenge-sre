[
    {
        "name": "${app_name}",
        "image": "${graphql_image}",
        "essential": true,
        "environment": [
            {"name": "BOOKING_SERVICE_URI", "value": "${booking_uri}"},
            {"name": "AUTH_SERVICE_URI", "value": "${auth_uri}"}
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${log_group_name}",
                "awslogs-region": "${log_group_region}",
                "awslogs-stream-prefix": "${app_name}"
            }
        },
        "portMappings": [ 
            {
                "containerPort": 3000,
                "hostPort": 3000
            }
        ]
    }
]
