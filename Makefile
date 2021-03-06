OFFLINE = false
WEBAPP_FLAVOR = develop

.PHONY: api dashboard sentinel webapp

default:
	WEBAPP_FLAVOR=${WEBAPP_FLAVOR} foreman start

node_010:
	brew unlink node && brew unlink node012 && brew link node010
node_012:
	brew unlink node && brew unlink node010 && brew link node012
node_5:
	brew unlink node010 && brew unlink node012 && brew link node

api:
	cd api && \
		(${OFFLINE}||git pull||true) && \
		(${OFFLINE}||npm install) && \
		COUCH_URL=${COUCH_URL} node server.js
couch:
	couchdb
couch-logs:
	less /usr/local/var/log/couchdb/couch.log
lucene:
	/usr/local/Cellar/couchdb-lucene/1.0.2/bin/cl_run

dashboard: node_010
	cd dashboard && kanso push http://admin:pass@localhost:5984/dashboard

sentinel:
	cd sentinel && (git pull||true) && COUCH_URL=${COUCH_URL} node server.js

kansorc:
	cd webapp && echo "exports.env = { default: { db: '${COUCH_URL}' } }" > .kansorc
webapp-clean-bower:
	${OFFLINE} || (cd webapp && rm -rf bower_components)
webapp:
	cd webapp && (${OFFLINE}||git pull||true) && \
		rm -rf static/dist && \
		(${OFFLINE}||npm install) && \
		COUCH_URL=${COUCH_URL} grunt dev
webapp-develop: node_5 kansorc webapp
webapp-010: node_010 kansorc webapp
webapp-012: node_012 kansorc webapp
precommit:
	cd webapp && grunt precommit

launch-latest-iso:
	cd containerisation && ./pack

reset-demo-data: reset-demo-data-alpha
reset-demo-data-mini:
	-mkdir demo-data
	${OFFLINE} || (cd demo-data && \
		wget -c 'https://staging.dev.medicmobile.org/_couch/downloads/medic-demos-diy-release.tar.xz/medic-demos-diy-release.tar.xz')
	cd demo-data && tar -xvf medic-demos-diy-release.tar.xz
	cp demo-data/demos/*.couch /usr/local/var/lib/couchdb/ && rm -rf /usr/local/var/lib/couchdb/.medic_design/
reset-demo-data-alpha:
	-mkdir demo-data
	${OFFLINE} || (cd demo-data && \
		wget -c 'https://staging.dev.medicmobile.org/_couch/downloads/medic-demos-demos-alpha.tar.xz/medic-demos-demos-alpha.tar.xz')
	cd demo-data && tar -xvf medic-demos-demos-alpha.tar.xz
	cp demo-data/demos/*.couch /usr/local/var/lib/couchdb/ && rm -rf /usr/local/var/lib/couchdb/.medic_design/
reset-demo-data-beta:
	-mkdir demo-data
	${OFFLINE} || (cd demo-data && \
		wget -c 'https://staging.dev.medicmobile.org/_couch/downloads/medic-demos-demos-beta.tar.xz/medic-demos-demos-beta.tar.xz')
	cd demo-data && tar -xvf medic-demos-demos-beta.tar.xz
	cp demo-data/demos/*.couch /usr/local/var/lib/couchdb/ && rm -rf /usr/local/var/lib/couchdb/.medic_design/

kill-services:
	ps -ef | egrep 'node|npm' | grep -v grep | awk '{print $$2}' | xargs -n1 kill -9

webapp-unit:
	cd webapp && grunt jshint mmjs karma:unit karma:unit_ci
