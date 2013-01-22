#!/usr/bin/python

# ./troubleshooting_uploader.py --filename troubleshooting_data.tar.gz \
# --access_key your_access_key --secret_key your_secret_key --gateway objects.dreamhost.com

def main():
	import boto, boto.s3.connection, sys, getopt
	from boto.s3.key import Key
	from datetime import datetime
	from time import strftime, gmtime


	options, remainder = getopt.getopt(sys.argv[1:], '', ['filename=', 'access_key=', 'secret_key=', 'gateway='])

	timestamp = strftime("%Y-%m-%d_%H-%M-%S", gmtime())

	filename = ''
	access_key = ''
	secret_key = ''
	gateway = ''

	for opt, arg in options:
		if opt == '--filename':
			filename = arg
		elif opt == '--access_key':
			access_key = arg
		elif opt == '--secret_key':
			secret_key = arg
		elif opt == '--gateway':
			gateway = arg

	bucket_name = 'troubleshooting_data_'+timestamp
	print 'GATEWAY   :', gateway
	print 'BUCKET    :', bucket_name

	conn = boto.connect_s3 (
	    aws_access_key_id = access_key,
	    aws_secret_access_key = secret_key,
	    host = gateway,
	    calling_format = boto.s3.connection.OrdinaryCallingFormat(),
	)

	bucket = conn.create_bucket(bucket_name)
	bucket.set_canned_acl('private')

	print 'Uploading to %s/%s/%s' %(gateway, bucket_name, filename)
	k = bucket.new_key(filename)
	k.set_contents_from_filename(filename, cb=percent_cb, num_cb=10)
	print ''

	print 'Files found in bucket: '
	for key in bucket.list():
		key.set_canned_acl('public-read')
		print "File: %s" %(key.name)
		print 'http://%s/%s/%s' %(gateway, bucket_name, key.name)
		print ''

def percent_cb(complete, total):
	print('.'),

if __name__ == "__main__":
    main()