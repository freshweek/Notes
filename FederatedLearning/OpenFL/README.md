## Aggregator

1. short-lived entity
2. be spawned by `Director`
3. work with `Collaborator` according to FL Plan
4. perform model aggregation at the end of each round

## Collaborator

1. short-lived entity
2. created by `Envoy`
3. manage training the model on local data
4. execute assigned tasks
5. convert deep learning framework-specfic tensor objects to OpenFL inner representation
6. exchanging model parameters with `Aggregator`

## Director

1. long-lived entity
2. central node of federation
3. start an `Aggregator` for each experiment
4. broadcast experiment archive to connected collaborator nodes and provide updates
5. support concurrent frontend connections
6. monitor `Aggregator` when experment is running


## Envoy

1. long-lived entity
2. run on `Collaborator` nodes
3. always connect to `Director`
4. each `Envoy` is matched to one `shard descriptor`
5. accept the experiment workspace, prepare the environment, and start a `Collaborator`
6. responsible for sending heartbeats message to `Director`

一直等待director返回work list
work list被压缩为一个zip文件，其中包含各种yaml文件。
yaml文件定义了如何进行训练


## shard_descripter

本身是一个数据集，在python中定义为序列化的对象

## task interface

涉及到了装饰器decorator

包含任务的添加
model_interface
task_interface
dataloader_interface

## plan

plan对象是FL中的任务执行相关的配置

# Done

```
cp defaults/assigner.yaml defaults/assigner.yaml.bak
cp defaults/tasks_torch.yaml defaults/tasks_torch.yaml.bak

```