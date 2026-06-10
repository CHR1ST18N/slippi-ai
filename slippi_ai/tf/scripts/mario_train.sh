#!/usr/bin/env sh

# NUM_DAYS=6
# RUNTIME=$(($NUM_DAYS * 24 * 60 * 60))
#   --config.runtime.max_runtime=$RUNTIME \
DELAY="18"
CHAR="mario"

DATA_ROOT=slippi_ai/data/mario_dataset
DATA_DIR="$DATA_ROOT/Parsed"
META_PATH="$DATA_ROOT/meta.json"

python3.13 slippi_ai/tf/scripts/train.py \
  --wandb.mode=online \
  --config.tag=${CHAR}_delay_${DELAY} \
  --config.policy.delay=$DELAY \
  --config.data.batch_size=512 \
  --config.data.unroll_length=80 \
  --config.learner.learning_rate=1e-4 \
  --config.learner.reward_halflife=4 \
  --config.network.name=tx_like \
  --config.network.tx_like.num_layers=3 \
  --config.network.tx_like.hidden_size=512 \
  --config.network.tx_like.ffw_multiplier=2 \
  --config.policy.train_value_head=False \
  --config.value_function.train_separate_network=True \
  --config.value_function.separate_network_config=True \
  --config.value_function.network.name=tx_like \
  --config.value_function.network.tx_like.num_layers=1 \
  --config.value_function.network.tx_like.hidden_size=512 \
  --config.value_function.network.tx_like.ffw_multiplier=2 \
  --config.controller_head.name=autoregressive \
  --config.controller_head.autoregressive.component_depth=2 \
  --config.controller_head.autoregressive.residual_size=128 \
  --config.dataset.allowed_characters=$CHAR \
  --config.dataset.allowed_opponents=all \
  --config.dataset.data_dir=$DATA_DIR \
  --config.dataset.meta_path=$META_PATH \
  --config.runtime.eval_every_n=5000 \
  --config.runtime.num_eval_steps=200 \
  --config.runtime.log_interval=300 \
  --config.runtime.save_interval=600 \
  "$@"
