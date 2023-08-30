local certManager = (import "cert-manager-mixin/mixin.libsonnet").grafanaDashboards;
local flux = (import "flux-mixin/mixin.libsonnet").grafanaDashboards;
local etcd = (import "mixin/mixin.libsonnet").grafanaDashboards;
local nodeExporter = (import "node-mixin/mixin.libsonnet") {
  _config+:: {
    nodeExporterSelector: 'job="node-exporter"',
    showMultiCluster: true,
  },
}.grafanaDashboards;
local kubernetes = (import "kubernetes-mixin/mixin.libsonnet") {
  _config+:: {
    cadvisorSelector: 'job="kubelet"',
    diskDeviceSelector: 'device=~"/dev/(%s)"' % std.join('|', self.diskDevices),
    kubeApiserverSelector: 'job="apiserver"',
    showMultiCluster: true,
  },
}.grafanaDashboards;
local prometheus = (import 'prometheus-mixin/mixin.libsonnet').grafanaDashboards;

{
  ["cert-manager/" + name]: certManager[name] for name in std.objectFields(certManager)
}+
{
  ["etcd/" + name]: etcd[name] for name in std.objectFields(etcd)
}+
{
  ["flux/" + name]: flux[name] for name in std.objectFields(flux)
}+
{
  ["node-exporter/" + name]: nodeExporter[name] for name in std.objectFields(nodeExporter)
}+
{
  ["kubernetes/" + name]: kubernetes[name] for name in std.objectFields(kubernetes)
}+
{
  ["prometheus/" + name]: prometheus[name] for name in std.objectFields(prometheus)
}
