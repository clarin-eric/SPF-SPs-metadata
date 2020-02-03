
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
      //console.log(parse(this.responseXML.children[0]));
      generateHTML(parseRoot(this.responseXML.children[0]), this);
    }
  };
  xmlhttp.open("GET", encodeURI("../reports/aggregated_feed_master_sps_qa_report_results.xml"), true);
  xmlhttp.setRequestHeader("Content-Type", "text/xml");
  xmlhttp.send();

}

function generateHTML(xml, response) {
  // Generate page header
  $("#lastModified").append(xml.date);
  $("#lastCommitLink").append(xml.commit);
  $("#lastCommitLink").attr("href", "https://github.com/clarin-eric/SPF-SPs-metadata/commit/" + xml.commit);
  // Generate results table
  $("#reportTable").append("<thead class='thead-dark'><tr class='d-flex'><th class='col-2' scope='col'>entityID</th><th class='col-6' scope='col'>Issue</th><th class='col-4' scope='col'>Requirement explanation</th></tr></thead>");
  $("#reportTable").append("<tbody id='QAtableBody'>");
  var i;
  x = xml.children.sort(compare);
  for (i = 0; i < x.length; i++) { 
    requirement = x[i].children[2].textContent;
    colorClass = "table-warning";
    if (requirement.indexOf("Completely a requirement") !== -1) {
        colorClass = "table-danger";
    }
    enityID = x[i].children[0].textContent;
    $("#QAtableBody").append("<tr class='" + colorClass + " d-flex'><th class='col-2 text-break' scope='row'><a href='" + enityID +"'>" +
      enityID + "</a></th><td class='col-6 text-break'>" +
      x[i].children[1].textContent +
      "</td><td class='col-4 text-break'>" + requirement + "</td></tr>");
  }
}
loadXMLDoc();

$(document).ready(function(){
  $("#searchInput").on("keyup", function() {
    var value = $(this).val().toLowerCase();
    $("#QAtableBody tr").filter(function() {
      var enable = $(this).text().toLowerCase().indexOf(value) > -1
      $(this).toggle(enable).toggleClass('d-flex', enable)
    });
  });
});