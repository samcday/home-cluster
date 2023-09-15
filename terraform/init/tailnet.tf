resource "tailscale_acl" "acl" {
  acl = jsonencode({
    "autoApprovers" : {
      "routes" : {
        # home-cluster Pod CIDRs
        "172.30.0.0/16" : ["tag:home-cluster"],
        "fdab:bc3f:3e04::/56" : ["tag:home-cluster"],

        # home-cluster Service CIDRs
        "172.31.0.0/16" : ["tag:home-cluster"],
        "fd7f:bc81:7c5c::/112" : ["tag:home-cluster"],

        # home-cluster control-plane endpoint VIP
        "172.29.0.1/32" : ["tag:home-cluster"],
      },
    },

    "tagOwners" : {
      "tag:home-cluster" : ["autogroup:admin"],
    },

    "acls" : [
      { "action" : "accept", "src" : ["*"], "dst" : ["*:*"] },
    ],

    "tests" : [
      {
        "src" : "tag:home-cluster",
        "accept" : ["172.29.0.1:6444"],
      },
    ],
  })
}
