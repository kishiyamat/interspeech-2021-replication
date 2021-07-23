# interspeech-2021-replication

## Prerequisitee

- Docker

## How to replicate the results

Run Experiments

```
$ # Local terminal 1
$ docker build -t kishiyamat/interspeech-2021-replication .
$ docker run -it --rm kishiyamat/interspeech-2021-replication bash
$ # Docker terminal
$ cd interspeech-2021-replication
$ make exp1     # dupoux et al. 1999
$ make exp2     # dupoux et al. 2011
$ # keep docker running
```

Copy Results

```
$ # Local terminal 2
$ docker ps
CONTAINER ID        IMAGE                                     COMMAND             CREATED             STATUS              PORTS               NAMES
7609212cd78a        kishiyamat/interspeech-2021-replication   "bash"              9 minutes ago       Up 9 minutes        8787/tcp            sleepy_bell
$ use CONTAINER ID to find results
$ docker cp 7609212cd78a:/opt/app/interspeech-2021-replication/artifact/. artifact/
```

## Citation

```
@inproceedings{kishiyama2021influence,
  author={Takeshi Kishiyama},
  title={The Influence of Parallel Processing on Illusory Vowels},
  pages={N--N},
  booktitle={INTERSPEECH},
  year={2021},
}
```
