
ifeq ($(TEST_NO_FUSE),1)
go_test=go test -tags nofuse
else
go_test=go test
endif

ipfsCmdDir=./src/github.com/ipfs/go-ipfs/cmd/ipfs

all:
	# no-op. try:
	#   make install
	#   make test

gb:
	go get -u github.com/constabulary/gb/...

# saves/vendors third-party dependencies to Godeps/_workspace
# -r flag rewrites import paths to use the vendored path
# ./... performs operation on all packages in tree
vendor: gb
	godep save -r ./...

install:
	cd ${ipfsCmdDir} && go install

build: gb
	gb build github.com/ipfs/go-ipfs/cmd/ipfs

nofuse:
	cd ${ipfsCmdDir} && go install -tags nofuse

##############################################################
# tests targets

test: test_expensive

test_short: build test_go_short test_sharness_short

test_expensive: build test_go_expensive test_sharness_expensive

test_3node:
	cd test/3nodetest && make

test_go_short:
	$(go_test) -test.short ./...

test_go_expensive:
	$(go_test) ./...

test_go_race:
	$(go_test) ./... -race

test_sharness_short:
	cd test/sharness/ && make

test_sharness_expensive:
	cd test/sharness/ && TEST_EXPENSIVE=1 make

test_all_commits:
	@echo "testing all commits between origin/master..HEAD"
	@echo "WARNING: this will 'git rebase --exec'."
	@test/bin/continueyn
	GIT_EDITOR=true git rebase -i --exec "make test" origin/master
