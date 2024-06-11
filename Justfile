
dev:
	find src downbadd downbad -name "*.hs" | entr -r ./restart_server.sh
