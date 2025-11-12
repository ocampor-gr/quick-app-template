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
eb create docker-compose-tutorial
```

## Test Application

```
eb open
```

## Update environment

Tip: Make sure the change is commited or it will deploy the latest
committed version.

```
eb deploy
```

## Clean Up

```
eb terminate
```