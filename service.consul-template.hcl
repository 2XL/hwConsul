template {
  // path to template file
  source = "service.ctmpl",

  //
  destination = "service.cfg",


  command = "docker restart service"
}


// usage:
// consul-template -config service.consul-template.hcl
