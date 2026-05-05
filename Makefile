.PHONY: init plan apply destroy test lint bootstrap

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