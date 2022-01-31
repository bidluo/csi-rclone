resource "kubernetes_manifest" "statefulset_csi_rclone_csi_controller_rclone" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "StatefulSet"
    "metadata" = {
      "name" = "csi-controller-rclone"
      "namespace" = "csi-rclone"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "csi-controller-rclone"
        }
      }
      "serviceName" = "csi-controller-rclone"
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "csi-controller-rclone"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--v=5",
                "--csi-address=$(ADDRESS)",
              ]
              "env" = [
                {
                  "name" = "ADDRESS"
                  "value" = "/csi/csi.sock"
                },
              ]
              "image" = "quay.io/k8scsi/csi-attacher:v1.1.1"
              "imagePullPolicy" = "Always"
              "name" = "csi-attacher"
              "volumeMounts" = [
                {
                  "mountPath" = "/csi"
                  "name" = "socket-dir"
                },
              ]
            },
            {
              "args" = [
                "--v=5",
                "--pod-info-mount-version=\"v1\"",
                "--csi-address=$(ADDRESS)",
              ]
              "env" = [
                {
                  "name" = "ADDRESS"
                  "value" = "/csi/csi.sock"
                },
              ]
              "image" = "quay.io/k8scsi/csi-cluster-driver-registrar:v1.0.1"
              "name" = "csi-cluster-driver-registrar"
              "volumeMounts" = [
                {
                  "mountPath" = "/csi"
                  "name" = "socket-dir"
                },
              ]
            },
            {
              "args" = [
                "--nodeid=$(NODE_ID)",
                "--endpoint=$(CSI_ENDPOINT)",
              ]
              "env" = [
                {
                  "name" = "NODE_ID"
                  "valueFrom" = {
                    "fieldRef" = {
                      "fieldPath" = "spec.nodeName"
                    }
                  }
                },
                {
                  "name" = "CSI_ENDPOINT"
                  "value" = "unix://plugin/csi.sock"
                },
              ]
              "image" = "registry.digitalocean.com/mediafs/csi-rclone:latest"
              "imagePullPolicy" = "Always"
              "name" = "rclone"
              "volumeMounts" = [
                {
                  "mountPath" = "/plugin"
                  "name" = "socket-dir"
                },
                {
                  "mountPath" = "/rclone-service-account"
                  "name" = "rclone-service-account"
                },
              ]
            },
          ]
          "imagePullSecrets" = [
            {
              "name" = "mediafs"
            },
          ]
          "serviceAccountName" = "csi-controller-rclone"
          "volumes" = [
            {
              "emptyDir" = {}
              "name" = "socket-dir"
            },
            {
              "name" = "rclone-service-account"
              "secret" = {
                "secretName" = "rclone-service-account"
              }
            },
          ]
        }
      }
    }
  }
}
