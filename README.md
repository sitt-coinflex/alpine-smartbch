# Full node client of smartBCH on Alpine Linux Base Container

This repository contains the code of the full node client of smartBCH, an EVM&Web3 compatible sidechain for Bitcoin Cash.

You can get more information at smartbch.org.

## Docker

To run smartBCH via docker-compose you can execute the commands below! Note, the first time you run docker-compose it will take a while, as it will need to build the docker image.

* Generate a set of 10 test keys.
    >  docker-compose run smartbch gen-test-keys -n 10  

* Init the node, include the keys from the last step as a comma separated list.

    > docker-compose run smartbch init mynode --chain-id 0x1 --init-balance=10000000000000000000 --test-keys="key1, key2, key3"  

* Start it up, you are all set!
    > docker-compose up  

## Attached Shellscript `dev.sh`

To use the attach shellscript, first you must allow your terminal to run it

```sh
sudo chmod +x dev.sh
```

Run the following commands to get started

```sh
# Generate test-keys and save them in root-folder under file `test-keys.txt`
./dev.sh gen-test-keys

# Initiate Node with given amount to the keys within `test-keys.txt`
./dev.sh init

# Start that node
./dev.sh start
```

## References

1. https://docs.smartbch.org/smartbch/deverlopers-guide/runsinglenode

2. `smartbch` [Dockerfile](https://github.com/smartbch/smartbch/blob/main/Dockerfile)

3.  `unoexperto/docker-rocksdb` [Dockerfile](https://github.com/unoexperto/docker-rocksdb/blob/master/Dockerfile)

4. `alpine-glibc` [Dockerfile](https://github.com/puxos/alpine-pkg-glibc/blob/master/Dockerfile)

5. `rockdb-sharp` [Issue #54](https://github.com/warrenfalk/rocksdb-sharp/issues/54)

6. `docker-rocksdb` [Gist](https://gist.github.com/dukelion/2a8813f8adb4ac08b500175f4daa88fd)

7. `docker-rocksdb v6.17.3` [Dockerfile](https://github.com/savsgio/docker-rocksdb/blob/main/Dockerfile)

8. `n0madic/alpine-gcc` [Dockerfile](https://github.com/n0madic/alpine-gcc/blob/master/Dockerfile)