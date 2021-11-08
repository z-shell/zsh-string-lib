check: test

test:
	@command -v zunit >/dev/null && \
	    { zunit; ((1)); } || \
	    echo "Please install zunit to run the tests (https://github.com/zunit-zsh/zunit)"
