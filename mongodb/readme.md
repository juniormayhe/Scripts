# MongoDB

## Convert Binary format ID to JSON and CSUUID

```js
// set your binary id here
var id = "cNwSBKe6TUiXSIWct08rXA==";

var binaryId = BinData(3, id);
var hexString = binaryId.toString('hex');
var guid = hexString.replace(/(.{8})(.{4})(.{4})(.{4})(.{12})/, "$1-$2-$3-$4-$5");

var t = UUID(bin.buffer.toString("hex"));
var bin = Binary(Buffer.from(t.toString("hex"), "hex"), 3);

function ToCSUUID(binaryId) {
  var buffer = binaryId.buffer;

  var hexString = "";
  for (var i = 0; i < buffer.length; i++) {
    var hex = (buffer[i] & 0xff).toString(16);
    hex = hex.length === 1 ? "0" + hex : hex;
    hexString += hex;
  }

  var csuuid =
    hexString.substr(0, 8) +
    "-" +
    hexString.substr(8, 4) +
    "-" +
    hexString.substr(12, 4) +
    "-" +
    hexString.substr(16, 4) +
    "-" +
    hexString.substr(20);

  return csuuid;
}

print("-- Results --------------------------------------------");
print("  - Original Id:");
print("    └ BSON id: \t\t\t\t" + id);
print("  - Converted to GUIDs:");
print("    └ JSON guid: \t\t\t" + guid);
// print("    └ CSharp UUID (CSUUID):\t" + ToCSUUID( UUID(bin.buffer.toString("hex"))) );
```
## Convert UUID to BinData
```js
function HexToBase64(hex) {
    var base64Digits = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    var base64 = "";
    var group;
    for (var i = 0; i < 30; i += 6) {
        group = parseInt(hex.substr(i, 6), 16);
        base64 += base64Digits[(group >> 18) & 0x3f];
        base64 += base64Digits[(group >> 12) & 0x3f];
        base64 += base64Digits[(group >> 6) & 0x3f];
        base64 += base64Digits[group & 0x3f];
    }
    group = parseInt(hex.substr(30, 2), 16);
    base64 += base64Digits[(group >> 2) & 0x3f];
    base64 += base64Digits[(group << 4) & 0x3f];
    base64 += "==";
    return base64;
}

function Base64ToHex(base64) {
    var base64Digits = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    var hexDigits = "0123456789abcdef";
    var hex = "";
    for (var i = 0; i < 24; ) {
        var e1 = base64Digits.indexOf(base64[i++]);
        var e2 = base64Digits.indexOf(base64[i++]);
        var e3 = base64Digits.indexOf(base64[i++]);
        var e4 = base64Digits.indexOf(base64[i++]);
        var c1 = (e1 << 2) | (e2 >> 4);
        var c2 = ((e2 & 15) << 4) | (e3 >> 2);
        var c3 = ((e3 & 3) << 6) | e4;
        hex += hexDigits[c1 >> 4];
        hex += hexDigits[c1 & 15];
        if (e3 != 64) {
            hex += hexDigits[c2 >> 4];
            hex += hexDigits[c2 & 15];
        }
        if (e4 != 64) {
            hex += hexDigits[c3 >> 4];
            hex += hexDigits[c3 & 15];
        }
    }
    return hex;
}

function UUID(uuid) {
    var hex = uuid.replace(/[{}-]/g, ""); // remove extra characters
    var base64 = HexToBase64(hex);
    return new BinData(4, base64); // new subtype 4
}

function JUUID(uuid) {
    var hex = uuid.replace(/[{}-]/g, ""); // remove extra characters
    var msb = hex.substr(0, 16);
    var lsb = hex.substr(16, 16);
    msb = msb.substr(14, 2) + msb.substr(12, 2) + msb.substr(10, 2) + msb.substr(8, 2) + msb.substr(6, 2) + msb.substr(4, 2) + msb.substr(2, 2) + msb.substr(0, 2);
    lsb = lsb.substr(14, 2) + lsb.substr(12, 2) + lsb.substr(10, 2) + lsb.substr(8, 2) + lsb.substr(6, 2) + lsb.substr(4, 2) + lsb.substr(2, 2) + lsb.substr(0, 2);
    hex = msb + lsb;
    var base64 = HexToBase64(hex);
    return new BinData(3, base64);
}

function CSUUID(uuid) {
    var hex = uuid.replace(/[{}-]/g, ""); // remove extra characters
    var a = hex.substr(6, 2) + hex.substr(4, 2) + hex.substr(2, 2) + hex.substr(0, 2);
    var b = hex.substr(10, 2) + hex.substr(8, 2);
    var c = hex.substr(14, 2) + hex.substr(12, 2);
    var d = hex.substr(16, 16);
    hex = a + b + c + d;
    var base64 = HexToBase64(hex);
    return new BinData(3, base64);
}

function PYUUID(uuid) {
    var hex = uuid.replace(/[{}-]/g, ""); // remove extra characters
    var base64 = HexToBase64(hex);
    return new BinData(3, base64);
}

BinData.prototype.toUUID = function () {
    var hex = Base64ToHex(this.base64()); // don't use BinData's hex function because it has bugs in older versions of the shell
    var uuid = hex.substr(0, 8) + '-' + hex.substr(8, 4) + '-' + hex.substr(12, 4) + '-' + hex.substr(16, 4) + '-' + hex.substr(20, 12);
    return 'UUID("' + uuid + '")';
}

BinData.prototype.toJUUID = function () {
    var hex = Base64ToHex(this.base64()); // don't use BinData's hex function because it has bugs in older versions of the shell
    var msb = hex.substr(0, 16);
    var lsb = hex.substr(16, 16);
    msb = msb.substr(14, 2) + msb.substr(12, 2) + msb.substr(10, 2) + msb.substr(8, 2) + msb.substr(6, 2) + msb.substr(4, 2) + msb.substr(2, 2) + msb.substr(0, 2);
    lsb = lsb.substr(14, 2) + lsb.substr(12, 2) + lsb.substr(10, 2) + lsb.substr(8, 2) + lsb.substr(6, 2) + lsb.substr(4, 2) + lsb.substr(2, 2) + lsb.substr(0, 2);
    hex = msb + lsb;
    var uuid = hex.substr(0, 8) + '-' + hex.substr(8, 4) + '-' + hex.substr(12, 4) + '-' + hex.substr(16, 4) + '-' + hex.substr(20, 12);
    return 'JUUID("' + uuid + '")';
}

BinData.prototype.toCSUUID = function () {
    var hex = Base64ToHex(this.base64()); // don't use BinData's hex function because it has bugs in older versions of the shell
    var a = hex.substr(6, 2) + hex.substr(4, 2) + hex.substr(2, 2) + hex.substr(0, 2);
    var b = hex.substr(10, 2) + hex.substr(8, 2);
    var c = hex.substr(14, 2) + hex.substr(12, 2);
    var d = hex.substr(16, 16);
    hex = a + b + c + d;
    var uuid = hex.substr(0, 8) + '-' + hex.substr(8, 4) + '-' + hex.substr(12, 4) + '-' + hex.substr(16, 4) + '-' + hex.substr(20, 12);
    return 'CSUUID("' + uuid + '")';
}

BinData.prototype.toPYUUID = function () {
    var hex = Base64ToHex(this.base64()); // don't use BinData's hex function because it has bugs
    var uuid = hex.substr(0, 8) + '-' + hex.substr(8, 4) + '-' + hex.substr(12, 4) + '-' + hex.substr(16, 4) + '-' + hex.substr(20, 12);
    return 'PYUUID("' + uuid + '")';
}

BinData.prototype.toHexUUID = function () {
    var hex = Base64ToHex(this.base64()); // don't use BinData's hex function because it has bugs
    var uuid = hex.substr(0, 8) + '-' + hex.substr(8, 4) + '-' + hex.substr(12, 4) + '-' + hex.substr(16, 4) + '-' + hex.substr(20, 12);
    return 'HexData(' + this.subtype() + ', "' + uuid + '")';
}

// for compatibility with the new mongosh shell
if (BinData.prototype.base64 === undefined && BinData.prototype.subtype === undefined) {
    BinData.prototype.base64 = function() { return this.buffer.base64Slice(); };
    BinData.prototype.subtype = function() { return this.sub_type; };
}

// Convert CSUUID("0412DC70-BAA7-484D-9748-859CB74F2B5C"), --> "cNwSBKe6TUiXSIWct08rXA=="
var s = "0412DC70-BAA7-484D-9748-859CB74F2B5C";
var csuuid = CSUUID(s);
print(csuuid.base64());
```

## Find items whose ID is not found in another collection
```js
db.getCollection("CollectionA").find({
  MyId: {
    $nin: db.getCollection("CollectionB").distinct("MyId")
  }
})
```
## Copy database
```js
// Drop the new database if it already exists
var oldDb = 'OLD_DB';
var targetDatabase = 'NEW_DB';
if (db.getMongo().getDBNames().indexOf(targetDatabase) !== -1) {
  print("Dropping existing database: " + targetDatabase);
  db.getSiblingDB(targetDatabase).dropDatabase();
}

use (targetDatabase);

// Get the list of collections from the old database
var oldCollections = db.getSiblingDB(oldDb).getCollectionNames();

// Copy each collection from the old database to the new one
oldCollections.forEach(function(collectionName) {
  var sourceCollection = db.getSiblingDB(oldDb)[collectionName];
  var targetCollection = db[collectionName];

  // Regular collections can be copied using find and insert
  sourceCollection.find().forEach(function(doc) {
      targetCollection.insert(doc);
  });
    
});
```
## Delete one
```js
var demoServiceId = new BinData(3, "DY85ZEcqnU2NdTziInJJWw=="); // UUID("64398f0d-2a47-4d9d-8d75-3ce22272495b");
try {
	db.getCollection("Services").deleteOne({ _id: demoServiceId });
} catch (e) {
	print(e);
}
```

## Delete many
```js
var demoSloId = new BinData(3, "9QHiRKmljEakC44TPktvqQ=="); // UUID("44e201f5-a5a9-468c-a40b-8e133e4b6fa9");
try {
	db.getCollection("Slos").deleteMany({
		"DefinitionUsed._id": demoSloId,
	});
} catch (e) {
	print(e);
}
```

## Python import as binary
utils.py
```python
import os
import sys
import json
import base64
import uuid

from pymongo import MongoClient
from bson.binary import Binary

def HexToBase64(hex_string):
    base64_string = base64.b64encode(bytes.fromhex(hex_string)).decode()
    
    # Add padding if necessary
    while len(base64_string) % 4 != 0:
        base64_string += '='
    
    return base64_string


def CSUUID(uuid_string):
    # Remove extra characters
    uuid_string = uuid_string.replace('{', '').replace('}', '').replace('-', '')
    
    # Rearrange the hex string
    a = uuid_string[6:8] + uuid_string[4:6] + uuid_string[2:4] + uuid_string[0:2]
    b = uuid_string[10:12] + uuid_string[8:10]
    c = uuid_string[14:16] + uuid_string[12:14]
    d = uuid_string[16:]
    hex_string = a + b + c + d
    
    # Convert hex to base64
    return HexToBase64(hex_string)

def UUIDtoBinary(id):
    return Binary(base64.b64decode(CSUUID(id)), 3)

```

import.py
```python
import os
import sys
import json

from pymongo import MongoClient
from utils import UUIDtoBinary, HexToBase64, CSUUID


def add_documents(file_path):
    # MongoDB connection string
    connection_string = "mongodb://localhost:27017/"
    
    # Connect to the MongoDB server
    client = MongoClient(connection_string)
    
    # Select the database
    database = client["SVC_SHIELD_LIVE"]
    
    # Select the collection
    collection = database["AppService"]

    # Drop existing collection documents
    collection.drop()

    # Open the JSON file and load the data
    with open(file_path, 'r') as file:
        data = json.load(file)
    
    # Insert each document from the JSON array into the collection
    for doc in data:
        # Use the 'id' property as the '_id' field
        doc['_id'] = UUIDtoBinary(doc.get('id'))

        if '_id' in doc:
            del doc['id']  # Remove 'id' field if present
        
        # Insert the document into the collection
        collection.insert_one(doc)

    print("added successfully!")

if __name__ == "__main__":
    # Set default file path if not provided
    if len(sys.argv) == 2:
        file_path = sys.argv[1]
    else:
        file_path = "C:\\temp\\services.json"
    
    # Check if the default file path exists
    if not os.path.exists(file_path):
        print(f"Error: File not found at the default path: {file_path}")
        sys.exit(1)
    
    add_documents(file_path)

```
