# CTL CouldFront Utility

The sole purpose of this CFC is to create digitally signed CloudFront URLs so that you can grant time-based access to protected content served on Amazon CloudFront.

For more information about setting up CloudFront distributions for protected content, see the [Amazon CloudFront docs](http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PrivateContent.html). I also have a [blog post](http://www.iterateme.com/blog/) describing the setup in detail and it covers the basics of signing CloudFront URLs in ColdFusion.

### Requirements

This component relies on version 1.11.x (or later) of the [AWS Java SDK](https://aws.amazon.com/sdk-for-java/). It will not work with version 2 of the AWS Java SDK. Please review this blog post to find out [how to add the AWS Java SDK to your ColdFusion instance](https://brianklaas.net/aws/coldfusion/2018/12/10/Update-On-Using-AWS-Java-SDK-With-ColdFusion-2018.html).


#### Methods

There are two methods to this component:

**init()**

Required Arguments

* cloudFrontDomain = the domain name of your CloudFront distribution. Can be found in the CloudFront console.

* cloudFrontKeyPairID = the string ID of the CloudFront key pair you are going to use. Can be found in your account settings.

* privateKeyFilePath = the path to your private CloudFront key. Different than an EC2 key. Must be generated in your account settings. Store with heightened security.

**createSignedURL()**

Required Arguments

 * originFilePath = the path to and file name of the file on your origin server (usually the path to the object in a S3 bucket).

Optional Arguments

 * expiresOnDate = the date/time on which this signed URL expires. Defaults to 7 days from Now().
 * objectVersion = the integer value of the version number of this object. Only useful if you do object versioning rather than direct invalidation of an object in CloudFront.
 * isAttachment = boolean indicating if the file should be served as an attachment (download). Otherwise the file is served inline.
 * fileNameToUse = string value of the alternate file name to serve the file as. Only used if isAttachment is set to true.
 
#### No Unit Tests?

Note that I did not include tests for this component as it requires a valid CloudFront key pair to work in any scenario, and, alas, I won't be sharing mine with the world.
