dependency "cluster" {
  config_path = "../cluster"
}

terraform {
  source = format(include.root.locals.module_source, "eks/storageclass") # or inline
}

inputs = {
  cluster_endpoint = dependency.cluster.outputs["api-server-endpoint"]
  cluster_ca       = dependency.cluster.outputs["certificate-authority"][0]["data"]
  cluster_name     = dependency.cluster.outputs.cluster_name
  region           = dependency.cluster.outputs.region
}
