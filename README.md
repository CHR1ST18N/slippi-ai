## Local Play
From the repository root:

```
pip install -e ".[tf]"
python scripts/eval_two.py --p1.type human --p2.ai.path <path/to/trained/model> --dolphin.copy_home_directory
python scripts/eval_two.py --help  # to get a full list of options
```

A model capable of playing 12 different characters is available [here](https://www.dropbox.com/scl/fi/lpi9krfei1knfvfw7up7v/medium-v2?rlkey=qmah3qfz5anwva93x48zcx01k&st=sxo8hbeb&dl=0). You can change the character by setting `--p2.character <fox/falco/marth/...>`.

pass --help for all commands  

#### Notes
* Tested with python 3.12 and 3.13.
* By default phillip sets up human players as using Wii-U controller adapters. If you want to use your own dolphin configuration (including controller config) pass `--dolphin.copy_home_directory`. You still need to specify which player (p1 or p2) is human.
* On Windows you may need to [enable long paths](https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation?tabs=powershell#registry-setting-to-enable-long-paths) in order for the pip installs to work.
* On Windows make sure no other dolphin instances are running as it will prevent the bot from sending inputs to the game.
* The script will try to find slippi dolphin and your melee ISO; if it fails you can manually specify `--dolphin.iso` and `--dolphin.path`.


# Code Overview

Phillip is trained in two stages. In the first stage, it learns to imitate human play from a large dataset of slippi replays. The resulting imitation policy is ok, but makes a lot of mistakes. In the second stage, the imitation policy is refined by playing against itself with Reinforcement Learning. This results in much stronger agents that have their own style of play.

## Creating a Dataset

The first step is preprocess your slippi replays using [`slippi_db/parse_local.py`](\slippi_db\parse_local.py). See the documentation in that file for more details. (not fully supported in Native Windows. Use WSL)

The output of this step will be a `Parsed` directory of preprocessed games and a `meta.json` metadata file. ['Folder'](\slippi_ai\data\toy_dataset\Raw) 

## Imitation Learning

The entry point for imitation learning is [`scripts/train.py`](slippi_ai\tf\scripts\train.py). See [`scripts/imitation_example.sh`](slippi_ai\tf\scripts\imitation_example.sh) for appropriate arguments.

Metrics are logged to [wandb](https://wandb.ai/) during training. To use your own wandb account, set the `WANDB_API_KEY` environment variable. The key metric to look at is `eval.policy.loss` -- once this has plateaued you can stop training. On a good GPU (e.g. a 3080Ti), imitation learning should take a few days to a week. The agent checkpoint will be periodically written to `experiments/<tag>/latest.pkl`.

## Reinforcement Learning

There are two entry points for RL: [`slippi_ai/rl/run.py`](slippi_ai/rl/run.py) for training an agent in the ditto, and [`slippi_ai/rl/train_two.py`](slippi_ai/rl/train_two.py) which trains two agents simultaneously. The arguments are similar for both; see [`scripts/rl_example.sh`](scripts/rl_example.sh) for an example ditto training script.

## Evaluation

To play a trained agent or watch two trained agents play each other, use [`scripts/eval_two.py`](scripts/eval_two.py). To do a full evaluation of two agents against each other, use [`scripts/run_evaluator.py`](main/scripts/run_evaluator.py).
