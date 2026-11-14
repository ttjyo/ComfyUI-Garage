#!/bin/bash
# October setup for the MiniMax H3 pod (Singularity R2VA, Oct 24 workflows)
COMFY=/workspace/runpod-slim/ComfyUI
MODELS=$COMFY/models
BRANCH_URL=https://raw.githubusercontent.com/ttjyo/ComfyUI-Garage/october-snapshot/workflows/minimax
WF_DIR=$COMFY/user/default/workflows/minimax

say() { echo "[october-setup] $(date +%H:%M:%S) $*"; }

# fetch <folder> <file name> <url> <minimum size in bytes>
fetch() {
    local dir="$MODELS/$1" name="$2" url="$3" min="$4"
    mkdir -p "$dir"
    local size=0
    [ -f "$dir/$name" ] && size=$(stat -c%s "$dir/$name")
    if [ "$size" -ge "$min" ]; then
        say "$name already there, skipping"
    else
        say "downloading $name ..."
        wget -q --show-progress -c -O "$dir/$name" "$url" || say "FAILED: $name"
    fi
}

say "waiting for ComfyUI folders..."
for i in $(seq 1 120); do [ -f "$COMFY/main.py" ] && break; sleep 5; done

fetch diffusion_models Minimax-h3_Singularity_ref2va_Pruned_v1.3_int8.safetensors \
  "https://huggingface.co/WarmBloodAban/Minimax-h3_Singularity/resolve/main/Minimax-h3_Singularity_ref2va_Pruned_v1.3_int8.safetensors" 20000000000
fetch loras minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors \
  "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/loras/minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors" 1900000000

say "waiting for the pod's own workflow downloader to finish..."
for i in $(seq 1 120); do
    grep -q "Workflow downloads done" /var/log/minimax-h3-workflows.log 2>/dev/null && break
    sleep 5
done

mkdir -p "$WF_DIR"
for f in MiniMaxH3-Singularity-R2VA-Qwen3.5.json MiniMaxH3-Turbo-I2VA-Qwen3.5.json MiniMaxH3-Turbo-FL2VA-Qwen3.5.json MiniMaxH3-Turbo-T2VA-Qwen3.5.json MiniMaxH3-Turbo-R2VA-Qwen3.5.json MiniMaxH3-Director-Native-Qwen3.5.json MiniMaxH3-Director-Storyboard-Qwen3.5.json; do
    if wget -q -O "$WF_DIR/$f.tmp" "$BRANCH_URL/$f"; then
        mv -f "$WF_DIR/$f.tmp" "$WF_DIR/$f"
        say "workflow restored: $f"
    else
        rm -f "$WF_DIR/$f.tmp"
        say "FAILED: $f"
    fi
done

say "DONE - reload the ComfyUI page (or press R) to refresh the lists"
