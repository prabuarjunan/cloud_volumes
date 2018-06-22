var s_account = undefined;
var s_code_src = document.getElementsByTagName("script")[document.getElementsByTagName("script").length-1].src;
var currentUrl = window.location.href;

function getApiUrl() {
  var baseEndpoint = s_code_src.indexOf("cssweb") > -1 ? "https://mysupport.netapp.com/css/cssweb/js/" : "https://mysupport.netapp.com/NOW/public/js/";
  return baseEndpoint+'s_code.js';
}

// Get the current timestamp and convert it to PST
function getTimestamp() {
  var d = new Date();
  var nd = new Date(((d.getTime()+(d.getTimezoneOffset()*60000))+(3600000*-7)));
  return {"timestamp":nd.getHours()+":"+(nd.getMinutes()<10?'0':'') + nd.getMinutes(), "day":['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'][nd.getDay()]};
}

function getUrlContext() {
  var uhref = window.location.href;
  var url = uhref.substring(uhref.indexOf('/', 8) + 1);
  var arr = url.split("/");
  return arr[0];
}

function getUrlContext2() {
  var uhref = window.location.href;
  var url = uhref.substring(uhref.indexOf('/', 8) + 1);
  var arr = url.split("/");
  return arr[0] + "/" + arr[1];
}

function setDefaultParams(cloudParams) {
  cloudParams = cloudParams || {};
  var hrefChunks = window.location.href.split('/');
  var projectId = 'CloudDocs';
  var productId = hrefChunks[3];
  var lang = hrefChunks[4];

  // For base site, set product to home
  if (document.title.indexOf("NetApp Cloud Documentation |") != -1) {
    productId = "home";
    lang = hrefChunks[3];
  }

  var _date = getTimestamp();

  cloudParams.channel = projectId+':'+productId;
  cloudParams.pageName = 'NSS:Documentation:'+projectId+':'+productId+':'+document.title;
  cloudParams.pageType = "html";
  cloudParams.server = projectId;

  cloudParams.prop1 = getUrlContext();
  cloudParams.prop2 = getUrlContext2();
  cloudParams.prop35 = lang;
  cloudParams.prop37 = cloudParams.server;
  cloudParams.prop39 = s_account;
  cloudParams.prop52 = _date.timestamp;
  cloudParams.prop53 = _date.day;

  cloudParams.eVar35 = cloudParams.prop35;
  cloudParams.eVar37 = cloudParams.prop37;
  cloudParams.eVar39 = cloudParams.prop39;
}

function sendAnalyticsPageLoad(cloudParams) {
  cloudParams = cloudParams || {};
  $.getScript(getApiUrl(), function () {
    if (typeof(s) == "undefined") {
      return;
    }

    $.extend(s,cloudParams);
    s.t();
  });
}

function sendAnalyticsSearchClick(searchParams, cloudParams) {
  cloudParams = cloudParams || {};
  cloudParams.prop28 = cloudParams.channel+":Search Results";
  cloudParams.prop29 = searchParams.searchString;
  cloudParams.prop50 = searchParams.href;
  cloudParams.linkTrackVars = "prop28,prop29,prop50";
  cloudParams.linkTrackEvents = "None"; //(this allows to trigger following events)

  $.getScript(getApiUrl(), function () {
    if (typeof(s) == "undefined") {
      return;
    }

    $.extend(s,cloudParams);
    s.tl(true, "o", "Link Clicked");
    delete cloudParams.prop28;
    delete cloudParams.prop29;
    delete cloudParams.prop50;
    delete s.prop28;
    delete s.prop29;
    delete s.prop50;
  });
}

$(document).ready(function() {
  if (currentUrl == null) {
    return;
  }

  if (currentUrl.indexOf('.netapp.com') > -1) {
    s_account = "networkapplsupport-global-dev"; //FIXME: Change to networkapplsupport-global
  } else if (currentUrl.indexOf('localhost') > -1) {
    s_account = "networkapplsupport-global-dev";
  }

  var cloudParams = {};
  setDefaultParams(cloudParams);

  if (!cloudParams.hasOwnProperty('prop35') || (typeof cloudParams.prop35 === "undefined") || cloudParams.prop35.length == 0) {
    return;
  }

  sendAnalyticsPageLoad(cloudParams);

  $('#results-container').on("click", "a", function(){
    var searchParams = {
      "html": $( this ).prop("outerHTML"),
      "pageName": $( this ).html(),
      "searchString": $('#search-input').val(),
      "href": $( this ).attr("href")
    };

    sendAnalyticsSearchClick(searchParams, cloudParams);
  });

});
