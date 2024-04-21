# mas

## requirements

- volta
    ```bash
    # install Volta
    curl https://get.volta.sh | bash
    ```

- docker (https://docs.docker.com/get-docker/)

## setup
```bash
# install libs
scripts/install.sh
```

## cleanup
```bash
# remove build / logs etc
scripts/clean.sh

# remove node_modules, containers etc
scripts/prune.sh
```

## containers
```bash
# create/start
scripts/start.sh

# stop/remove
scripts/stop.sh
```
