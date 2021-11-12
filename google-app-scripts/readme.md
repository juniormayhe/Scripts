# read data from Jira

spreadsheet is handled by SheetConverter class and it does not use Google Sheets API service.

Settings.gs
```js
const Settings = {
  timeZone: "GMT+1",
  dayDateFormat: "yyyy-MM-dd",
  dateFormat: "yyyy-MM-dd HH:mm:ss",
  changesOlderThanNbrOfDays: 3, //days
  jira:
  {
    email: 'email@email.com',
    token: 'xyz',
    browseUrl: 'https://company.atlassian.net/browse/',
    searchUrl: 'https://company.atlassian.net/rest/api/2/search/',
    maxResults: 5
  },
  lpmSheet: {
    sheedId: '10EZY43ggo2_...',
    sheetTab: 'jira-db'
  }
}
```
JiraGateway.gs
```js
class JiraGateway {

  static buildPayload(jql, fields, changelog, maxResults, startAt) {
    var payload = {
      "expand": changelog ? ["changelog"] : [],
      "jql": jql,
      "maxResults": maxResults,
      "fieldsByKeys": false,
      "fields": fields,
      "startAt": startAt
    }

    return payload
  }

  static searchItems(jql, fields, changelog, maxResults, startAt) {

    const payload = JiraGateway.buildPayload(jql, fields, changelog, maxResults, startAt)

    var options = {
      "method": "post",
      "contentType": "application/json",
      "headers": {
        "Authorization": "Basic " + Utilities.base64Encode(Settings.jira.email + ':' + Settings.jira.token)
      },
      "payload": JSON.stringify(payload)
    }

    try {
      var response = UrlFetchApp.fetch(Settings.jira.searchUrl, options)
      return JSON.parse(response.getContentText())
    } catch (e) {
      Logger.log(e)
      throw ("Error getting Jira items: " + e)
    }
  }

}
```
SheetConverter.gs
```js
/*
Create and manage an object from sheet values

https://ramblings.mcpher.com/apps-script/apps-script-v8/multiple-script-files/
*/
class SheetConverter {

  static makeValues({ data }) {
    // derive the headers from the data 
    const headers = Object.keys(data.reduce((p, row) => {
      Object.keys(row).forEach(col => p[col] = col)
      return p
    }, {}))
    // combine the headers and the values
    return [headers].concat(data.map(row => headers.map(col => row[col])))
  }

  static makeData({ values }) {
    const [headers, ...data] = values
    return {
      data: data.map(row => headers.reduce((p, c, i) => {
        p[c] = row[i]
        return p
      }, {})),
      headers
    }
  }

  constructor({ mySheet }) {
    this._mySheet = mySheet
    this.readValues()
  }

  // convert data to values and store
  setValues({ data }) {
    this.values = this.constructor.makeValues({ data: data || this.data })
  }
  set values(values) {
    this._values = values
  }
  get values() {
    return this._values
  }

  set headers(headers) {
    this._headers = headers
  }
  get headers() {
    return this._headers
  }

  // convert values to data and store
  setData({ values }) {
    const { headers, data } = this.constructor.makeData({ values: values || this.values })
    this.headers = headers
    this.data = data
    return this.data
  }

  set data(data) {
    this._data = data
  }
  get data() {
    return this._data
  }

  get mySheet() {
    return this._mySheet
  }

  writeData(options) {
    // convert data to values and write to sheet
    const data = (options && options.data) || this.data
    this.setValues({ data })
    this.writeValues()
  }

  writeValues(options) {
    const values = (options && options.values) || this.values
    this.mySheet.setValues({ values })
  }

  readValues() {
    this.values = this.mySheet.getValues()
    this.setData({ values: this.values })
    return this.values
  }
}
```

SheetWrapper.gs
```js
/*
Interact with Google Sheets

https://ramblings.mcpher.com/apps-script/apps-script-v8/multiple-script-files/
 */
class SheetWrapper {
  static open({ sheetName, create, spreadSheetId }) {
    const ss = (spreadSheetId && SpreadsheetApp.openById(spreadSheetId)) || SpreadsheetApp.getActiveSpreadsheet()
    return ss.getSheetByName(sheetName) || (create && ss.insertSheet(sheetName))
  }
  static replaceValues({ sheet, values }) {
    sheet.getDataRange().clear()
    if (values.length && values[0] && values[0].length) {
      const range = sheet.getRange(1, 1, values.length, values[0].length)
      return range.setValues(values)
    }
  }
  static appendRow({ sheet, rows }) {
    if (rows && rows.length) {
      rows.forEach(r => sheet.appendRow(r))
    }
  }

  constructor(options) {
    this._sheet = this.constructor.open(options)
  }
  get sheet() {
    return this._sheet
  }
  get dataRange() {
    return this.sheet.getDataRange()
  }
  // get currently cached valued
  get values() {
    // if we dont have any then get some
    return this._values || this.getValues()
  }
  // get values from sheet
  getValues() {
    // caching for later
    this._values = this.dataRange.getValues()
    return this._values
  }
  // set currently cached values
  set values(val) {
    this._values = val
  }
  // write current (or new) values to sheet
  setValues({ values }) {
    if (values) {
      this.values = values
    }
    return this.constructor.replaceValues({ sheet: this.sheet, values: this.values })
  }

  get lastRowIndex() {
    return this.sheet.getLastRow()
  }

  // append rows
  appendRows({ rows }) {
    if (rows) {
      return this.constructor.appendRow({ sheet: this.sheet, rows: rows })
    }
  }

  /* aux methods*/
  getCellRangeByRowColumnName(columnName, row) {
    //let data = this.sheet.getDataRange().getValues()
    let data = this.sheet.getRange(1, 1, 1, this.sheet.getMaxColumns()).getValues() // get header only to be faster
    let column = data[0].indexOf(columnName)
    if (column != -1) {
      return this.sheet.getRange(row, column + 1, 1, 1)
    }
  }

  getCellByRowColumnName(columnName, row) {
    return this.getCellRangeByRowColumnName(columnName, row)
  }

  setCellValueByRowColumnName(columnName, row, value) {
    let cell = this.getCellByRowColumnName(columnName, row)
    if (cell != null) {
      return cell.setValue(value)
    }
  }
}
```
StoryReader.gs
```js
// read stories, bugs and other epic subitems
class StoryReader
{

  static getStory(key) {
    let startAt = 0;
    const EPIC_LINK = "customfield_10700";
    const jql = `"key" = ${key}`;
    const result = JiraGateway.searchItems(
      jql, 
      ["summary", "description", "status", "created", "priority", "labels", "issuelinks", EPIC_LINK], 
      false, 
      Settings.jira.maxResults, 
      startAt);   
    return result;
  }
}
```
EpicReader.gs
```js
class EpicReader
{

  static getEpic(key) {
    let startAt = 0;

    const jql = `"key" = ${key}`;
    const result = JiraGateway.searchItems(
      jql, 
      ["key","summary", "description", "status", "created", "priority", "labels", "issuelinks", "customfield_10700"], 
      false, 
      Settings.jira.maxResults, 
      startAt);

    
    return result;
  }
}
```
PUBReader.gs
```js
class PUBReader {
    
  static getPubs() {

    let pubs = [];
    let startAt = 0;

    const jql = `project = "PUB" AND issuetype = "Change" AND created > ${DateHelper.getLoopbackDate()} AND status not in (Draft, Canceled, Submitted, "Awaiting CAB approval")`
    let rowCount = 0;
    do {
      const result = JiraGateway.searchItems(
        jql, 
        ["summary", "description", "status", "created", "priority", "labels", "issuelinks"], 
        false, 
        Settings.jira.maxResults, 
        startAt);
      
      rowCount = result?.issues?.length ?? 0;
      if (rowCount > 0) {
        
        pubs.push(result);
      }
      startAt += rowCount;
    }
    while (rowCount > 0);
    
    return pubs;
  }
}

```

DataHelper.gs
```js
class DateHelper {
  
  static getLoopbackDate() {
    const MILLIS_PER_HOUR = 1000 * 60 * 60;
    const MILLIS_PER_DAY = MILLIS_PER_HOUR * 24;

    const lookback = new Date(new Date().getTime() - (Settings.changesOlderThanNbrOfDays * MILLIS_PER_DAY));

    const lookbackDate = Utilities.formatDate(lookback, Settings.timeZone, Settings.dayDateFormat)
    return lookbackDate;
  }
}
```
main.gs
```js
function main() {

  const sheet = new SheetWrapper( { sheetName: Settings.lpmSheet.sheetTab, spreadSheetId: Settings.lpmSheet.sheedId } );
  let shob = new SheetConverter( {mySheet: sheet } );
  shob.data=[];

  var pubs = PUBReader.getPubs();
  
  pubs.forEach(pub => {
    
    findStory(pub, shob);
  });

  shob.writeData();
}

function findStory(pub, shob){
  pub.issues.forEach(pubIssue => {
    
    pubIssue.fields.issuelinks.forEach(pubIssueLink => {
    
      if (pubIssueLink.outwardIssue){
        
        var story = StoryReader.getStory(pubIssueLink.outwardIssue.key);
        findEpic(story, pubIssue.key, shob);
      }
    });
  });
}

function findEpic(story, pubKey, shob) {
  story.issues.forEach(storyIssue => {
            
  const epicKey = storyIssue.fields?.customfield_10700 ?? undefined;
  if (epicKey) {
    
    const epic = EpicReader.getEpic(epicKey);
    findLpm(epic, storyIssue, pubKey, shob);
  }
  
  });
}

function findLpm(epic, storyIssue, pubKey, shob){
  let rows = [];
  epic.issues.forEach(epicIssue => {
    // when the epic has inwardIssue set, the inward issue is the parent LPM. you can read it as the LPM contains the epic
    // when the epic has outwardIssue set, the outward issue is the resolved LPM. you can read it as the epic resolves other LPM 
    // and maybe the epic doesnt have a parent LPM, it's hard to reason the user intention when creating the relations
    
    epicIssue.fields.issuelinks.forEach(epicIssueLink => {
      //console.log(`pub ${pubKey} ~ lpm ${epicIssueLink?.inwardIssue?.key ?? "N/A"} > epic ${epicIssue.key} > story ${storyIssue.key}. Epic resolves ${epicIssueLink?.outwardIssue?.key ?? "N/A"}`);
      rows.push({ 
        pubKey: pubKey, 
        lpmKey: epicIssueLink?.inwardIssue?.key ?? "N/A", 
        epicKey: epicIssue.key,
        storyKey: storyIssue.key,
        resolvesKey: epicIssueLink?.outwardIssue?.key ?? "N/A"
      });
    });
  });
  //console.log('rows', rows);

  shob.data.push(...rows); 
  
}
```
