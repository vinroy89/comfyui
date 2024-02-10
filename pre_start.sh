#!/bin/bash

export PYTHONUNBUFFERED=1
source /venv/bin/activate
rsync -au --remove-source-files /ComfyUI/ /workspace/ComfyUI/


replicate_and_link() {
    local source_dir="$1"
    local dest_dir="$2"

    find "$source_dir" -type d | while read src_dir_path; do
        local relative_path="${src_dir_path#$source_dir}"
        mkdir -p "$dest_dir$relative_path"
    done

    find "$source_dir" -type f | while read src_file_path; do
        local relative_path="${src_file_path#$source_dir}"
        local dest_path="$dest_dir$relative_path"
        if [ ! -L "$dest_path" ]; then  # Check if the symbolic link does not already exist
            ln -s "$src_file_path" "$dest_path"
        fi
    done
}

replicate_and_link "/comfy-models" "/workspace/ComfyUI/models"
replicate_and_link "/instant-id-models" "/workspace/ComfyUI/custom_nodes/ComfyUI-InstantID"

cd /workspace/ComfyUI
python main.py --listen --port 3000 --share &
