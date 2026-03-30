build-api:
	docker build -t api ./apps/api

build-frontend:
	docker build -t frontend ./apps/frontend

deploy:
	ansible-playbook ansible/playbooks/deploy.yml

lint:
	helm lint helm/sdd-navigator
