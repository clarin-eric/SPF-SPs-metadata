
// compare function for sorting
function compare(a,b) {
  if (a.children[0].textContent < b.children[0].textContent)
     return -1;
  if (a.children[0].textContent > b.children[0].textContent)
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

function loadXMLDoc() {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      console.log(parse(this.responseXML.children[0]));
      generateHTML(parse(this.responseXML.children[0]));
    }
  };
  xmlhttp.open("GET", "../master_sps_qa_report_results.xml", true);
  xmlhttp.setRequestHeader("Content-Type", "text/xml");
  xmlhttp.send();
}

function generateHTML(xml) {
  var i;
  x = xml.children.sort(compare);;
  var table="<tr><th>entityID</th><th>Issue</th><th>Requirement explanation</th></tr>";
  for (i = 0; i < x.length; i++) { 
    requirement = x[i].children[2].textContent;
    colorClass = "yellow-row";
    if (requirement.indexOf("Completely a requirement") !== -1) {
        colorClass = "red-row";
    }
    enityID = x[i].children[0].textContent;
    table += "<tr class=" + colorClass + "><td><a href='" + enityID +"'>" +
      enityID + "</a></td><td>" +
      x[i].children[1].textContent +
      "</td><td>" + requirement + "</td></tr>";
  }
  document.getElementById("report").innerHTML = table;
}
loadXMLDoc();