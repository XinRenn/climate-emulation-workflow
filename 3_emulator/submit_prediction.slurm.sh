#!/bin/bash
#SBATCH --job-name=emu_pred
#SBATCH --account=PGEO001321
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=64G
#SBATCH --time=4:00:00
#SBATCH --partition=compute
#SBATCH --output=downscaling_NWS/log/prediction_%j.out
#SBATCH --error=downscaling_NWS/log/prediction_%j.err

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

# Activate conda environment
source ~/.bashrc
conda activate emu

# Navigate to working directory
cd downscaling_NWS/

# Create log dir if missing
mkdir -p "$(dirname "$0")/logs"


# Run prediction
python run_prediction.py
