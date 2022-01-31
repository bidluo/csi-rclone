resource "kubernetes_manifest" "serviceaccount_csi_rclone_csi_controller_rclone" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "name" = "csi-controller-rclone"
      "namespace" = "csi-rclone"
    }
  }
}

resource "kubernetes_manifest" "clusterrole_external_controller_rclone" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "name" = "external-controller-rclone"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "persistentvolumes",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "update",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "csi.storage.k8s.io",
        ]
        "resources" = [
          "csinodeinfos",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "storage.k8s.io",
        ]
        "resources" = [
          "volumeattachments",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "update",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_csi_attacher_role_rclone" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "csi-attacher-role-rclone"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "external-controller-rclone"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "csi-controller-rclone"
        "namespace" = "csi-rclone"
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrole_csi_cluster_driver_registrar_role" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "name" = "csi-cluster-driver-registrar-role"
    }
    "rules" = [
      {
        "apiGroups" = [
          "csi.storage.k8s.io",
        ]
        "resources" = [
          "csidrivers",
        ]
        "verbs" = [
          "create",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "apiextensions.k8s.io",
        ]
        "resources" = [
          "customresourcedefinitions",
        ]
        "verbs" = [
          "create",
          "list",
          "watch",
          "delete",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_csi_cluster_driver_registrar_binding" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "csi-cluster-driver-registrar-binding"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "csi-cluster-driver-registrar-role"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "csi-controller-rclone"
        "namespace" = "csi-rclone"
      },
    ]
  }
}
