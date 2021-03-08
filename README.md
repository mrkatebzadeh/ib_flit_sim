# ib_flit_sim
This directory tree hold an InfiniBand model with support for
IB flow control scheme, Arbitration over multiple VLs and routing
based on Linear Forwarding Tables.

## Build the image:
```
docker-compose build
```

## Run the container:
```
docker-compose run mlx bash
```

## Compile the model:
```
./build.sh
```

## Run examples:
```
cd examples/XXX
$d/src/ib_flit_sim -f XXX.ini -u Cmdenv
```
