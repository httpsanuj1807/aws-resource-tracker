# AWS Resource Tracker

## Description

The **AWS Resource Tracker** is a shell script that helps you manage and track your AWS resources efficiently. It generates a report of all your AWS resources, including S3 buckets and EC2 instances, and uploads this report to an S3 bucket. Additionally, it triggers an AWS Lambda function to send a notification with a signed URL to access the report via email.

## Features

- Lists all S3 buckets and their contents.
- Lists all EC2 instances with details.
- Uploads the generated report to an S3 bucket.
- Sends an email notification with a link to the report using AWS SES.

## Prerequisites

- AWS CLI installed and configured on your machine.
- AWS IAM permissions to access S3, EC2, Lambda, and SES services.

## Installation

1. Clone the repository to your local machine:
   git clone <repository-url>

2. Navigate to the project directory:
   cd <project-directory>

3. Make the script executable:
   chmod +x track-aws-resources.sh

## Configuration

1. Open the script file (`track-aws-resources.sh`) and set the following variables:
   - `S3_BUCKET`: Your S3 bucket name where the report will be uploaded.
   - `LAMBDA_FUNCTION_NAME`: The name of your AWS Lambda function.

## Usage

Run the script manually:
bash track-aws-resources.sh

## Scheduling with Cron

To run this script automatically at a specific time every day, add a cron job:

1. Open the crontab editor:
   crontab -e

2. Add the following line to schedule the script to run daily at 11:00 PM:
   0 23 * * * /path/to/your/track-aws-resources.sh >> /path/to/your/cron_output.log 2>&1

## Notes

- Ensure that your AWS CLI is configured with the correct credentials and region.
- Check the `cron_output.log` file for any execution details or errors.