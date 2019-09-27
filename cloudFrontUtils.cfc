/*
CTL Cloud Front Utilities

This component is a utility for creating URLs for Amazon's CloudFront CDN and for digitally signing those URLs as needed.

This component requires that you have a copy of the aws-java-sdk-x.x.x.jar from the AWS SDK for Java in your coldfusion/lib/ directory.

Author: Brian Klaas (bklaas@jhu.edu)
Created: January 13, 2013
Major refactor: June 19, 2019
Copyright 2013, 2019 Brian Klaas

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

component output="false" hint="A utility for creating URLs for Amazon's CloudFront CDN and for digitally signing those URLs as needed" {

	/**
	*	@description Component initialization
	*	@requiredArguments
	*		- cloudFrontDomain = the domain name of your CloudFront distribution. Can be found in the CloudFront console.
	*		- cloudFrontKeyPairID = the string ID of the CloudFront key pair you are going to use. Can be found in your account settings.
	*		- privateKeyFilePath = the path to your private CloudFront key. Different than an EC2 key. Must be generated in your account settings. Store with heightened security.
	*/
	public any function init(required string cloudFrontDomain, required string cloudFrontKeyPairID, required string privateKeyFilePath) {
		variables.cloudFrontDomain = arguments.cloudFrontDomain;
		variables.cloudFrontKeyPairID = arguments.cloudFrontKeyPairID;
		variables.awsDateUtils = createObject("java", "com.amazonaws.util.DateUtils");
		variables.URLSigner = createObject("java", "com.amazonaws.services.cloudfront.CloudFrontUrlSigner");

		// Thanks to Leigh! How to read in a .pem private key and convert it into a correctly typed private key object for signing
		// https://stackoverflow.com/questions/40733190/using-coldfusion-to-sign-data-for-single-sign-on
		// However, we have to read in a .der file for this to work with CloudFront, but the core principles are the same
		// This page was also helpful in understanding what is needed: https://stackoverflow.com/questions/20119874/how-to-load-the-private-key-from-a-der-file-into-java-private-key-object
		var derContent = FileReadBinary(arguments.privateKeyFilePath);
		var keySpec = createObject("java", "java.security.spec.PKCS8EncodedKeySpec");
		var keyFactory = createObject("java", "java.security.KeyFactory").getInstance("RSA");
		variables.privateKey = keyFactory.generatePrivate(keySpec.init(derContent));

		return this;
	}


	/**
	*	@description Creates a signed URL to the specified object in CloudFront. Optionally takes an object version, expiration date, and content disposition values.
	*	@requiredArguments
	*		- originFilePath = the path to and file name of the file on your origin server (usually the path to the object in a S3 bucket).
	*	@optionalArguments
	*		- expiresOnDate = the date/time on which this signed URL expires. Defaults to 7 days from Now().
	*		- objectVersion = the integer value of the version number of this object. Only useful if you do object versioning rather than direct invalidation of an object in CloudFront.
	*		- isAttachment = boolean indicating if the file should be served as an attachment (download). Otherwise the file is served inline.
	*		- fileNameToUse = string value of the alternate file name to serve the file as. Only used if isAttachment is set to true.
	*		- mimeType - string value of the MIME type of the file
	*/
	public string function createSignedURL(required string originFilePath, date expiresOnDate = dateAdd("d",7,Now()), numeric objectVersion = 1, boolean isAttachment = false, string fileNameToUse = "", string mimeType = "") {
		var returnString = "";
		var cloudFrontObjURL = "https://" & variables.cloudFrontDomain & "/" & arguments.originFilePath;
		var queryStringFlagSet = 0;
		var thisMimeType = "";
		// The parseIso8601Date function expects a date/time string in Zulu (GMT) format -- ie; "2013-11-14T22:30:00.000Z"
		var amazonExpiresOnDate = variables.awsDateUtils.parseIso8601Date(formatDateInZuluTime(arguments.expiresOnDate));
		// If the object version or content-disposition parameters have been specified, include those in the signed URL
		if (arguments.objectVersion GT 1) {
			cloudFrontObjURL &= "?ver=" & arguments.objectVersion;
			queryStringFlagSet = 1;
		}
		if (arguments.isAttachment) {
			if (queryStringFlagSet) {
				cloudFrontObjURL &= "&";
			} else {
				cloudFrontObjURL &= "?";
				queryStringFlagSet = 1;
			}
			cloudFrontObjURL &= "response-content-disposition=attachment";
			if (len(trim(arguments.fileNameToUse))) {
				cloudFrontObjURL &= "%3Bfilename%3D" & arguments.fileNameToUse;
			}
		}
		if (len(trim(arguments.mimeType))) {
			switch(trim(arguments.mimeType)) {
				case "webm":
					thisMimeType = "video/webm";
					break;
				default:
			}
			if (len(thisMimeType)) {
				if (queryStringFlagSet) {
					cloudFrontObjURL &= "&";
				} else {
					cloudFrontObjURL &= "?";
				}
				cloudFrontObjURL &= "response-content-type=" & thisMimeType;
			}
		}

		return variables.URLSigner.getSignedURLWithCannedPolicy(cloudFrontObjURL,
                                                  variables.cloudFrontKeyPairID,
                                                  variables.privateKey,
                                                  amazonExpiresOnDate);
	}

	/**
	*	@description Takes a ColdFusion date/time string and formats it for AWS (Zulu/GMT time).
	* 	@sourceDate The ColdFusion date/time string we want to parse.
	*/
	private string function formatDateInZuluTime(required date sourceDate) {
		var utcDate = DateAdd("s", GetTimeZoneInfo().utcTotalOffset, arguments.sourceDate);
		return DateFormat(utcDate, "yyyy-mm-dd") & "T" & TimeFormat(utcDate, "HH:mm:ss.000Z");
	}

}
