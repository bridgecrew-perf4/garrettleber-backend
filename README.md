# garrettleber.com - Backend
This repo holds the backend code for my personal website, created as part of the cloud resume challenge located at https://cloudresumechallenge.dev

In order to use the included pre-commit hook, run the following command to create a symbolic link
```
ln -s pre-commit.sh .git/hooks/pre-commit
```

I chose to use terraform because I already have a slight familiarity with the tool.

This uses the packaged Python lambda function included in the src/ and package/ dirs, spins it up in AWS and configures the proper role to give it the permissions it needs. It then creates the REST API used by the function, and spits that out as output to be used in the frontend. At the end it creates the necessary DynamoDB table that stores the data for the visitor counter.