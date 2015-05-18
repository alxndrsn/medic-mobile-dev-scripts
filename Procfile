# Please define a .env file with relevant environment
# variables defined inside as key=value pairs (one per
# line.
#
# Possible variables include:
#
# WEBAPP_START_DELAY: the time (seconds) it takes
#   webapp to start.  sentinel and api need to delay
#   starting until webapp is running ok.
# COUCH_URL: url for accessing your couch db instance,
#   e.g. http://admin:pass@localhost:5984/medic

api: sleep ${WEBAPP_START_DELAY} && make api
couch: make couch
lucene: make lucene
sentinel: sleep ${WEBAPP_START_DELAY} && make sentinel
webapp: make webapp
