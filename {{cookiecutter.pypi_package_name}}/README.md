source: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/docker-compose-quickstart.html

## Install

```
pip install awsebcli --upgrade
```

## Create an EB application

1. Create EB configuration
```
eb init -p docker docker-compose-tutorial --region us-east-2
```

2. Create EC2 SSH key

```
eb init
```

## Create environment

```
eb create {{cookiecutter.environment}}
```

## Test Application

```
eb open
```

## Update environment

Tip: Make sure the change is committed, or it will deploy the latest
committed version.

```
eb deploy
```

## Clean Up

```
eb terminate
```

## Generate AUTH_SECRET

```
openssl rand -base64 32
```

## Generate Google Auth Credentials

If you are getting the error:

```
Access blocked: This app’s request is invalid
```

Make sure you added the prod URL in authorized redirect URIs in Google Console. For example:

```
http://prod.eba-7it7jwzi.us-east-2.elasticbeanstalk.com/api/auth/callback/google
```

Also, if after the re-direct you get a not found. Make sure the proxy isn't overwriting the correct
route. To fix this issue, the backend is redirected to /api/v1.