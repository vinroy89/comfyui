#!/bin/bash

# This file will be sourced in init.sh

# https://raw.githubusercontent.com/ai-dock/comfyui/main/config/provisioning/default.sh

# Check if the cuda-toolkit package is already installed
if ! dpkg -l | grep -qw cuda-toolkit; then
  echo "CUDA Toolkit not found. Installing CUDA Toolkit..."
  apt update
  apt install cuda-toolkit -y
else
  echo "CUDA Toolkit is already installed."
fi


# Check if CUDA is already installed by looking for nvcc
if ! type nvcc > /dev/null 2>&1; then
  echo "CUDA not found. Installing CUDA..."
  sudo apt update && sudo apt upgrade -y
  # Install CUDA
  # Note: You may need to adjust the package name for different CUDA versions
  sudo apt install -y cuda-toolkit
else
  echo "CUDA is already installed."
fi

# Packages are installed after nodes so we can fix them...

PYTHON_PACKAGES=(
    "evalidate"
    "spandrel"
    "ultralytics" 
    "numba" 
    "deepdiff" 
    "Ninja"
    "omegaconf"
    "google-generativeai==0.7.2"
)

NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes"
    "https://github.com/11cafe/comfyui-workspace-manager"
    "https://github.com/kijai/ComfyUI-SUPIR"
    "https://github.com/ManglerFTW/ComfyI2I"
    "https://github.com/cubiq/ComfyUI_IPAdapter_plus"
    "https://github.com/cubiq/ComfyUI_InstantID"
    "https://github.com/Fannovel16/comfyui_controlnet_aux"
    "https://github.com/ltdrdata/ComfyUI-Inspire-Pack"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    "https://github.com/CYBERLOOM-INC/ComfyUI-nodes-hnmr"
    "https://github.com/unanan/ComfyUI-clip-interrogator"
    "https://github.com/kijai/ComfyUI-SUPIR"
    "https://github.com/WASasquatch/was-node-suite-comfyui"
    "https://github.com/crystian/ComfyUI-Crystools"
    "https://github.com/BadCafeCode/masquerade-nodes-comfyui"
    "https://github.com/laksjdjf/cgem156-ComfyUI"
)

CHECKPOINT_MODELS=(
    "https://huggingface.co/KamCastle/sdxlmodels/resolve/main/wildcardxXLLIGHTNING_wildcardxXL.safetensors"
    "https://huggingface.co/camenduru/SUPIR/resolve/main/SUPIR-v0F.ckpt"
    "https://huggingface.co/camenduru/SUPIR/resolve/main/SUPIR-v0Q.ckpt"
)

LORA_MODELS=(
    "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_offset_example-lora_1.0.safetensors"
    "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid_sdxl_lora.safetensors"
    "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sdxl_lora.safetensors"
    "https://huggingface.co/PvDeep/Add-Detail-XL/resolve/main/add-detail-xl.safetensors"
)

VAE_MODELS=(
    "https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl.vae.safetensors"
)

ESRGAN_MODELS=(
    "https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x4.pth"
    "https://huggingface.co/FacehugmanIII/4x_foolhardy_Remacri/resolve/main/4x_foolhardy_Remacri.pth"
    "https://huggingface.co/gemasai/4x_NMKD-Superscale-SP_178000_G/resolve/main/4x_NMKD-Superscale-SP_178000_G.pth"
    "https://huggingface.co/gemasai/4x_NMKD-Siax_200k/resolve/main/4x_NMKD-Siax_200k.pth"
)

CONTROLNET_MODELS=()

IPADAPTER_MODELS=(
    "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid_sdxl.bin"
    "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sdxl.bin"
    "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter_sdxl.safetensors"
)

ANTELOPE_MODELS=(
    "https://huggingface.co/DIAMONIK7777/antelopev2/resolve/main/1k3d68.onnx"
    "https://huggingface.co/DIAMONIK7777/antelopev2/resolve/main/2d106det.onnx"
    "https://huggingface.co/DIAMONIK7777/antelopev2/resolve/main/genderage.onnx"
    "https://huggingface.co/DIAMONIK7777/antelopev2/resolve/main/glintr100.onnx"
    "https://huggingface.co/DIAMONIK7777/antelopev2/resolve/main/scrfd_10g_bnkps.onnx"
)

### DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING ###

function provisioning_start() {
    DISK_GB_AVAILABLE=$(($(df --output=avail -m "${WORKSPACE}" | tail -n1) / 1000))
    DISK_GB_USED=$(($(df --output=used -m "${WORKSPACE}" | tail -n1) / 1000))
    DISK_GB_ALLOCATED=$(($DISK_GB_AVAILABLE + $DISK_GB_USED))
    provisioning_print_header
    provisioning_get_nodes
    provisioning_install_python_packages
    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/ckpt" \
        "${CHECKPOINT_MODELS[@]}"
    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/lora" \
        "${LORA_MODELS[@]}"
    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/controlnet" \
        "${CONTROLNET_MODELS[@]}"
    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/vae" \
        "${VAE_MODELS[@]}"
    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/esrgan" \
        "${ESRGAN_MODELS[@]}"
    provisioning_get_models \
        "${WORKSPACE}/ComfyUI/models/ipadapter" \
        "${IPADAPTER_MODELS[@]}"
    provisioning_get_models \
        "${WORKSPACE}/ComfyUI/custom_nodes/ComfyUI-InstantID/models/antelopev2" \
        "${ANTELOPE_MODELS[@]}"
    
    printf "Downloading InstantID models ...\n" "${repo}"
    provisioning_download "https://huggingface.co/InstantX/InstantID/resolve/main/ControlNetModel/config.json" "${WORKSPACE}/ComfyUI/models/checkpoints/controlnet/"
    provisioning_download "https://huggingface.co/InstantX/InstantID/resolve/main/ControlNetModel/diffusion_pytorch_model.safetensors" "${WORKSPACE}/ComfyUI/models/checkpoints/controlnet/"
    provisioning_download "https://huggingface.co/InstantX/InstantID/resolve/main/ip-adapter.bin" "${WORKSPACE}/ComfyUI/models/checkpoints/"
    
    printf "Downloading clip models ...\n" "${repo}"
    provisioning_download "https://huggingface.co/h94/IP-Adapter/resolve/main/models/image_encoder/model.safetensors" "${WORKSPACE}/ComfyUI/models/clip_vision"

    printf "Downloading Xinsir models ...\n" "${repo}"
    provisioning_download "https://huggingface.co/xinsir/controlnet-canny-sdxl-1.0/resolve/main/diffusion_pytorch_model_V2.safetensors" "${WORKSPACE}/ComfyUI/models/controlnet" "xinsir-controlnet-canny-sdxl-1.0.safetensors"
    provisioning_download "https://huggingface.co/xinsir/controlnet-tile-sdxl-1.0/resolve/main/diffusion_pytorch_model.safetensors" "${WORKSPACE}/ComfyUI/models/controlnet" "xinsir-controlnet-tile-sdxl-1.0.safetensors"
    provisioning_download "https://huggingface.co/xinsir/controlnet-depth-sdxl-1.0/resolve/main/diffusion_pytorch_model.safetensors" "${WORKSPACE}/ComfyUI/models/controlnet" "xinsir-controlnet-depth-sdxl-1.0.safetensors"
    provisioning_download "https://huggingface.co/xinsir/controlnet-openpose-sdxl-1.0/resolve/main/diffusion_pytorch_model_twins.safetensors" "${WORKSPACE}/ComfyUI/models/controlnet" "xinsir-controlnet-openpose-twins-sdxl-1.0.safetensors"
    
    printf "Downloading LeoSams' Helloworld CLIP models ...\n" "${repo}"
    provisioning_download "https://huggingface.co/misri/leosamsHelloworldXL_helloworldXL70/resolve/main/text_encoder/model.fp16.safetensors" "${WORKSPACE}/ComfyUI/models/clip" "leosamsHelloworldXL_helloworldXL70-CLIP-L_fp16.safetensors"
    provisioning_download "https://huggingface.co/misri/leosamsHelloworldXL_helloworldXL70/resolve/main/text_encoder_2/model.fp16.safetensors" "${WORKSPACE}/ComfyUI/models/clip" "leosamsHelloworldXL_helloworldXL70-CLIP-G_fp16.safetensors"
    provisioning_print_end
}

function provisioning_get_nodes() {
    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        path="/opt/ComfyUI/custom_nodes/${dir}"
        requirements="${path}/requirements.txt"
        if [[ -d $path ]]; then
            if [[ ${AUTO_UPDATE,,} != "false" ]]; then
                printf "Updating node: %s...\n" "${repo}"
                ( cd "$path" && git pull )
                if [[ -e $requirements ]]; then
                    printf "Installing requirements for %s...\n" "${dir}"
                    micromamba -n comfyui run ${PIP_INSTALL} -r "$requirements"
                    if [[ $? -ne 0 ]]; then
                        printf "Error installing requirements for %s\n" "${dir}" >&2
                    fi
                fi
            fi
        else
            printf "Downloading node: %s...\n" "${repo}"
            git clone "${repo}" "${path}" --recursive
            if [[ $? -ne 0 ]]; then
                printf "Error cloning repository %s\n" "${repo}" >&2
            fi
            if [[ -e $requirements ]]; then
                printf "Installing requirements for %s...\n" "${dir}"
                micromamba -n comfyui run ${PIP_INSTALL} -r "${requirements}"
                if [[ $? -ne 0 ]]; then
                    printf "Error installing requirements for %s\n" "${dir}" >&2
                fi
            fi
        fi
    done
}

function provisioning_install_python_packages() {
    printf "Checking if there are Python packages to install...\n"
    if [ ${#PYTHON_PACKAGES[@]} -gt 0 ]; then
        printf "Python packages to be installed: ${PYTHON_PACKAGES[*]}\n"
        printf "Downloading python packages ${PYTHON_PACKAGES[*]}\n"
        micromamba -n comfyui run ${PIP_INSTALL} ${PYTHON_PACKAGES[*]}
        if [[ $? -ne 0 ]]; then
            printf "Error installing python packages: ${PYTHON_PACKAGES[*]}\n" >&2
        else
            printf "Successfully installed python packages: ${PYTHON_PACKAGES[*]}\n"
        fi
    else
        printf "No Python packages to install.\n"
    fi
}

function provisioning_get_models() {
    if [[ -z $2 ]]; then return 1; fi
    dir="$1"
    mkdir -p "$dir"
    shift
    if [[ $DISK_GB_ALLOCATED -ge $DISK_GB_REQUIRED ]]; then
        arr=("$@")
    else
        printf "WARNING: Low disk space allocation - Only the first model will be downloaded!\n"
        arr=("$1")
    fi
    
    printf "Downloading %s model(s) to %s...\n" "${#arr[@]}" "$dir"
    for url in "${arr[@]}"; do
        printf "Downloading: %s\n" "${url}"
        provisioning_download "${url}" "${dir}"
        printf "\n"
    done
}

function provisioning_print_header() {
    printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
    if [[ $DISK_GB_ALLOCATED -lt $DISK_GB_REQUIRED ]]; then
        printf "WARNING: Your allocated disk size (%sGB) is below the recommended %sGB - Some models will not be downloaded\n" "$DISK_GB_ALLOCATED" "$DISK_GB_REQUIRED"
    fi
}

function provisioning_print_end() {
    printf "\nProvisioning complete:  Web UI will start now\n\n"
}

# Download from $1 URL to $2 file path, optionally use $3 as the filename
function provisioning_download() {
    url=$1
    directory=$2
    filename=$3

    mkdir -p "$directory"
    
    if [[ -z "$filename" ]]; then
        wget -qnc --content-disposition --show-progress -e dotbytes="${4:-4M}" -P "$directory" "$url"
    else
        wget -qnc --show-progress -e dotbytes="${4:-4M}" -O "$directory/$filename" "$url"
    fi
}

provisioning_start
