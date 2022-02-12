[
    {
        "name": "${app_name}",
        "image": "${auth_image}",
        "essential": true,
        "secrets": [
            {"name": "MONGODB_URL", "valueFrom": "${mongodb_url}"},
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
                "containerPort": 4000,
                "hostPort": 8080
            }
        ]
    }
]
