## 🚀 SDXL Comfy UI Template for RunPod

### 📝 General Information

⚠️ **Important: This template is pre-configured and should work seamlessly upon deployment, without requiring adjustments for encrypted volumes.**

Welcome to the RunPod SDXL Comfy UI template! This setup is tailored for enhanced user experience with a wide range of models pre-installed for your convenience. While we package this for easier deployment, please direct specific inquiries about stable diffusion or the Comfy UI to the appropriate communities or the original developers.

🔵 **Ensure the GPU Utilization % reads 0 before connecting to avoid a 502 error. This indicates that the pod is fully prepared for your use.**

### ⚙️ Launch Parameters

The launch configuration for SDXL Comfy UI is preset; however, you can modify parameters as needed. Edit the startup script or configuration files according to your requirements. Restart your pod via the pod's menu to apply any changes.

### 📥 Integrating Your Models

To use custom models with your SDXL Comfy UI, consider uploading them directly through `runpodctl`, or transfer them via cloud services like Google Drive. Follow the instructions for `runpodctl` [here](https://github.com/runpod/runpodctl/blob/main/README.md) or use the provided cloud storage method for seamless integration.

### 🚚 Google Drive Uploading

To transfer files between your pod and Google Drive, utilize [this helpful colab](https://colab.research.google.com/drive/1ot8pODgystx1D6_zvsALDSvjACBF1cj6) with `runpodctl`. This can be executed within a web terminal available in your pod's connect menu or through a desktop terminal session.

## 🔌 Template Ports Configuration

The template is configured with the following ports for essential services:

- **22** | TCP - Secure Shell (SSH) access.
- **3001** | HTTP - The main Comfy Web UI interface.
- **8888** | HTTP - JupyterLab interface for advanced data analysis and visualization.

### Pre-installed Models Overview

This template comes pre-loaded with an extensive collection of models to enhance your stable diffusion experience:

#### ControlNet Models
- Various models from lllyasviel's SD control collection and CVL-Heidelberg's ControlNet-XS, including recolor, canny, and blur variants.

#### CLIP Vision Model
- `clip-vit-h.safetensors` for advanced image understanding and manipulation.

#### IP Adapter Models
- Multiple `ip-adapter` instances for face ID recognition and enhancements.

#### LoRA Models
- LoRA adaptations of IP Adapter models for efficient large model fine-tuning.

#### Diffusers Models
- A selection of `diffusers` models optimized for canny and depth effects.

With SDXL Comfy UI, you're equipped to explore, create, and innovate with stable diffusion like never before. Enjoy the journey!
