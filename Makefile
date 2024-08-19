.PHONY: test

export TF_PATH

test:
	cd tests && go test -v -timeout 60m -run TestApplyNoError/$(TF_PATH) ./rule_test.go
