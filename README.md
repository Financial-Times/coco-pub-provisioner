Docker image to provision a cluster
===================================

Tutorial
--------

If you're looking to provision a new pub cluster, the [tutorial](Tutorial.md) might be a better place to start than here. 

For developers
--------------

If you want to build the docker image locally and provision a cluster with that image, see [the developer readme](DEVELOPER_README.md)

Set up SSH
----------

See [SSH_README.md](/SSH_README.md/)

Provision a publishing cluster
------------------------------

```bash
## Set all the environment variables required to provision a cluster. These variables are stored in LastPass
## For PROD cluster
## LastPass: PROD Publishing cluster provisioning setup
## For TEST cluster
## LastPass: TEST Publishing cluster provisioning setup

## Run docker command
docker run \
    -e "VAULT_PASS=$VAULT_PASS" \
    -e "TOKEN_URL=$TOKEN_URL" \
    -e "SERVICES_DEFINITION_ROOT_URI=$SERVICES_DEFINITION_ROOT_URI" \
    -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
    -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
    -e "ENVIRONMENT_TAG=$ENVIRONMENT_TAG" \
    -e "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" \
    -e "API_HOST=$API_HOST" \
    -e "CLUSTER_BASIC_HTTP_CREDENTIALS=$CLUSTER_BASIC_HTTP_CREDENTIALS" \
    -e "BRIGHTCOVE_ACCOUNT_ID=$BRIGHTCOVE_ACCOUNT_ID" \
    -e "BRIGHTCOVE_AUTH=$BRIGHTCOVE_AUTH" \
    -e "AUTHORS_BERTHA_URL=$AUTHORS_BERTHA_URL" \
    -e "ROLES_BERTHA_URL=$ROLES_BERTHA_URL" \
    -e "MAPPINGS_BERTHA_URL=$MAPPINGS_BERTHA_URL" \
    -e "FACTSET_USERNAME=$FACTSET_USERNAME" \
    coco/coco-pub-provisioner:test

## IMPORTANT NOTE: Due to some unknown reason setting BRIGHTCOVE_AUTH did not work as expected. Once the cluster is running
## please check the etcd value for /ft/_credentials/brightcove_auth and correct it if necessary.

## IMPORTANT NOTE: Because the Factset SSH key exceeds the maximum length of a service file line, this key has to be set manually.
## Please run these commands from one of the cluster's machines, after provisioning:
    export FACTSET_KEY=
    etcdctl mk /ft/_credentials/factset/key "$FACTSET_KEY"
## FACTSET_KEY can be found in Lastpass: Factset FTP.

## If the cluster is running, set up HTTPS support (see below)
```

Set up HTTPS support
--------------------

To access URLs from the cluster through HTTPS, we need to add support for this in the load balancer of this cluster

* log on to one of the machines in AWS
* pick a HC url, like `foo-up.ft.com`, (where `foo` is the ENVIRONMENT_TAG you defined for this cluster) and execute `dig foo-up.ft.com`
* the answer section will look something like this:

```
;; ANSWER SECTION:
foo-up.ft.com.        600    IN    CNAME    bar1426.eu-west-1.elb.amazonaws.com.
```

* This is the ELB for the cluster on which the HC is running: `bar1426.eu-west-1.elb.amazonaws.com`

* in the AWS console > EC2 > Load Balancers > search for the LB
* click on it > Listeners > Edit > Add HTTPS on instance port `80`
* to know which SSL certificate to choose, check what the LBs of other clusters (which have https enabled) are using
* save and try if it works, ex. `https://foo-up.ft.com`
* you can also remove HTTP support if needed

Decommission an environment
---------------------------

```
## Secret used during decommissioning to decrypt keys - stored in LastPass.
## Lastpass: coco-provisioner-ansible-vault-pass
export VAULT_PASS=

## AWS API keys for decommissioning - stored in LastPass.
## Lastpass: infraprod-coco-aws-provisioning-keys
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=

## AWS region containing cluster to be decommissioned.
export AWS_DEFAULT_REGION=eu-west-1

## Cluster environment tag to decommission.
export ENVIRONMENT_TAG=
```



```sh
docker run \
  -e "VAULT_PASS=$VAULT_PASS" \
  -e "ENVIRONMENT_TAG=$ENVIRONMENT_TAG" \
  -e "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" \
  -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
  -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
  coco/coco-provisioner:v1.0.0 /bin/bash /decom.sh
```

Sometimes cleanup takes a long time and ELBs/Security Groups still get left behind. Other ways to clean up:

```sh
# List all coreos security groups
aws ec2 describe-security-groups | jq -r '.SecurityGroups[] | .GroupName + " " + .GroupId' | grep coreos

# Delete coreos security groups not in use, does not filter - will fail on any group that is being used
aws ec2 describe-security-groups | jq -r '.SecurityGroups[] | .GroupName + " " + .GroupId' | grep coreos | awk '{print $2}' | xargs -I {} -n1 sh -c 'aws ec2 delete-security-group --group-id {} || echo {} is active'

# Delete ELBs that have no instances AND there are no instances with the same group name (stopped) as the ELB
aws elb describe-load-balancers | jq -r '.LoadBalancerDescriptions[] | select(.Instances==[]) | .LoadBalancerName' | grep coreos | xargs -I {} sh -c "aws ec2 describe-instances --filters "Name=tag-key,Values=coco-environment-tag" | jq -e '.Reservations[].Instances[].SecurityGroups[] | select(.GroupName==\"{}\")' >/dev/null 2>&1 || echo {}" | xargs -n1 -I {} aws elb delete-load-balancer --load-balancer-name {}
```

