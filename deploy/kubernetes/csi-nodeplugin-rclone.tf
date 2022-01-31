resource "kubernetes_manifest" "daemonset_csi_rclone_csi_nodeplugin_rclone" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "DaemonSet"
    "metadata" = {
      "name" = "csi-nodeplugin-rclone"
      "namespace" = "csi-rclone"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "csi-nodeplugin-rclone"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "csi-nodeplugin-rclone"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--v=5",
                "--csi-address=/plugin/csi.sock",
                "--kubelet-registration-path=/var/lib/kubelet/plugins/csi-rclone/csi.sock",
              ]
              "env" = [
                {
                  "name" = "KUBE_NODE_NAME"
                  "valueFrom" = {
                    "fieldRef" = {
                      "fieldPath" = "spec.nodeName"
                    }
                  }
                },
              ]
              "image" = "quay.io/k8scsi/csi-node-driver-registrar:v1.1.0"
              "lifecycle" = {
                "preStop" = {
                  "exec" = {
                    "command" = [
                      "/bin/sh",
                      "-c",
                      "rm -rf /registration/csi-rclone /registration/csi-rclone-reg.sock",
                    ]
                  }
                }
              }
              "name" = "node-driver-registrar"
              "volumeMounts" = [
                {
                  "mountPath" = "/plugin"
                  "name" = "plugin-dir"
                },
                {
                  "mountPath" = "/registration"
                  "name" = "registration-dir"
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
              "lifecycle" = {
                "postStart" = {
                  "exec" = {
                    "command" = [
                      "/bin/sh",
                      "-c",
                      "mount -t fuse.rclone | while read -r mount; do umount $(echo $mount | awk '{print $3}') ; done",
                    ]
                  }
                }
              }
              "name" = "rclone"
              "securityContext" = {
                "allowPrivilegeEscalation" = true
                "capabilities" = {
                  "add" = [
                    "SYS_ADMIN",
                  ]
                }
                "privileged" = true
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/plugin"
                  "name" = "plugin-dir"
                },
                {
                  "mountPath" = "/rclone-service-account"
                  "name" = "rclone-service-account"
                },
                {
                  "mountPath" = "/var/lib/kubelet/pods"
                  "mountPropagation" = "Bidirectional"
                  "name" = "pods-mount-dir"
                },
              ]
            },
          ]
          "dnsPolicy" = "ClusterFirstWithHostNet"
          "hostNetwork" = true
          "imagePullSecrets" = [
            {
              "name" = "mediafs"
            },
          ]
          "serviceAccountName" = "csi-nodeplugin-rclone"
          "volumes" = [
            {
              "name" = "rclone-service-account"
              "secret" = {
                "secretName" = "rclone-service-account"
              }
            },
            {
              "hostPath" = {
                "path" = "/var/lib/kubelet/plugins/csi-rclone"
                "type" = "DirectoryOrCreate"
              }
              "name" = "plugin-dir"
            },
            {
              "hostPath" = {
                "path" = "/var/lib/kubelet/pods"
                "type" = "Directory"
              }
              "name" = "pods-mount-dir"
            },
            {
              "hostPath" = {
                "path" = "/var/lib/kubelet/plugins_registry"
                "type" = "DirectoryOrCreate"
              }
              "name" = "registration-dir"
            },
          ]
        }
      }
    }
  }
}
