.PHONY: api dashboard sentinel webapp

node_010:
	brew unlink node && brew link node010
node_012:
	brew unlink node010 && brew link node
api:
	cd api && (git pull||true) && npm install && COUCH_URL=${COUCH_URL} node server.js
couch:
	couchdb
couch-logs:
	less /usr/local/var/log/couchdb/couch.log
dashboard: node_010
	cd dashboard && kanso push http://admin:pass@localhost:5984/dashboard
lucene:
	/usr/local/Cellar/couchdb-lucene/1.0.2/bin/cl_run
sentinel:
	cd sentinel && (git pull||true) && COUCH_URL=${COUCH_URL} node server.js
webapp: node_012
	cd webapp && rm -rf static/dist && (git pull||true) && COUCH_URL=${COUCH_URL} grunt dev --force
precommit:
	cd webapp && grunt precommit
reset-demo-data:
	-mkdir demo-data
	cd demo-data && wget -c 'https://staging.dev.medicmobile.org/_couch/downloads/medic-demos-demos-alpha.tar.xz/medic-demos-demos-alpha.tar.xz'
	cd demo-data && tar -xvf medic-demos-demos-alpha.tar.xz
	cp demo-data/demos/*.couch /usr/local/var/lib/couchdb/ && rm -rf /usr/local/var/lib/couchdb/.medic_design/
