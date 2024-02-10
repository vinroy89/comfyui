FROM nvidia/cuda:11.8.0-base-ubuntu22.04 as runtime

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set working directory and environment variables
ENV SHELL=/bin/bash
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /

# Set up system
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt install --yes --no-install-recommends git wget curl bash libgl1 software-properties-common openssh-server nginx rsync && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt install python3.10-dev python3.10-venv build-essential -y --no-install-recommends && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo en_US.UTF-8 UTF-8 > /etc/locale.gen

# Set up Python and pip
RUN ln -s /usr/bin/python3.10 /usr/bin/python && \
    rm /usr/bin/python3 && \
    ln -s /usr/bin/python3.10 /usr/bin/python3 && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py

RUN python -m venv /venv
ENV PATH=/venv/bin:$PATH

# Install necessary Python packages
RUN pip install --upgrade --no-cache-dir pip && \
    pip install --upgrade setuptools && \
    pip install --upgrade wheel
RUN pip install --upgrade --no-cache-dir torch==2.0.1+cu118 torchvision==0.15.2+cu118 torchaudio==2.0.2 --index-url https://download.pytorch.org/whl/cu118
RUN pip install --upgrade --no-cache-dir jupyterlab ipywidgets jupyter-archive jupyter_contrib_nbextensions triton xformers==0.0.22 gdown

# Set up Jupyter Notebook
RUN pip install --no-cache-dir notebook==6.5.5
RUN jupyter contrib nbextension install --user && \
    jupyter nbextension enable --py widgetsnbextension

# Install ComfyUI and ComfyUI Manager
RUN git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd /ComfyUI && \
    pip install --no-cache-dir -r requirements.txt && \
	pip install --no-cache-dir onnxruntime-gpu insightface && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager custom_nodes/ComfyUI-Manager && \
	git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes custom_nodes/ComfyUI_Comfyroll_CustomNodes && \
	git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus custom_nodes/ComfyUI_IPAdapter_plus && \
	git clone https://github.com/Fannovel16/comfyui_controlnet_aux custom_nodes/comfyui_controlnet_aux && \
	git clone https://github.com/ltdrdata/ComfyUI-Inspire-Pack custom_nodes/ComfyUI-Inspire-Pack && \
	git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack custom_nodes/ComfyUI-Impact-Pack && \
	git clone https://github.com/CYBERLOOM-INC/ComfyUI-nodes-hnmr custom_nodes/ComfyUI-nodes-hnmr && \
	git clone https://github.com/unanan/ComfyUI-clip-interrogator custom_nodes/ComfyUI-clip-interrogator && \
	git clone https://github.com/ZHO-ZHO-ZHO/ComfyUI-InstantID.git custom_nodes/ComfyUI-InstantID && \
	wait && \
    cd /ComfyUI/custom_nodes/ComfyUI-Manager && \
    pip install --no-cache-dir -r requirements.txt && \
    cd /ComfyUI/custom_nodes/comfyui_controlnet_aux && \
    pip install --no-cache-dir -r requirements.txt && \
    cd /ComfyUI/custom_nodes/ComfyUI-Inspire-Pack && \
    pip install --no-cache-dir -r requirements.txt && \
    cd /ComfyUI/custom_nodes/ComfyUI-Impact-Pack && \
    pip install --no-cache-dir -r requirements.txt && \
	cd /ComfyUI/custom_nodes/ComfyUI-InstantID && \
    pip install --no-cache-dir -r requirements.txt


# Create directory structure
RUN mkdir -p /comfy-models \
	/comfy-models/checkpoints \
	/comfy-models/ipadapter \
	/comfy-models/clip_vision \
	/comfy-models/diffusers \
	/comfy-models/controlnet \
	/comfy-models/loras \
	/comfy-models/loras/ipadapter \
	/comfy-models/upscale_models \
	/instant-id-models \
	/instant-id-models/checkpoints \
	/instant-id-models/checkpoints/controlnet \
	/instant-id-models/models \
	/instant-id-models/models/antelopev2
			 
RUN wget --no-check-certificate -O /downloads/comfy-models/controlnet/sai_xl_recolor_128lora.safetensors  --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/sai_xl_recolor_128lora.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/cvl_heidelberg_xl_canny_20m.safetensors --progress=bar:force https://huggingface.co/CVL-Heidelberg/ControlNet-XS/resolve/main/sdxl_encD_canny_20m.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/cvl_heidelberg_xl_canny_48m.safetensors --progress=bar:force https://huggingface.co/CVL-Heidelberg/ControlNet-XS/resolve/main/sdxl_encD_canny_48m.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/ioclab_sd15_recolor.safetensors --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/ioclab_sd15_recolor.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/kohya_controllllite_xl_blur.safetensors --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/kohya_controllllite_xl_blur.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/kohya_controllllite_xl_blur_anime.safetensors --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/kohya_controllllite_xl_blur_anime.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/kohya_controllllite_xl_blur_anime_beta.safetensors  --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/kohya_controllllite_xl_blur_anime_beta.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/kohya_controllllite_xl_canny.safetensors --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/kohya_controllllite_xl_canny.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/kohya_controllllite_xl_canny_anime.safetensors --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/kohya_controllllite_xl_canny_anime.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/kohya_controllllite_xl_depth.safetensors --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/kohya_controllllite_xl_depth.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/kohya_controllllite_xl_depth_anime.safetensors --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/kohya_controllllite_xl_depth_anime.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/kohya_controllllite_xl_openpose_anime.safetensors --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/kohya_controllllite_xl_openpose_anime.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/kohya_controllllite_xl_openpose_anime_v2.safetensors --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/kohya_controllllite_xl_openpose_anime_v2.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/kohya_controllllite_xl_scribble_anime.safetensors --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/kohya_controllllite_xl_scribble_anime.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/sai_xl_canny_128lora.safetensors  --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/sai_xl_canny_128lora.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/sai_xl_canny_256lora.safetensors  --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/sai_xl_canny_256lora.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/sai_xl_depth_128lora.safetensors  --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/sai_xl_depth_128lora.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/sai_xl_depth_256lora.safetensors  --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/sai_xl_depth_256lora.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/sai_xl_recolor_256lora.safetensors  --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/sai_xl_recolor_256lora.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/sai_xl_sketch_128lora.safetensors  --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/sai_xl_sketch_128lora.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/controlnet/sai_xl_sketch_256lora.safetensors  --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/sai_xl_sketch_256lora.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/clip_vision/clip-vit-h.safetensors  --progress=bar:force https://huggingface.co/h94/IP-Adapter/resolve/main/models/image_encoder/model.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/ipadapter/ip-adapter-faceid_sdxl.bin  --progress=bar:force https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid_sdxl.bin  \
	&& wget --no-check-certificate -O /downloads/comfy-models/ipadapter/ip-adapter-faceid-plusv2_sdxl.bin   --progress=bar:force https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sdxl.bin  \
	&& wget --no-check-certificate -O /downloads/comfy-models/ipadapter/ip-adapter-plus-face_sdxl_vit-h.safetensors  --progress=bar:force https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus-face_sdxl_vit-h.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/loras/ipadapter/ip-adapter-faceid_sdxl_lora.safetensors  --progress=bar:force https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid_sdxl_lora.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/loras/ipadapter/ip-adapter-faceid-plusv2_sdxl_lora.safetensors  --progress=bar:force https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sdxl_lora.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/diffusers/diffusers_xl_canny_full.safetensors  --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_canny_full.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/diffusers/diffusers_xl_canny_mid.safetensors  --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_canny_mid.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/diffusers/diffusers_xl_canny_small.safetensors  --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_canny_small.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/diffusers/diffusers_xl_depth_full.safetensors  --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_depth_full.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/diffusers/diffusers_xl_depth_mid.safetensors  --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_depth_mid.safetensors  \
	&& wget --no-check-certificate -O /downloads/comfy-models/diffusers/diffusers_xl_depth_small.safetensors  --progress=bar:force https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_depth_small.safetensors  \
	&& wget --no-check-certificate -O /downloads/instant-id-models/checkpoints/controlnet/config.json  --progress=bar:force https://huggingface.co/InstantX/InstantID/resolve/main/ControlNetModel/config.json  \
	&& wget --no-check-certificate -O /downloads/instant-id-models/checkpoints/controlnet/control_instant_id_sdxl.safetensors  --progress=bar:force https://huggingface.co/InstantX/InstantID/resolve/main/ControlNetModel/diffusion_pytorch_model.safetensors  \
	&& wget --no-check-certificate -O /downloads/instant-id-models/checkpoints/ip-adapter_instant_id_sdxl.bin  --progress=bar:force https://huggingface.co/InstantX/InstantID/resolve/main/ip-adapter.bin  \
	&& wget --no-check-certificate -O /downloads/instant-id-models/models/antelopev2/1k3d68.onnx  --progress=bar:force https://huggingface.co/DIAMONIK7777/antelopev2/resolve/main/1k3d68.onnx   \
	&& wget --no-check-certificate -O /downloads/instant-id-models/models/antelopev2/2d106det.onnx  --progress=bar:force https://huggingface.co/DIAMONIK7777/antelopev2/resolve/main/2d106det.onnx  \
	&& wget --no-check-certificate -O /downloads/instant-id-models/models/antelopev2/genderage.onnx  --progress=bar:force https://huggingface.co/DIAMONIK7777/antelopev2/resolve/main/genderage.onnx  \
	&& wget --no-check-certificate -O /downloads/instant-id-models/models/antelopev2/glintr100.onnx  --progress=bar:force https://huggingface.co/DIAMONIK7777/antelopev2/resolve/main/glintr100.onnx  \
	&& wget --no-check-certificate -O /downloads/instant-id-models/models/antelopev2/scrfd_10g_bnkps.onnx  --progress=bar:force https://huggingface.co/DIAMONIK7777/antelopev2/resolve/main/scrfd_10g_bnkps.onnx \
	&& wget --no-check-certificate -O /downloads/comfy-models/loras/sd_xl_offset_example-lora_1.0.safetensors --progress=bar:force  https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_offset_example-lora_1.0.safetensors  \
 	&& wget --no-check-certificate -O /downloads/comfy-models/checkpoints/juggernautXL_v8Rundiffusion.safetensors --progress=bar:force https://huggingface.co/frankjoshua/juggernautXL_v8Rundiffusion/resolve/main/juggernautXL_v8Rundiffusion.safetensors  \
 	&& wget --no-check-certificate -O /downloads/comfy-models/upscale_models/4x_NMKD-Superscale-SP_178000_G.pth --progress=bar:force  https://huggingface.co/gemasai/4x_NMKD-Superscale-SP_178000_G/resolve/main/4x_NMKD-Superscale-SP_178000_G.pth \
 	&& wget --no-check-certificate -O /downloads/comfy-models/checkpoints/sd_xl_base_1.0.safetensors --progress=bar:force https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors \
 	&& wget --no-check-certificate -O /downloads/comfy-models/checkpoints/sd_xl_refiner_1.0.safetensors --progress=bar:force https://huggingface.co/ckpt/sd_xl_refiner_1.0/resolve/main/sd_xl_refiner_1.0.safetensors  \
 	&& wget --no-check-certificate -O /downloads/comfy-models/checkpoints/RealVisXL_V3.0.safetensors --progress=bar:force  https://huggingface.co/SG161222/RealVisXL_V3.0/resolve/main/RealVisXL_V3.0.safetensors  \
 	&& wget --no-check-certificate -O /downloads/comfy-models/upscale_models/4x_NMKD-Siax_200k.pth --progress=bar:force https://huggingface.co/gemasai/4x_NMKD-Siax_200k/resolve/main/4x_NMKD-Siax_200k.pth 

# NGINX Proxy
COPY container-template/proxy/nginx.conf /etc/nginx/nginx.conf
COPY container-template/proxy/readme.html /usr/share/nginx/html/readme.html

# Copy the README.md
COPY README.md /usr/share/nginx/html/README.md

# Start Scripts
COPY pre_start.sh /pre_start.sh
COPY container-template/start.sh /
RUN chmod +x /start.sh

EXPOSE 3000
EXPOSE 8888

CMD [ /start.sh ]
