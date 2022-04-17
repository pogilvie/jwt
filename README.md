# JWT Authorization for Salesforce Scratch Orgs
A codified version of Wade Wegner's [blog post](https://www.wadewegner.com/2018/01/authenticate-to-your-scratch-orgs-using-the-oauth-2.0-jwt-bearer-flow/)

## Prerequisites
1. Install Make
2. Salesforce cli authentication to a devhub (you might want to create an
   authenticate to a new playground if you're just tryin this out)
3. Install sfdx-waw-plugin `sfdx plugins:install sfdx-waw-plugin`
4. update the `dev` variable in `config.mk` to the value of devhub user or alias
5. udpate the `connectedAppName` of the connected app you wish to create

## Create server.crt(Cert) server.key (Private Key )
`server.crt` is a certificate which can up uploaded to Salesforce. It has an
expiration in this example and is generated from server.csr and server.key

`server.key` is the private key which is used to sign requests
 
 Rules 1 - 4 in `Makfile` as used to generate these files

1. Generate server.pass.key: `make step-1`
2. Generate server.key from server.pass.key: `make step-2`
3. Generate server.csr: `make step-3` fill in values of country, state etc.  But
   leave password blank
3. Finally generate SSL certificate (expires in 1 year): `make step-4`

## Create a Connected App

This command will create a connected app on the deb hub with `grantUsername` as the app contact

1. `make connected-app`

If successful the app will output some JSON with the `consumerkey` and `consumerSecret`.  Set the variable `clientId` to the value of `consumerkey`

### Configure Connected App

1. Manage: Edit Policies `Admin approved users are pre-authorized` Profile `System Administrator`
2. Edit: Use digital signatures:  upload `server.crt`

## Grant the user access to the app

This is the step which is often skipped.  The JWT token will not work without it.

1. `make grant`

you should see something similar to the following:

```
peter: (master):~/Projects/jwt-> make grant
sfdx force:auth:jwt:grant \
                --clientid '3MVG9KI2HHAq33RyHfKPr46ZZYHmziSVDqXLpuhI4Cib54XtjSpgM6ItuZCy1vHV976CiT5OGZNhxgky9T69r' \
                --username code@ogilvie.us.com \
                --jwtkeyfile ./server.key \
                --setdefaultdevhubusername -a dev
Successfully authorized code@ogilvie.us.com with org ID 00D61000000JfR9EAK
```

## create a scarch org using the JWT token

`make scatch`

Note the user name from the output and save it in `config.mk:scratchUsername`

```
peter: (master):~/Projects/jwt-> make scratch
sfdx force:org:create -a Demo -s -f config/scratch.json
(node:43336) [DEP0147] DeprecationWarning: In future versions of Node.js, fs.rmdir(path, { recursive: true }) will be removed. Use fs.rm(path, { recursive: true }) instead
(Use `node --trace-deprecation ...` to show where the warning was created)
Successfully created scratch org: 00D0t000000NtlrEAC, username: test-kz4bxmxfdley@example.com
```
