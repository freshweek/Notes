# Namespaces

## Namespace Types

### UTS
allow processes to see separate hostname other than actual global namespace.

### PID
Within the PID namespace, the processes construct a process tree.
Each has an `init` process with PID 1.

The process tree belong to one global process tree, which is only visuable to `host`.

### Mount
control which mount points a process should see.

bind mount can make a `directory` within the host to be mount to the container's `file system`.

### Network
a network namespace gives a container a separate set of network subsystem.
The processes within the network namespace will see a different network interfaces, routes, and iptables.

### IPC
IPC namespace construct POSIX message queues.

### Cgroup
