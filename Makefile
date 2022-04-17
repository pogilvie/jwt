include ./config.mk

# grant
grant:
	sfdx force:auth:jwt:grant \
		--clientid '$(clientId)' \
		--username $(grantUsername) \
		--jwtkeyfile ./server.key \
		--setalias $(dev)

# setup up grant to scatch org
grant-scratch:
	sfdx force:auth:jwt:grant \
		--clientid $(clientId) \
		--username $(scratchUsername) \
		--jwtkeyfile ./server.key \
		--instanceurl https://test.salesforce.com

# create a scratch org
scratch:
	sfdx force:org:create -a scratch -f config/scratch.json -v $(grantUsername)

# create connected app
connected-app:
	sfdx waw:connectedapp:create \
		-c http://localhost:1717/OauthRedirect \
		-e $(grantUsername) \
		-s Basic,Api,Web,RefreshToken \
		-n $(connectedAppName) \
		-u $(dev)

# generate SSL certificate
step-4:
	openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt

# create server.csr
step-3:
	openssl req -new -key server.key -out server.csr

# generate server.key from server.pass.key
step-2:
	openssl rsa -passin pass:gsahdg -in server.pass.key -out server.key
	rm server.pass.key

# generate server.pass.key
step-1:
	openssl genrsa -aes256 -passout pass:gsahdg -out server.pass.key 4096