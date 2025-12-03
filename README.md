## Create Project

To create a new project run the following command and follow the instructions.

1. Install Cruft.

```
pip install cruft
```

2. Create a new project.

```
cruft create https://github.com/ocampor-gr/quick-app-template
```

3. [Optional] Install Elastic Beanstalk CLI

```
pip install awscli awsebcli --upgrade
```

4. [Optional] Add the environment URL to Google Ath  authorized URLs in Google Console. 
If you don't know how to do it ask #engineering for help. You can do it [here](https://console.cloud.google.com/auth/clients)

5. [Optional] Make sure that GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET environment variables
are configured in Github Secrets. If you don't know how to do it ask #engineering for help.

## Update Project from Template

```
cruft update
```
