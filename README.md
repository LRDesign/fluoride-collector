This is the collector part for fluoride: a tool to whiten the black boxes that Rails apps can become.

The idea here is:

0. Put the collector into an app.
0. Run the app in production (or staging)
0. Pull down the collected requests and responses for analysis.

Assuming that you're installing into your rails app deployed on Heroku:

Add 'fluoride-collector' to your Gemfile and bundle install.

== Saving collected exchanges

Fluoride-collector can save exchanges either to local file storage or to AWS S3. The latter is primarily useful for environments where local file storage is unavailable, like Heroku.  

=== Saving exchanges to local files

There shouldn't be anything to do but add fluoride-collector to your Gemfile and bundle.  Exchange files will get written to fluoride/request_recordings.  

=== Saving exchanges

You will need to set up an AWS S3 bucket. More info here: http://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html

In config/environment.rb, insert the following code:

<APPNAME>::Application.configure do
  aws_key, aws_secret = ENV.values_at("FLUORIDE_S3_KEY", "FLUORIDE_S3_SECRET")
  if aws_key.present? and aws_secret.present?
    config.fluoride.store_to = :s3
    config.fluoride.bucket = "your-bucket-name"
    config.fluoride.key_id = aws_key
    config.fluoride.access_secret = aws_secret
  end
end

Make sure to run this configuration code BEFORE you initialize your rails application.

Deploy to staging/production. Set environment variables "FLUORIDE_S3_KEY" and "FLUORIDE_S3_SECRET".

Use your application.

Check your S3 bucket. You should see a bunch of yml files with request information!

== Analysis

Analysis is performed by the [[Fluoride Analyzer](https://]


Several types of analysis are planned:

* Cloned coverage: set up a dev instance as a clone of the tested app, add coverage, replay requests.
* Request test generation: if I make this recorded request, do you reply like I expect?
* Response timing: how long do different requests take to process - where are our hotspots
* etc

(Currently, this is a private repo, since it's easier to go public than the reverse)
