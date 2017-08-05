#!/bin/bash
#This script creates a mongodb sharded cluster in a single server 
#This cluster can be used for testing and development task and never recommended for production environment :)
#MongoDB sharded cluster has 2 shards for test environment
#Author Pranab Sharma <pranabksharma@gmail.com>

#Create the data directories
echo "Creating data directories"
mkdir -p /data/a0
mkdir -p /data/a1
mkdir -p /data/a2

mkdir -p /data/b0
mkdir -p /data/b1
mkdir -p /data/b2


#Create config directories
echo "Creating configDB data directories"
mkdir -p /data/cfg0
mkdir -p /data/cfg1
mkdir -p /data/cfg2


#Create log directory
echo "Creating log directory"
mkdir -p /logs


#Start config servers
echo "Starting config servers"
mongod --configsvr --replSet cfg --dbpath /data/cfg0 --port 26000 --fork --logpath /logs/log.cfg0 --logappend
mongod --configsvr --replSet cfg --dbpath /data/cfg1 --port 26001 --fork --logpath /logs/log.cfg1 --logappend
mongod --configsvr --replSet cfg --dbpath /data/cfg2 --port 26002 --fork --logpath /logs/log.cfg2 --logappend

echo "Running config replica set initiate"
cfg="{
    _id: 'cfg',
    members: [
        {_id: 1, host: 'localhost:26000'},
        {_id: 2, host: 'localhost:26001'},
        {_id: 3, host: 'localhost:26002'}
    ]
}"
mongo localhost:26000 --eval "JSON.stringify(db.adminCommand({'replSetInitiate' : $cfg}))"


#Start Mongod data servers
echo "Starting shard servers"
echo "Starting replica set a"
mongod --shardsvr --replSet a --dbpath /data/a0 --logpath /logs/log.a0 --port 27000 --fork --logappend  
mongod --shardsvr --replSet a --dbpath /data/a1 --logpath /logs/log.a1 --port 27001 --fork --logappend 
mongod --shardsvr --replSet a --dbpath /data/a2 --logpath /logs/log.a2 --port 27002 --fork --logappend 

echo "Running a replica set initiate"
cfg="{
    _id: 'a',
    members: [
        {_id: 1, host: 'localhost:27000'},
        {_id: 2, host: 'localhost:27001'},
        {_id: 3, host: 'localhost:27002'}
    ]
}"
mongo localhost:27000 --eval "JSON.stringify(db.adminCommand({'replSetInitiate' : $cfg}))"


echo "Starting replica set b"
mongod --shardsvr --replSet b --dbpath /data/b0 --logpath /logs/log.b0 --port 27100 --fork --logappend 
mongod --shardsvr --replSet b --dbpath /data/b1 --logpath /logs/log.b1 --port 27101 --fork --logappend 
mongod --shardsvr --replSet b --dbpath /data/b2 --logpath /logs/log.b2 --port 27102 --fork --logappend 


echo "Running b replica set initiate"
cfg="{
    _id: 'b',
    members: [
        {_id: 1, host: 'localhost:27100'},
        {_id: 2, host: 'localhost:27101'},
        {_id: 3, host: 'localhost:27102'}
    ]
}"
mongo localhost:27100 --eval "JSON.stringify(db.adminCommand({'replSetInitiate' : $cfg}))"



#Starting Mongos
echo "Starting mongos"
mongos --configdb cfg/localhost:26000,localhost:26001,localhost:26002 --fork --logappend --logpath /logs/log.mongos0 --port 27017
mongos --configdb cfg/localhost:26000,localhost:26001,localhost:26002 --fork --logappend --logpath /logs/log.mongos1 --port 27018
mongos --configdb cfg/localhost:26000,localhost:26001,localhost:26002 --fork --logappend --logpath /logs/log.mongos2 --port 27019

#Adding the shards
mongo localhost:27017 --eval "JSON.stringify(sh.addShard( 'a/localhost:27000'))"

mongo localhost:27017 --eval "JSON.stringify(sh.addShard( 'b/localhost:27100'))"




ps -A | grep mongo

tail -n 1 /logs/log.cfg0
tail -n 1 /logs/log.cfg1
tail -n 1 /logs/log.cfg2

tail -n 1 /logs/log.a0
tail -n 1 /logs/log.a1
tail -n 1 /logs/log.a2

tail -n 1 /logs/log.b0
tail -n 1 /logs/log.b1
tail -n 1 /logs/log.b2


tail -n 1 /logs/log.mongos0
tail -n 1 /logs/log.mongos1
tail -n 1 /logs/log.mongos2

