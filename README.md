# interspeech-2021-replication

## Prerequisites

- Git
- Docker

## How to replicate the results

Clone this repository

```shell
$ git clone git@github.com:kishiyamat/interspeech-2021-replication.git
$ cd interspeech-2021-replication
```

Run Experiments

```shell
$ # Local terminal 1 @ interspeech-2021-replication
$ docker build -t kishiyamat/interspeech-2021-replication .
$ docker run -it --rm kishiyamat/interspeech-2021-replication bash
$ # Docker terminal
$ cd interspeech-2021-replication
$ make exp1     # dupoux et al. 1999
$ make exp2     # dupoux et al. 2011
$ # keep docker running
```

Copy Results

```shell
$ # Local terminal 2 @ interspeech-2021-replication
$ docker ps
CONTAINER ID        IMAGE                                     COMMAND             CREATED             STATUS              PORTS               NAMES
7609212cd78a        kishiyamat/interspeech-2021-replication   "bash"              9 minutes ago       Up 9 minutes        8787/tcp            sleepy_bell
$ use CONTAINER ID to find results
$ docker cp 7609212cd78a:/opt/app/interspeech-2021-replication/artifact/. artifact/
```

## Citation

```bibtex
@inproceedings{kishiyama2021influence,
  author={Takeshi Kishiyama},
  title={The Influence of Parallel Processing on Illusory Vowels},
  pages={N--N},
  booktitle={INTERSPEECH},
  year={2021},
}
```
