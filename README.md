# jenkins-terraform
Simple repo that spins up an ec2 instance using jenkins, terraform and a github webhook.

# local jenkins instance
1. Make sure docker instance is running locally
2. Open browser to http://localhost:8080/

# ngrok
Point ngrok to local Jenkins instance
`ngrok http 8080 --url https://reactive-gyration-calibrate.ngrok-free.dev`

# github
Define a webhook with 
Payload URL: https://reactive-gyration-calibrate.ngrok-free.dev/github-webhook/
Content type: application/json