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

#cd /clusteruy/home/henry.marichal/repos/INBD && python main.py inference \
#        runs/salix_1/model_1/2025-09-11_06h16m58s_INBD_100e_a6.3_/model.pt.zip \
#        /clusteruy/home/henry.marichal/datasets/candice_reviewers1/salix_1/test_images.txt

cd /clusteruy/home/henry.marichal/repos/INBD && python main.py evaluate inference/2025-09-11_06h16m58s_INBD_100e_a6.3_ \
        /clusteruy/home/henry.marichal/datasets/candice_reviewers1/salix_1/test_annotations.txt
