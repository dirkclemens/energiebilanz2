#!/usr/bin/env python3
# -*- coding: utf-8 -*-

########################################################################
#
#	mqtt subscription daemon
#	leitet alles in db tabellen um ...
#
#	--user-Flag angeben, damit die Module im Home-Verzeichnis installiert werden
#
#	requirements:
#		paho			--> sudo python3 -m pip install paho-mqtt 
#		config  		--> sudo python3 -m pip install configparser
#
#		sudo apt-get install python-dev python-pip python-lxml
#		sudo pip install paho-mqtt
#
#	ideas:
#		https://github.com/tomyvi/php-owntracks-recorder
# 		https://www.dinotools.de/2015/04/12/mqtt-mit-python-nutzen/
#
#	https://www.w3schools.com/python/python_json.asp
#
########################################################################
from __future__ import print_function


import paho.mqtt.client as mqtt
import sqlite3
import json
import time
import datetime
import os, sys
import logging
import glob
import logging
import logging.handlers
from logging.handlers import TimedRotatingFileHandler
import requests # REST-API calls

# ---------------------------------------------------------------------------- #
# setup / defines
# ---------------------------------------------------------------------------- #

smarthomedb 	= '/opt/autohome/smarthome.db'

# ---------------------------------------------------------------------------- #
debug_flag = False
#debug_flag = True

# ---------------------------------------------------------------------------- #
json_dict = dict()
hist_values = []


# ---------------------------------------------------------------------------- #
#	parameter handling
# ---------------------------------------------------------------------------- #
if len(sys.argv) >= 2:
	if (sys.argv[1] == "debug"):
		print ("started in debug mode")
		debug_flag = True

try:
	from configparser import ConfigParser
except ImportError:
	from ConfigParser import ConfigParser  # ver. < 3.0

config = ConfigParser()
config.read('/home/dirk/.credentials/pycredentials')

MQTT_SERVER 		= config.get('DEFAULT','mqtt_server')
MQTT_PORT 			= config.get('DEFAULT','mqtt_port')
MQTT_TLS 			= config.get('DEFAULT','mqtt_tls')
MQTT_SERVERIP 		= config.get('DEFAULT','mqtt_serverip')
MQTT_CACERT 		= config.get('DEFAULT','mqtt_cacert')
MQTT_USER 			= config.get('DEFAULT','mqtt_user')
MQTT_PASSWD 		= config.get('DEFAULT','mqtt_passwd')


# ---------------------------------------------------------------------------- #
def dolog(message):
	print('[%s]\t%s\n\n' % (str(datetime.datetime.now()), message))

def debug_out(message):
	if (debug_flag == True):
		print('[%s]\t%s\n\n' % (str(datetime.datetime.now()), message))
		my_logger.debug(message)



# ---------------------------------------------------------------------------- #
# mosquitto 	#
# ---------------------------------------------------------------------------- #
# The callback for when the client receives a CONNACK response from the server.
def on_connect(mqtt_client, userdata, flags, rc):
	print("Connected with result code " + str(rc))
	debug_out("Connected to mosquitto server with result code " + str(rc))
	
#	## smarthome/stat/tasmota7163/STATUS8 (alle 10 sec, daher besser tele/tasmota7163)
#	mqtt_client.subscribe([('energy/growatt/modbusdata/#',0),('smarthome/stat/tasmota7163/STATUS8/#',0)])

# ---------------------------------------------------------------------------- #
def on_disconnect(mqtt_client, userdata, rc):
    if rc != 0:
        my_logger.error("Unexpected disconnection.")
        pushover("mqtt_subd:Unexpected disconnection from MQTT: %s" % (str(rc),))

# ---------------------------------------------------------------------------- #
def on_log(mqtt_client, userdata, level, buf):
	my_logger.info("%s - %s" % (userdata, buf))

# ---------------------------------------------------------------------------- #
# The callback for when a PUBLISH message is received from the server.
# ---------------------------------------------------------------------------- #
def on_message(mqtt_client, userdata, msg):
	global json_dict, hist_values
	#,mqttHomePower,mqttGridPower,mqttPower,mqttIsCharging,mqttChargePower,mqttVehicleRange,mqttVehicleSoc,mqttVehicleOdometer,mqttTotal_In,mqttTotal_Out,mqttPower_curr

	#print("Received message '" + str(msg.payload) + "' on topic '" + msg.topic + "' with QoS " + str(msg.qos))
	debug_out("Topic: %s - Message: %s" % (msg.topic, str(msg.payload)))
	#2016-01-24 12:10:04
	ts = time.time()
	timestamp  = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
	
#	print (repr(msg.payload))

	try:
		if msg.topic == "evcc/site/homePower":		# Verbrauch
			#mqttHomePower = float(msg.payload)
			json_dict['homePower'] = float(msg.payload)

		if msg.topic == "evcc/site/gridPower":		# Einspeisung (<0) oder Netzbezug (>0) 
			#mqttGridPower = float(msg.payload)
			gridPower = float(msg.payload)
			if gridPower < 0 :
				json_dict['gridInPower']  = 0.0
				json_dict['gridOutPower']  = gridPower
			else:
				json_dict['gridInPower']  = gridPower
				json_dict['gridOutPower']  = 0.0

		if msg.topic == "evcc/site/pvPower":		# Erzeugung (PV)
			#mqttPower = float(msg.payload)
			json_dict['pvPower'] = float(msg.payload)

		if msg.topic == "evcc/loadpoints/1/charging":
			#mqttIsCharging = msg.payload.decode("utf-8")
			json_dict['charging'] = msg.payload.decode("utf-8")

		if msg.topic == "evcc/loadpoints/1/chargePower":
			#mqttChargePower = float(msg.payload)
			json_dict['chargePower'] = float(msg.payload)

		if msg.topic == "evcc/loadpoints/1/vehicleRange":
			#mqttVehicleRange = float(msg.payload)
			json_dict['vehicleRange'] = float(msg.payload)
			
		if msg.topic == "evcc/loadpoints/1/vehicleSoc":
			#mqttVehicleSoc = float(msg.payload)
			json_dict['vehicleSoc'] = float(msg.payload)
			
		if msg.topic == "evcc/loadpoints/1/vehicleOdometer":
			#mqttVehicleOdometer = float(msg.payload)
			json_dict['vehicleOdometer'] = float(msg.payload)

		if msg.topic == "energy/growatt/modbusdata":
			try:
				tmp_dict = json.loads(msg.payload.decode("utf-8"))

				json_dict['outputpower'] = tmp_dict['outputpower']
				json_dict['energytotal'] = tmp_dict['energytotal']
				json_dict['energytoday'] = tmp_dict['energytoday']


			except Exception as e:
				my_logger.error("ERROR: on_message: \t%s (%s > %s)" % (e, msg.topic, msg.payload))


		if msg.topic == "smarthome/stat/tasmota7163/STATUS8":
			try:
				tmp_dict = json.loads(msg.payload.decode("utf-8"))

				json_dict['Total_in'] = tmp_dict["StatusSNS"]["SML"]["Total_in"]
				json_dict['Total_out'] = tmp_dict["StatusSNS"]["SML"]["Total_out"]
				json_dict['Power_curr'] = tmp_dict["StatusSNS"]["SML"]["Power_curr"]

			except Exception as e:
				my_logger.error("ERROR: on_message: tasmota7163\t%s (%s > %s)" % (e, msg.topic, msg.payload))


			# ---------------------------------------------------------------------------
			#	collect historical data for charts
			# ---------------------------------------------------------------------------
# 			if hist_values == "":
# 				return
# 			if len(hist_values) == 50:
# 				hist_values.pop(0)
# 			hist_values.append([json_dict['homePower'], json_dict['gridPower'], json_dict['pvPower']])
			#print("Array:", hist_values)


	except Exception as e:
		my_logger.error("ERROR: on_message(): %s (%s > %s)" % (e, msg.topic, msg.payload))
	#finally:

# ---------------------------------------------------------------------------- #
#	send data as API call 
# ---------------------------------------------------------------------------- #
def sendRequest():
	global json_dict, hist_values

# 	add timestamp to json
	now = datetime.datetime.now()
	date_time = now.strftime("%Y-%m-%d %H:%M:%S")
	json_dict['dt'] = '%s' % (date_time)

	json_dict['id'] = 1

	json_string = json.dumps(json_dict)
	#dolog(json_string)

	try:
		# send json_string to server
		url = 'https://xx.xxx.de/api.php'
		headers = {'Content-Type': 'application/json'}
		response = requests.post(url, data=json_string, headers=headers)
		# print the response from the server
# 		if (response.status_code != 201):
# 			dolog("%s Status:%s" % (response.text, response.status_code))
	except Exception as e:
		my_logger.error("ERROR: sendRequest(): %s (%s > %s)" % (e, response.text, response.status_code))


# ---------------------------------------------------------------------------- #
#	send data as API call 
# ---------------------------------------------------------------------------- #
def sendRequestHistData():
	global hist_values
	
	try:
		# send json_string to server
		url = 'https://xx.xxx.de/api.php?type=hist'
		headers = {'Content-Type': 'application/json'}
		response = requests.post(url, data=json_string, headers=headers)
		# print the response from the server
# 		if (response.status_code != 201):
# 			dolog("%s Status:%s" % (response.text, response.status_code))
	except Exception as e:
		my_logger.error("ERROR: sendRequest(): %s (%s > %s)" % (e, response.text, response.status_code))

# ---------------------------------------------------------------------------- #
#
#   Main Program
#
# ---------------------------------------------------------------------------- #
def main():

	# https://pypi.org/project/paho-mqtt/
	# create the MQTT client
	mqtt_client = mqtt.Client()
	if (MQTT_TLS == "True"):
		my_logger.info("connecting using tls")
		mqtt_client.tls_set(MQTT_CACERT)

	mqtt_client.on_connect 		= on_connect
	mqtt_client.on_disconnect 	= on_disconnect
	if (debug_flag == True):
		mqtt_client.on_log		= on_log
	mqtt_client.on_message 		= on_message

	mqtt_client.username_pw_set(username=MQTT_USER,password=MQTT_PASSWD)
	#print('connect')
	mqtt_client.connect(MQTT_SERVER, int(MQTT_PORT), 60)
	#print('connected')

	mqtt_client.subscribe([('evcc/site/#',0),('evcc/loadpoints/1/#',0),('energy/growatt/modbusdata/#',0),('smarthome/stat/tasmota7163/STATUS8/#',0)])

	# Blocking call that processes network traffic, dispatches callbacks and
	# handles reconnecting.
	# Other loop*() functions are available that give a threaded interface and a
	# manual interface.
	#mqtt_client.loop_forever()
	mqtt_client.loop_start()

	# once every n seconds or minutes
	shortInterval = (datetime.datetime.now() + datetime.timedelta(seconds=10)) #.replace(second=0, microsecond=0)
	longInterval = (datetime.datetime.now() + datetime.timedelta(minutes=5)) #.replace(second=0, microsecond=0)

	while True:
		#time.sleep(30)
		now = datetime.datetime.now()

		if now >= shortInterval:
			shortInterval = (datetime.datetime.now() + datetime.timedelta(seconds=10)) 
			dolog("normal data")
			# insert code to be run every n  minute here
			sendRequest()

		if now >= longInterval:
			longInterval = (datetime.datetime.now() + datetime.timedelta(minutes=5)) 
			dolog("hist data")
			# insert code to be run every n minute here
			#sendRequestHistData()


	mqtt_client.unsubscribe([('evcc/site/#',0),('evcc/loadpoints/1/#',0),('energy/growatt/modbusdata/#',0),('smarthome/stat/tasmota7163/STATUS8/#',0)])

	mqtt_client.disconnect()



# ---------------------------------------------------------------------------- #
#
#
# ---------------------------------------------------------------------------- #
if __name__ == '__main__':

	if (debug_flag == True):
		logging.basicConfig(level=logging.DEBUG)
	else:
		logging.basicConfig(level=logging.INFO)

	__location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))
	LOG_FILENAME = os.path.join(__location__, "mqtt_energy.log")

	# Set up a specific logger with our desired output level
	my_logger = logging.getLogger('--[MQTT_ENERGY]--')
	my_logger.setLevel(logging.INFO)
	logFormatter = logging.Formatter('%(asctime)s \t %(message)s')

	# Add the log message handler to the logger
	logHandler = logging.handlers.TimedRotatingFileHandler(LOG_FILENAME, when="W0", backupCount=12)
	logHandler.setFormatter(logFormatter)
	my_logger.addHandler(logHandler)

	# additionally log to stdout
	consoleHandler = logging.StreamHandler()
	consoleHandler.setFormatter(logFormatter)
	my_logger.addHandler(consoleHandler)

	try:
		main()
	except KeyboardInterrupt:
		pass

	print ("\nGoodbye!")


