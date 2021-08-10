# Typescript, Express and React

This repository holds a barebones Typescript + Express + React app.

## Backend commands
Run these commands from the root folder.
- `yarn` installs all dependencies for server
- `yarn run start` Starts the backend development server.
- `yarn run build` Builds the backend app to the `build` directory.


## Frontend commands
Run these commands from the `frontend` folder.
- `yarn` installs all dependencies for frontend
- `yarn run start` Starts the frontend development server.
- `yarn run build` Builds the frontend app to the `build/frontend` directory.

## Assumptions for Jenkins file
The job is running on a server that already has access to aws with cli installed and access keys are configured.

From the jenkins job we must pass the required variables: 
AWS specific variables: 
AWS_REGION, IMAGE_VERSION, DOCKER_REGISTRY, DOCKER_TAG, ECS_CLUSTER, ECS_SERVICE, TASK_FAMILY
GIT_REPO: Specify the repo where are app files lie to clone from
CREDENTIALS: The credentials of the git repo confugured in credential manager of jenkins.
BRANCH: Specify the branch where the code lies.
RECIPIENT_LIST : Send a list of email ids that should be informed of the job status.
ENV: We can pass the environment variable like prod,uat, dev etc
