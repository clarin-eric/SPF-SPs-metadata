
// compare function for sorting
function compare(a,b) {
  if (a.children[0].textContent < b.children[0].textContent)
     return -1;
  if (a.children[0].textContent > b.children[0].textContent)
    return 1;
  if (a.children[2].textContent.indexOf("Completely a requirement") !== -1 && b.children[2].textContent.indexOf("Completely a requirement") === -1)
    return -1;
  if (a.children[2].textContent.indexOf("Completely a requirement") === -1 && b.children[2].textContent.indexOf("Completely a requirement") !== -1)
    return 1;
  return 0;
}

function parse(node) {
    if (node.nodeType != 1) return null;
    var result = {textContent: node.textContent};
    var children = [];
    for (var i = 0; i < node.childNodes.length; i++) {
        var child = parse(node.childNodes[i]);
        if (child)
        {
            children.push(child);
        }
    }    
    result.children = children;
    return result;
}

function parseRoot (root) {
  if (root.nodeType != 1) return null;
  var report = parse(root.children[2]);
  report.date = root.children[0].textContent;
  report.commit = root.children[1].textContent;
  return report;
}

function loadXMLDoc() {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      generateHTML(parseRoot(this.responseXML.children[0]), this);
    }
  };
  // Use URL query string to specify which xml report to load
  var reportURL = "../reports/aggregated_feed_master_sps_qa_report_results.xml";
  if ( location.search === "" ) {
    xmlhttp.open("GET", encodeURI(reportURL), true);
  } else {
    reportURL = "../reports/" + location.search.substring(1);
    xmlhttp.open("GET", encodeURI(reportURL), true);
  }
  xmlhttp.setRequestHeader("Content-Type", "text/xml");
  xmlhttp.send();
}

function generateHTML(xml, response) {
  // Generate page header
  $("#lastModified").append(xml.date);
  $("#lastCommitLink").append(xml.commit);
  $("#lastCommitLink").attr("href", "https://github.com/clarin-eric/SPF-SPs-metadata/commit/" + xml.commit);
  // Fill in the page global information according to the html template being used
  if (location.pathname.endsWith("master_qa_report.html")) {
    $("#reportTable").append("<thead class='thead-dark'><tr class='d-flex'><th class='col-2' scope='col'>entityID</th><th class='col-5' scope='col'>Issue</th><th class='col-4' scope='col'>Requirement explanation</th><th class='col-1 text-center' scope='col'>Last modified<br>Relevant commit</th></tr></thead>");
  } else if (location.pathname.endsWith("sp_qa_report.html")) {
    $("#reportTable").append("<thead class='thead-dark'><tr class='d-flex'><th class='col-8' scope='col'>Issue</th><th class='col-4' scope='col'>Requirement explanation</th></tr></thead>");
    if (typeof xml.children[0] != "undefined") {
      $("#entityID").append(xml.children[0].children[0].textContent);
    } else {
      $("#reportTable").append("<tbody id='QAtableBody'>");
      $("#QAtableBody").append("<tr class='table-success d-flex'><td class='col-12 text-break'>There are no outstanding issues for this Service Provider.</td></tr>");
    }
  }
  // Generate results table
  $("#reportTable").append("<tbody id='QAtableBody'>");
  var i;
  x = xml.children.sort(compare);
  for (i = 0; i < x.length; i++) { 
    requirement = x[i].children[2].textContent;
    colorClass = "table-warning";
    if (requirement.indexOf("Completely a requirement") !== -1) {
        colorClass = "table-danger";
    }
    // Fill in the table according to the html template in use
    if (location.pathname.endsWith("master_qa_report.html")) {
      entityID = x[i].children[0].textContent;
      // href for individual reports of each SP
      bareEntityID = entityID.replace(/https?:\/\//i, "");
      standalone_reportPath = encodeURIComponent(bareEntityID + "_sps_qa_report_results.xml");
      $("#QAtableBody").append("<tr class='" + colorClass + " d-flex'><th class='col-2 text-break' scope='row'><a href='sp_qa_report.html?" +
        standalone_reportPath + "'>" +
        entityID + "</a></th><td class='col-5 text-break'>" +
        x[i].children[1].textContent +
        "</td><td class='col-4 text-break'>" + requirement +
        "</td><td id='cell"+ i +"_lastm' class='col-1 text-break text-center align-middle'></td>" + "</tr>");
        getLastModified(standalone_reportPath, i);
    } else if (location.pathname.endsWith("sp_qa_report.html")) {
      $("#QAtableBody").append("<tr class='" + colorClass + " d-flex'><td class='col-8 text-break'>" +
        x[i].children[1].textContent +
        "</td><td class='col-4 text-break'>" + requirement + "</td></tr>");
    }
  }
}

function getLastModified(reportPath, i) {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      lastmDateValue = this.responseXML.children[0].children[0].textContent;
      lastmCommitValue = this.responseXML.children[0].children[1].textContent;
      lastmDateHTML = "<span>" + new Date(lastmDateValue).toUTCString().substring(4, 25) + "</span>";
      lastmCommitHTL = "<a href=\"https://github.com/clarin-eric/SPF-SPs-metadata/commit/" + lastmCommitValue + "\">" + lastmCommitValue.substring(0, 7) + "</a>";

      cellid = "cell" + i + "_lastm";
      $("#" + cellid + "").append(lastmDateHTML + "<br>" + lastmCommitHTL);
    }
  };
  xmlhttp.open("GET", encodeURI("../reports/" + reportPath), true);
  xmlhttp.setRequestHeader("Content-Type", "text/xml");
  xmlhttp.send();
}

loadXMLDoc();

$(document).ready(function(){
  $("#searchInput").val('');
  $("#searchInput").on("keyup", function() {
    var value = $(this).val().toLowerCase();
    $("#QAtableBody tr").filter(function() {
      var enable = $(this).text().toLowerCase().indexOf(value) > -1
      $(this).toggle(enable).toggleClass('d-flex', enable)
    });
  });
});