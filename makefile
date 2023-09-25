all:
	git submodule init
	git submodule update
	mix deps.get
	mix test
	mix escript.build
	test/bats/bin/bats test/acceptance_tests.bats
