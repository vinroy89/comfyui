variable "RELEASE" {
    default = "5.0.0"
}

target "default" {
    dockerfile = "Dockerfile"
    tags = ["frenchyyz/comfy-ui:test"]
    contexts = {
        scripts = "../../container-template"
        proxy = "../../container-template/proxy"
    }
}
