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
function ToBinData(uuid) {
  var buffer = Buffer.from(uuid.replace(/-/g, ''), 'hex');

  var binData = Binary(buffer, 3);

  return binData;
}

var uuid = "44e201f5-a5a9-468c-a40b-8e133e4b6fa9";
var binData = ToBinData(uuid);

print("-- Results --------------------------------------------");
print("  - Original UUID:");
print("    └ UUID: \t\t\t\t" + uuid);
print("  - Converted to BinData:");
print("    └ BinData(3, id): \t\t" + binData.buffer.toString('base64'));
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
