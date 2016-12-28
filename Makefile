.PHONY: test

test:
	SHELL=`command -v bash` ./test/runner
	SHELL=`command -v zsh` ./test/runner
