function loadXMLDoc() {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      myFunction(this);
    }
  };
  xmlhttp.open("GET", "../master_sps_qa_report_results.xml", true);
  xmlhttp.setRequestHeader("Content-Type", "text/xml");
  xmlhttp.send();
}
function myFunction(xml) {
  var i;
  var xmlDoc = xml.responseXML;
  var table="<tr><th>entityID</th><th>Explanation</th><th>Requirement</th></tr>";
  var x = xmlDoc.getElementsByTagName("result");
  for (i = 0; i <x.length; i++) { 
    requirement = x[i].getElementsByTagName("requirement")[0].childNodes[0].nodeValue;
    colorClass = "yellow-row";
    if (requirement.indexOf("Completely a requirement") !== -1) {
        colorClass = "red-row";
    }
    enityID = x[i].getElementsByTagName("sp")[0].childNodes[0].nodeValue;
    table += "<tr class=" + colorClass + "><td><a href='" + enityID +"'>" +
    enityID +
    "</a></td><td>" +
    x[i].getElementsByTagName("explanation")[0].childNodes[0].nodeValue +
    "</td><td>" +
    requirement +
    "</td></tr>";
  }
  document.getElementById("report").innerHTML = table;
}
loadXMLDoc();