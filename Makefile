# Makefile

.PHONY: apply plan sanity-check

plan:
    terraform get --update=true
	terraform plan --var-file=config.json --out plan.out

apply:
	terraform apply plan.out

sanity-check: venv
	venv/bin/python bin/sanity_check.py

# Python virtualenv automatic setup. Ensures that targets relying on the virtualenv always have an updated python to
# use.
#
# This is intended for developer convenience. Do not attempt to make venv in a Docker container or use a virtualenv in
# docker container because you will be going into a world of darkness.

venv: venv/bin/activate

venv/bin/activate: requirements.txt
	test -d venv || virtualenv venv --quiet --python python3
	venv/bin/pip install -Uqr requirements.txt
	touch venv/bin/activate