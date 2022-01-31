resource "kubernetes_manifest" "storageclass_csi_rclone_rclone" {
  manifest = {
    "apiVersion" = "storage.k8s.io/v1"
    "kind" = "StorageClass"
    "metadata" = {
      "name" = "rclone"
      "namespace" = "csi-rclone"
    }
    "provisioner" = "cluster.local/nfs-server-nfs-server-provisioner"
  }
}
