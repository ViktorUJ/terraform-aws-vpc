lint:
	pre-commit run --all-files -c .hooks/.pre-commit-config.yaml

install_git_hooks:
	$(VENV_BIN_PATH)/pre-commit install
	@echo 'Pre-commit hooks installed'

venv:
	virtualenv -p python3 -q $(VENV_PATH)
	$(VENV_BIN_PATH)/pip install --default-timeout 60 -r .hooks/requirements.txt
	@echo 'Virtualenv created'

clean:
	@rm -fr $(VENV_PATH)
	@echo 'Removed virtualenv'

dev: venv install_git_hooks
