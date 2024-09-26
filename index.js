import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";
import { SESClient, SendEmailCommand } from "@aws-sdk/client-ses";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";


const s3Client = new S3Client({

    region: "ap-south-1"

});

const sesClient = new SESClient({

    region: "ap-south-1"

});


const generatePresignedUrl = async (bucketName, fileName) => {

    try{

        const command = new GetObjectCommand({

            Bucket: bucketName,
            Key: fileName,

        });

        const signedUrl = await getSignedUrl(s3Client, command, { expiresIn: 3600 * 18 });

        return signedUrl;


    }
    catch(err){

        console.log("Error generating pre-signed url", err);
        return null;    

    }

}


const sendEmailWithLink = async (signedUrl) => {


    const command = new SendEmailCommand({
        Destination: {
            ToAddresses: ['anuj2002kumar@gmail.com'], 
        },
        Message: {
            Body: {
                Html: {
                    Data: `<p>Download the file using this link: <a href="${signedUrl}">Download File</a></p>`,
                },
            },
            Subject: { Data: 'AWS Resource Update' },
        },
        Source: 'anuj2002kumar@gmail.com', 
    });

    try{

        const response = await sesClient.send(command);

        console.log("Email sent successfully", response);

    }
    catch(err){

        console.log("Error sending email", err);

    }
    
}

export const handler = async (event) => {

    const bucketName = "my-script-bucket-anuj";
    const fileName = "resources.txt";

    const signedUrl = await generatePresignedUrl(bucketName, fileName);

    if(signedUrl){

        await sendEmailWithLink(signedUrl);
        return "success";

    }
    else{

        console.log("Failed to generate pre-signed url");

    }

}


