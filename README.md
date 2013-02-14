#CTL CouldFront Utility

The sole purpose of this CFC is to create digitally signed CloudFront URLs so that you can grant time-based access to protected content served on Amazon CloudFront.

For more information about setting up CloudFront distributions for protected content, see the [Amazon CloudFront docs](http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PrivateContent.html). I also have a [blog post](http://www.iterateme.com/blog/) describing the setup in detail and it covers the basics of signing CloudFront URLs in ColdFusion.

### Requirements

This component requires that you have a copy of the aws-java-sdk-x.x.x.jar from the [AWS SDK for Java](http://aws.amazon.com/sdkforjava/) in your coldfusion/lib/ directory. Alternatively, you can load this into your application using the new [.jar loading features of ColdFusion 10](http://help.adobe.com/en_US/ColdFusion/10.0/Developing/WSe61e35da8d318518-106e125d1353e804331-7ffe.html), or you can use Mark Mandel's excellent [JavaLoader](http://www.compoundtheory.com/?action=javaloader.index) utility if you are on ColdFusion 9.

This component will not work with ColdFusion 8 or earlier as it requires the JetSet S3/CloudFront utilities .jar which is bundled with Adobe ColdFusion 9.0.1 and later.

#### Methods

There are two methods to this component:

**init()**

Required Arguments

* awsAccessKey = the access key value of an Amazon IAM account associated with the same account as your CloudFront key pair.

* awsSecretKey = the secret key value of an Amazon IAM account associated with the same account as your CloudFront key pair.

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

#### ToDo

I should add in an option to utilize a custom Amazon policy for the specific URL, but since we don't have need for custom policies, I didn't bother to build this in.
 
#### No Unit Tests?

Note that I did not include tests for this component as it requires a valid set of AWS IAM credentials and a valid CloudFront key pair to work in any scenario, and, alas, I won't be sharing mine with the world.