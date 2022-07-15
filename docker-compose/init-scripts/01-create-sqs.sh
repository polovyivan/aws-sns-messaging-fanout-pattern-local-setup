#!/bin/bash
echo "########### Setting up localstack profile ###########"
aws configure set aws_access_key_id access_key --profile=localstack
aws configure set aws_secret_access_key secret_key --profile=localstack
aws configure set region us-east-1 --profile=localstack

echo "########### Setting default profile ###########"
export AWS_DEFAULT_PROFILE=localstack


echo "########### Setting Subscribers SQS names as env variables ###########"
export SQS_BRAZIL=sqs-brazil
export SQS_UKRAINE=sqs-ukraine
export SQS_LOGS=sqs-logs


echo "########### Creating Subscribers for BRAZIL  ###########"
aws --endpoint-url=http://localstack:4566 sqs create-queue --queue-name $SQS_BRAZIL

echo "########### ARN for BRAZIL ###########"
SQS_BRAZIL_ARN=$(aws --endpoint-url=http://localstack:4566 sqs get-queue-attributes\
                  --attribute-name QueueArn --queue-url=http://localhost:4566/000000000000/"$SQS_BRAZIL"\
                  |  sed 's/"QueueArn"/\n"QueueArn"/g' | grep '"QueueArn"' | awk -F '"QueueArn":' '{print $2}' | tr -d '"' | xargs)


echo "########### Creating Subscribers for UKRAINE  ###########"
aws --endpoint-url=http://localstack:4566 sqs create-queue --queue-name $SQS_UKRAINE

echo "########### ARN for UKRAINE ###########"
SQS_UKRAINE_ARN=$(aws --endpoint-url=http://localstack:4566 sqs get-queue-attributes\
                  --attribute-name QueueArn --queue-url=http://localhost:4566/000000000000/"$SQS_UKRAINE"\
                  |  sed 's/"QueueArn"/\n"QueueArn"/g' | grep '"QueueArn"' | awk -F '"QueueArn":' '{print $2}' | tr -d '"' | xargs)


echo "########### Creating Subscribers for LOGS  ###########"
aws --endpoint-url=http://localstack:4566 sqs create-queue --queue-name $SQS_LOGS


echo "########### ARN for LOGS ###########"
SQS_LOGS_ARN=$(aws --endpoint-url=http://localstack:4566 sqs get-queue-attributes\
                  --attribute-name QueueArn --queue-url=http://localhost:4566/000000000000/"$SQS_LOGS"\
                  |  sed 's/"QueueArn"/\n"QueueArn"/g' | grep '"QueueArn"' | awk -F '"QueueArn":' '{print $2}' | tr -d '"' | xargs)


echo "########### Creating SNS topic and getting arn  ###########"
SNS_ARN=$(aws --endpoint-url=http://localhost:4566 sns create-topic --name=global-mail |  sed 's/"TopicArn"/\n"TopicArn"/g' | grep '"TopicArn"' | awk -F '"TopicArn":' '{print $2}' | tr -d '"' | xargs)


echo "########### List SNS topics ###########"
aws --endpoint-url=http://localhost:4566 sns  list-topics --starting-token=0 --max-items=3


echo "########### Creating subscription for BRAZIL  ###########"
aws --endpoint-url=http://localhost:4566 \
 sns subscribe \
--topic-arn="$SNS_ARN" \
--protocol=sqs \
--notification-endpoint=http://localhost:4566/000000000000/"$SQS_BRAZIL" \
--return-subscription-arn


echo "########### Creating subscription for UKRAINE  ###########"
aws --endpoint-url=http://localhost:4566 \
 sns subscribe \
--topic-arn="$SNS_ARN" \
--protocol=sqs \
--notification-endpoint=http://localhost:4566/000000000000/"$SQS_UKRAINE" \
--return-subscription-arn


echo "########### Creating subscription for LOGS  ###########"
aws --endpoint-url=http://localhost:4566 \
 sns subscribe \
--topic-arn="$SNS_ARN" \
--protocol=sqs \
--notification-endpoint=http://localhost:4566/000000000000/"$SQS_LOGS" \
--return-subscription-arn


echo "########### List subscriptions  ###########"
aws --endpoint-url=http://localhost:4566\
 sns list-subscriptions

