# interspeech-2021-replication

https://www.isca-speech.org/archive/pdfs/interspeech_2021/kishiyama21_interspeech.pdf

## Prerequisites

- Git
- Docker

## How to replicate the results

Clone this repository

```shell
$ git clone git@github.com:kishiyamat/interspeech-2021-replication.git
$ cd interspeech-2021-replication
```

Run the experiments

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

Copy the results

```shell
$ # Local terminal 2 @ interspeech-2021-replication
$ docker ps
CONTAINER ID        IMAGE                                     COMMAND             CREATED             STATUS              PORTS               NAMES
7609212cd78a        kishiyamat/interspeech-2021-replication   "bash"              9 minutes ago       Up 9 minutes        8787/tcp            sleepy_bell
$ # Use CONTAINER ID to find results
$ docker cp 7609212cd78a:/opt/app/interspeech-2021-replication/artifact/. artifact/
```

## Citation

```bibtex
@article{kishiyama2021influence,
  title={The Influence of Parallel Processing on Illusory Vowels},
  author={Kishiyama, Takeshi},
  journal={Proc. Interspeech 2021},
  pages={1708--1712},
  year={2021}
}
```
