IMAGE_NAME=ft/coco-pub-provisioner
LATEST_TAG=$(IMAGE_NAME):latest

build:
	docker build -t ${LATEST_TAG} .

provision:
	docker run \
	-e "VAULT_PASS=$(VAULT_PASS)" \
    	-e "TOKEN_URL=$(TOKEN_URL)" \
    	-e "SERVICES_DEFINITION_ROOT_URI=$(SERVICES_DEFINITION_ROOT_URI)" \
    	-e "AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)" \
    	-e "AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)" \
    	-e "ENVIRONMENT_TAG=$(ENVIRONMENT_TAG)" \
    	-e "API_HOST=$(API_HOST)" \
    	-e "AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION)" \
    	-e "CLUSTER_BASIC_HTTP_CREDENTIALS=$(CLUSTER_BASIC_HTTP_CREDENTIALS)" \
    	-e "BRIGHTCOVE_ACCOUNT_ID=$(BRIGHTCOVE_ACCOUNT_ID)" \
    	-e "BRIGHTCOVE_AUTH=$(BRIGHTCOVE_AUTH)" \
    	-e "AUTHORS_BERTHA_URL=$(AUTHORS_BERTHA_URL)" \
    	-e "ROLES_BERTHA_URL=$(ROLES_BERTHA_URL)" \
    	-e "MAPPINGS_BERTHA_URL=$(MAPPINGS_BERTHA_URL)" \
	ft/coco-pub-provisioner:latest

decom:
	docker run \
	-e "VAULT_PASS=$(VAULT_PASS)" \
	-e "ENVIRONMENT_TAG=$(ENVIRONMENT_TAG)" \
	-e "AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION)" \
	-e "AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)" \
	-e "AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)" \
	ft/coco-pub-provisioner:latest /bin/bash /decom.sh
