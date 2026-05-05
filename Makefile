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

# Destroy all infrastructure
tf-destroy:
	cd terraform/environments/dev && terraform destroy -auto-approve

# Scheduled destroy (for cron jobs)
schedule-destroy:
	@echo "0 0 * * 0 cd $(PWD)/terraform/environments/dev && terraform destroy -auto-approve" | crontab -

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

build-publisher:
	cd src/publisher && \
	pip install -r requirements.txt -t ./package && \
	cp handler.py ./package/ && \
	cd package && zip -r ../lambda.zip . && cd .. && rm -rf package