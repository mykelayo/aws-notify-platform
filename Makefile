.PHONY: init plan apply destroy test lint bootstrap build-lambda

bootstrap:
	chmod +x scripts/bootstrap-state.sh
	./scripts/bootstrap-state.sh

init:
	cd terraform/environments/dev && terraform init

plan:
	cd terraform/environments/dev && terraform plan

apply:
	cd terraform/environments/dev && terraform apply

destroy:
	cd terraform/environments/dev && terraform destroy

test:
	pytest src/

lint:
	ruff check src/
	terraform fmt -recursive terraform/

build-lambda:
	cd src/processor && \
	pip install -r requirements.txt -t ./package && \
	cp handler.py ./package/ && \
	cd package && zip -r ../lambda.zip . && \
	cd .. && rm -rf package