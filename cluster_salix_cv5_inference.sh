#!/bin/bash
#SBATCH --job-name=inbd
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=100G
#SBATCH --time=72:00:00
#SBATCH --mail-type=ALL
#SBATCH --tmp=100G
#SBATCH --mail-user=henry.marichal@fing.edu.uy
#SBATCH --gres=gpu:a40:1
#SBATCH --partition=normal
#SBATCH --qos=gpu



# Cargar módulos y activar el entorno
source /etc/profile.d/modules.sh
source /clusteruy/home/henry.marichal/miniconda3/etc/profile.d/conda.sh
conda activate inbd_gpu

MODEL_ROOT_DIR=$1
INFERENCE_PARENT_DIR=$2
DATASET_DIR=$3
# Loop through X=[1,2,3,4,5]
for X in 1 2 3 4 5; do
    echo "Processing model_${X} with test set ${X}..."
    
    # Find the INBD model directory (latest one if multiple exist)
    MODEL_DIR=$(ls -td ${MODEL_ROOT_DIR}/model_${X}/*INBD*/ 2>/dev/null | head -1 | sed 's:/*$::')
    
    if [ -z "$MODEL_DIR" ]; then
        echo "Error: No INBD model found in ${MODEL_ROOT_DIR}/model_${X}/"
        continue
    fi
    
    MODEL_PATH="${MODEL_DIR}/model.pt.zip"
    
    if [ ! -f "$MODEL_PATH" ]; then
        echo "Error: Model file not found at ${MODEL_PATH}"
        continue
    fi
    
    echo "Using model: ${MODEL_PATH}"
    
    # Define output directory for this model
    INFERENCE_DIR="${INFERENCE_PARENT_DIR}/model_${X}"
    
    # Run inference
    cd /clusteruy/home/henry.marichal/repos/INBD && python main.py inference \
        ${MODEL_PATH} \
         ${DATASET_DIR}/test_images_${X}.txt \
         --output ${INFERENCE_PARENT_DIR}
        
    # Find the latest inference subdirectory (timestamped)
    LATEST_INFERENCE_DIR=$(ls -td ${INFERENCE_PARENT_DIR}/*/ 2>/dev/null | head -1 | sed 's:/*$::')

    if [ -z "$LATEST_INFERENCE_DIR" ]; then
    echo "Error: No inference output found in ${INFERENCE_PARENT_DIR}/"
    continue
    fi
    echo "Using inference output: ${LATEST_INFERENCE_DIR}"

    # Run evaluation
    cd /clusteruy/home/henry.marichal/repos/INBD && python main.py evaluate ${LATEST_INFERENCE_DIR} \
        ${DATASET_DIR}/test_annotations_${X}.txt

    echo "Completed model_${X}"
done
