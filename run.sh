#!/bin/bash

set -e
# set -x

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"

function try-load-dotenv {
    if [ ! -f "$THIS_DIR/.env" ]; then
        echo "no .env file found"
        return 1
    fi

    # Load the .env file (subshell, variables won't persist)
    source ".env"
    echo "Loaded environment variables from .env"
}

function install {
    python -m pip install --upgrade pip
    python -m pip install --editable "$THIS_DIR/[dev]"
}

function lint {
    pre-commit run --all-files
}

function lint:ci {
    pre-commit run --all-files
}

function build {
    python -m build --sdist --wheel "$THIS_DIR/"
}

function release:test {
    lint
    clean
    build
    publish:test
}

function release:prod {
    release:test
    publish:prod
}

function publish:test {
    try-load-dotenv || true
    twine upload dist/* \
        --repository testpypi \
        --username=__token__ \
        --password="$TEST_PYPI_TOKEN"
}

function publish:test {
    try-load-dotenv || true
    twine upload dist/* \
        --repository pypi \
        --username=__token__ \
        --password="$PROD_PYPI_TOKEN"
}

function clean {
    rm -rf dist build
    find . \
      -type d -name "*cache*" -or \
      -type d -name "*.dist-info" -or \
      -type d -name "*.egg-info" \
      -not -path "./venv/*" -exec rm -rf {} +
    echo "Clean up completed!"
}

function help {
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A function | cat -n
}

TIMEFORMAT="Task completed in %3lR"
time ${@:-help}
