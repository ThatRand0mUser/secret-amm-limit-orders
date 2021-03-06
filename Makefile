 
.PHONY: start
start: # CTRL+C to stop
	docker run -it --rm \
		-p 26657:26657 -p 26656:26656 -p 1337:1337 \
		-v $$(pwd):/root/code \
		--name secretdev enigmampc/secret-network-sw-dev:latest

.PHONY: snip20
snip20: # CTRL+C to stop
	bash ./tests/deployTestSNIP20s.sh

.PHONY: factory
factory: # CTRL+C to stop
	bash ./tests/deployFactory.sh

.PHONY: deploy-test-factory
deploy-test-factory: # CTRL+C to stop
	bash ./deploy/factory-testnet.sh

.PHONY: deploy-test-order
deploy-test-order: # CTRL+C to stop	
	bash ./deploy/secret-order-book-testnet.sh

