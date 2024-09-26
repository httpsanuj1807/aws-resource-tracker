#!/bin/bash

###############################################################################################
#
# Author     : Anuj Kumar
# Date       : 26 Sept 2024
# version    : v1
#
# This script does the following taks :
# Firstly generate a resources.txt file based on available resources in your account
# only works for (IAM users, S3 buckets, EC2 instances, Lambda functions)
# Next, it store that file in s3 bucket
# Then using lambda function, file signed url is generated
# Using lambda function that link is sent to owner using aws ses service
#
###############################################################################################


set -e  # for terminating script if any error occurs

# declarring variables

FILENAME="resources.txt"                    # file to store resources
S3_BUCKET="my-script-bucket-anuj"           # bucket to upload file after generation
LAMBDA_FUNCTION_NAME="send-email-function"  # lambda function name



# Adding additional details

# Date and Time to add in resource file
echo -e "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')\n\n" > $FILENAME


echo -e "S3 buckets details" >> $FILENAME
# above line uses redirection operation which will delete the previous
# content of resources file if exists else creates new one
# redirection (>) doesnt append, it clear file and write


# fetching all buckets name
buckets=$(aws s3 ls | awk '{print$3}')

# we will get buckets like
# my-personals3-bucket
# uca-project-images
# we can loop on it and then can print recursively

for bucket in $buckets
do

        echo -e "\nBucket name: ${bucket}\n-----------------------------------" >> $FILENAME
        # now printing content of buckets

        aws s3 ls s3://$bucket/ --recursive | awk '{print $1, $2, $3, $4, $5}' | sort -V -k 4 | column -t >> $FILENAME

        echo -e "\n" >> $FILENAME

done


# sort -k 4 will sort according to column 4 but in lexi order
# product10.jpeg
# product2.jpeg


# sort -V -k 4 will sort 4th column in natural sortinig
# product2.jpeg
# product10.jpeg


# -e with echo allows us to use \n, \t like escape sequences

# List EC2 instances

echo -e "\n\nEC2 instances details\n----------------------------------------" >> $FILENAME
aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | "\(.InstanceId)\t\(.Tags[] | select(.Key == "Name") | .Value // "N/A")\t\(.Placement.AvailabilityZone)\t\(.State.Name)\t\(.PublicIpAddress // "N/A")" ' | column -t -s $'\t'  >> $FILENAME

# jq -r is used to parse json data
# The -r option in jq is used to output raw strings instead of JSON-encoded
# strings. When you use jq without the -r flag, it formats the output as
# valid JSON, which includes additional quotes around strings and escape
# sequences for special characters. Using -r provides a cleaner output
# that is more suitable for direct usage in shell scripts or when you want plain text.

# column -t -s for output data in tabular form

#Lambda function
echo -e "\n\nAvailable Lambda function\n----------------------------------------" >> $FILENAME

aws lambda list-functions | jq -r '.Functions[].FunctionName' >> $FILENAME

# List IAM users

echo -e "\n\nIAM users list\n----------------------------------------" >> $FILENAME
aws iam list-users | jq -r  '.Users[].UserName' >> $FILENAME


# empty bucket before uploading new one
aws s3 rm s3://$S3_BUCKET --recursive


# upload file to aws s3 bucket
aws s3 cp $FILENAME s3://$S3_BUCKET --content-disposition "attachment; filename=\"$FILENAME\""

# "attachment; filename=\"$FILENAME\"" is used to download file with same name
# as it was uploaded to s3 bucket  else it will be downloaded with random name
# like 2024-09-26T12:00:00Z or something like that which is not user friendly
# so we are using this to download file with same name as it was uploaded

aws lambda invoke --function-name $LAMBDA_FUNCTION_NAME response.json

# response.json will contain the output of lambda function

rm response.json

echo "Script execution success!"