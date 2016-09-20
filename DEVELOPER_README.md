Docker image to provision a cluster
===================================

Building
--------

```bash
# Build the image
docker build -t coco/coco-pub-provisioner .
```


Set all the required variables
------------------------------

```bash
## You can also find all the setup stored in LastPass
## For PROD cluster
## LastPass: Publishing cluster provisioning setup
## For TEST cluster
## LastPass: TEST Publishing cluster provisioning setup

## Get a new etcd token for a new cluster, 3 refers to the number of initial boxes in the cluster:
## `curl https://discovery.etcd.io/new?size=3`
export TOKEN_URL=`curl -s https://discovery.etcd.io/new?size=3`

## Secret used during provision to decrypt keys - stored in LastPass.
## Lastpass: coco-provisioner-ansible-vault-pass
export VAULT_PASS=

## AWS API keys for provisioning (not for use by services) - stored in LastPass.
## Lastpass: infraprod-coco-aws-provisioning-keys
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=

## Base uri where your unit definition file and service files are expected to be.
export SERVICES_DEFINITION_ROOT_URI=https://raw.githubusercontent.com/Financial-Times/pub-service-files/master/

## make a unique identifier (this will be used for DNS tunnel, splunk, AWS tags)
export ENVIRONMENT_TAG=

## Set the FT environment type
## For PROD: p
## For TEST: t
export ENVIRONMENT_TYPE=

## Comma separated username:password which will be used to authenticate(Basic auth) when connecting to the cluster over https.
## See Lastpass: 'CoCo Basic Auth' for current cluster values.
export CLUSTER_BASIC_HTTP_CREDENTIALS=

## Gateway content api hostname (not URL) to access UPP content that the cluster read endpoints (e.g. CPR & CPR-preview) are mapped to. 
## Defaults to Prod if left blank.
## Prod: api.ft.com
## Pre-Prod: test.api.ft.com
export API_HOST=

# Unused here, but useful in decomissioning.
export AWS_DEFAULT_REGION=eu-west-1

# The following variable specifies URLs for read access to the delivery clusters, which are required by publishing monitoring services.
# The value should be specified by the following syntax: <env-tag1>:<delivery-cluster-url1>,<env-tag2>:<delivery-cluster-url2>,...,<env-tagN>:<delivery-cluster-urlN>
export DELIVERY_CLUSTERS_URLS='prod-uk:https://prod-uk.site.com/,prod-us:https://prod-uk.site.com/'

# The following variable specifies HTTP credentials to communicate to delivery clusters.
# The value should be specified by the following syntax: <env-tag1>:<username1>:<password1>,<env-tag2>:<username2>:<password2>,...,<env-tagN>:<usernameN>:<passwordN>
export DELIVERY_CLUSTERS_HTTP_CREDENTIAL='prod-uk:user1:passwd1,prod-us:user2:passwd2'

# For publishing videos, the brightcove-notifier and brightcove-metadata-preprocessor must connect to the Brightcove API with an id like this: 47628783001
export BRIGHTCOVE_ACCOUNT_ID=

# You could find the keys in LastPass under the name: Brightcove
# Make sure to surround value in quotes " "
export BRIGHTCOVE_AUTH=

##URLs to Bertha endpoints for accessing to specific Google Spreadsheet data. Used in publishing cluster
##AUTHORS_BERTHA_URL refers to the spreadsheet of curated authors data.
##ROLES_BERTHA_URL refers to the spreadsheet of roles for curated authors.
##MAPPINGS_BERTHA_URL refers to the spreadsheet of mappings between Brightcove video tags and TME IDs
export AUTHORS_BERTHA_URL=http://bertha.site.example/123456XYZ/Authors
export ROLES_BERTHA_URL=http://bertha.site.example/123456XYZ/Roles
export MAPPINGS_BERTHA_URL=http://bertha.site.example/123456XYZ/Mapping
```

Run the image
-------------

```bash
docker run \
    -e "VAULT_PASS=$VAULT_PASS" \
    -e "TOKEN_URL=$TOKEN_URL" \
    -e "SERVICES_DEFINITION_ROOT_URI=$SERVICES_DEFINITION_ROOT_URI" \
    -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
    -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
    -e "ENVIRONMENT_TAG=$ENVIRONMENT_TAG" \
    -e "ENVIRONMENT_TYPE=$ENVIRONMENT_TYPE" \
    -e "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" \
    -e "API_HOST=$API_HOST" \
    -e "CLUSTER_BASIC_HTTP_CREDENTIALS=$CLUSTER_BASIC_HTTP_CREDENTIALS" \
    -e "DELIVERY_CLUSTERS_URLS=$DELIVERY_CLUSTERS_URLS" \
    -e "DELIVERY_CLUSTERS_HTTP_CREDENTIALS=$DELIVERY_CLUSTERS_HTTP_CREDENTIALS" \
    -e "BRIGHTCOVE_ACCOUNT_ID=$BRIGHTCOVE_ACCOUNT_ID" \
    -e "BRIGHTCOVE_AUTH=$BRIGHTCOVE_AUTH" \
    -e "AUTHORS_BERTHA_URL=$AUTHORS_BERTHA_URL" \
    -e "ROLES_BERTHA_URL=$ROLES_BERTHA_URL" \
    -e "MAPPINGS_BERTHA_URL=$MAPPINGS_BERTHA_URL" \
    coco/coco-pub-provisioner
```
