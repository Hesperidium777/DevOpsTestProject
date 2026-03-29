.PHONY: help install-deps lint validate deploy test clean

help:
	@echo "Available commands:"
	@echo "  install-deps  Install development dependencies"
	@echo "  lint          Lint all infrastructure code"
	@echo "  validate      Validate Helm charts and K8s manifests"
	@echo "  deploy        Deploy application to Kubernetes"
	@echo "  test          Run integration tests"
	@echo "  clean         Clean up resources"

install-deps:
	@echo "Installing dependencies..."
	@pip install ansible ansible-lint
	@curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
	@chmod 700 get_helm.sh
	@./get_helm.sh
	@rm get_helm.sh

lint:
	@echo "Linting Ansible playbooks..."
	@ansible-lint ansible/playbooks/*.yml
	@echo "Linting Helm charts..."
	@helm lint helm/sdd-navigator/
	@echo "Linting Kubernetes manifests..."
	@find kubernetes -name "*.yaml" -exec kubeval {} \;

validate: lint
	@echo "Validating Helm chart templates..."
	@helm template test-release helm/sdd-navigator/ --debug
	@echo "Validating Ansible syntax..."
	@for playbook in ansible/playbooks/*.yml; do \
		ansible-playbook $$playbook --syntax-check; \
	done

deploy:
	@echo "Deploying to $(ENVIRONMENT) environment..."
	@ansible-playbook -i ansible/inventories/$(ENVIRONMENT)/hosts.yml \
		ansible/playbooks/deploy-app.yml \
		-e "environment=$(ENVIRONMENT)"

test:
	@echo "Running integration tests..."
	@kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=sdd-navigator -n sdd-navigator --timeout=300s
	@./scripts/smoke-test.sh

clean:
	@echo "Cleaning up resources..."
	@helm uninstall sdd-navigator -n sdd-navigator || true
	@kubectl delete namespace sdd-navigator || true

dev-deploy: validate
	@ENVIRONMENT=dev $(MAKE) deploy

staging-deploy: validate
	@ENVIRONMENT=staging $(MAKE) deploy

prod-deploy: validate
	@ENVIRONMENT=prod $(MAKE) deploy