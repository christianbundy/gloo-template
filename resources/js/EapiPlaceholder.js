// elementAPI placeholders for local testing

// initial user databag contents
var userData = {

/*
  // Top Ten Needs
  "ttnAnswers"        : '{"1":2,"2":-1,"3":1,"4":-2,"5":-1,"6":2,"7":0,"8":1,"9":-1,"10":-2,"11":2,"12":-1,"13":-1,"14":2,"15":-2,"16":-1,"17":1,"18":1,"19":-1,"20":1,"21":-1,"22":2,"23":-2,"24":2,"25":-1,"26":-2,"27":1,"28":2,"29":2,"30":2,"31":0,"32":1,"33":2,"34":2,"35":-1,"36":1,"37":1,"38":-2,"39":-2,"40":2,"41":2,"42":-2,"43":0,"44":2,"45":-2,"46":0,"47":2,"48":-2,"49":2,"50":0}',
  "ttnSelectedNeed"   : 'encouragement',
*/

/*
  // Picture This
  "sharedData"        : '{ "createdDTS" : 1123123123123, "currentRound" : 3, "roundWordID" : 67 ,"roundCardIDs" : [2, 98, 3, 4, 71], "currentScore" : 30, "highScore" : 30, "unusedWordIDs" : null }',
  "selectedCards"     : '{ "1":0, "2":98, "3":3 }',
  "lastRoundResults"  : '{ "viewed": 1, "roundNumber": 1, "wordID": 66, "cardIDs": [2,99,3,4,71], "userCardSelections": { "1": 2, "2": 98, "3": 3 }, "partnerCardSelections": { "1": 98, "2": 2, "3": 4 }, "matchingCardIDs": [], "commonCardIDs": [2,98], "singleCardIDs": [3,4] }',
*/

/*
  // Buzz Off
  "availableNormalQuestions"  : '[0,1,2,4,5,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122]',
  "availableBonusQuestions"   : '[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73]',
  "highScores"                : '{"user":300,"partner":400,"team":500}',
*/

  // Pants On Fire
  "pof_challenge"       : '{ "theme" : "worst haircut", "truth1" : "totally shaved, eighth grade", "lie" : "something", "truth2" : "something else" }',
  "pof_temp_challenge"  : '{ "theme" : "worst haircut", "truth1" : "totally shaved, eighth grade" }',
  "pof_score"           : null,
  "pof_viewed_results"  : 'true',
  "pof_wins"            : 2,

/*
  // Truth or Dare
  "player1Info"         : '{"name":"Liam","truthCount":0,"dareCount":0}',
  "player2Info"         : '{"name":"Emma","truthCount":0,"dareCount":0}',
*/
}

// initial partner databag contents
var partnerData = {

/*
  // Picture This
  "selectedCards"     : '{ "1":98, "2":2, "3":4 }',
*/

  // Pants On Fire
  "pof_challenge"       : '{ "theme" : "worst haircut", "truth1" : "totally shaved, eighth grade", "lie" : "psssst... this one\'s the lie", "truth2" : "something else" }',
  "pof_score"           : 20,
  "pof_viewed_results"  : 'true',
  "pof_wins"            : 4,

}

// metrics and their default values
var defaultMetrics = {

  // default
  "score"         : 0,

/*
  // Picture This
  "homenav"       : 0,
  "dashboardnav"  : 0,
  "selectionnav"  : 0,
  "resultsnav"    : 0,
*/

/*
  // Buzz Off
  "homenav"       : 1,
  "gameselectnav" : 1,
*/

  // Pants On Fire
  "one_one"       : 1,
  "one_two"       : 1,
  "two_one"       : 1,
  "two_two"       : 1,
  "two_three"     : 1,
  "two_four"      : 1,
  "two_five"      : 1,
  "three_one"     : 1,

}

// elementAPI object
var elementAPI = {

  user : function() {
    return {
      data : {
        first_name : '[user]'
      },
      name : function() { return "[user]"; }
    }
  },
  partner : function() {
    return {
      data : {
        first_name : '[partner]'
      },
      name : function() { return "[partner]"; }
    }
  },
  userData : function() {
    if(!this.internalUserData) { this.internalUserData=new DataBag(userData); }
    return this.internalUserData;
  },
  partnerData : function() {
    if(!this.internalPartnerData) { this.internalPartnerData=new DataBag(partnerData); }
    return this.internalPartnerData;
  },
  metrics : function() {
    if(!this.internalMetrics) { this.internalMetrics=setupMetrics(defaultMetrics); }
    return this.internalMetrics;
  },
  refresh : function() {
    location.reload(true);
  },
	sendMessage : function(msg) {
	}
};

// simulated databag object
function DataBag(data)
{
  // public property
  this.values = {};

  // initialize
  for(var prp in data) {
    if(data.hasOwnProperty(prp)) {
      this.values[prp]=data[prp];
    }
  }

  // public methods
  this.setValue = function(name, value) {
    this.values[name]=value;
    console.log('EAPI: set databag key ' + name + ' to value ' + value);
  };
  this.getValue = function(name) {
    return this.values[name];
  };
}

// simulated metric object
function Metric(name, value)
{
  // initialize
  this.data = {
    'id'    : 0,        // hardcode ID to 0
    'name'  : name,
    'value' : value
  };

  // public methods
  this.updateValueForMetric = function(val) {
    var prvval = this.data.value;
    this.data.value = val;
    console.log('EAPI: set metric ' + this.data.name + ' to ' + this.data.value + ' (prv ' + prvval + ')');
  };
  this.value = function() {
    return this.data.value;
  }
};

// returns a new master Metrics object which contains all Metric objects
function setupMetrics(defaultMetrics)
{
  var mstobj = {};  // master metrics object
  
  // initialize
  for(var prp in defaultMetrics) {
    if(defaultMetrics.hasOwnProperty(prp)) {
      mstobj[prp] = new Metric(prp,defaultMetrics[prp]);
    }
  }

  // complete
  return mstobj;
}
