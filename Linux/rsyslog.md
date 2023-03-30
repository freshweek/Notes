## Rsyslog简介
* Rsyslog的全称是 rocket-fast system for log，它提供了高性能，高安全功能和模块化设计。rsyslog能够接受从各种各样的来源，将其输入，输出的结果到不同的目的地。rsyslog可以提供超过每秒一百万条消息给目标文件。
* 日志是任何软件或操作系统的关键组件。 日志通常会记录用户的操作、系统事件、网络活动等等，具体取决于它们的用途。 Linux 系统上使用最广泛的日志系统之一是 rsyslog 。
* Rsyslog 是一个强大、安全和高性能的日志处理系统，它接受来自不同类型源（系统/应用程序）的数据并输出为多种格式。
* 它已经从一个常规的 syslog 守护进程发展成为一个功能齐全的企业级日志系统。 它采用客户端/服务器模型设计，因此可以配置为客户端和/或其他服务器、网络设备和远程应用程序的中央日志服务器。

## 功能特性
* 多线程
* 可以通过许多协议进行传输UDP，TCP，SSL，TLS，RELP；
* 直接将日志写入到数据库;
* 支持加密协议：ssl，tls，relp
* 强大的过滤器，实现过滤日志信息中任何部分的内容
* 自定义输出格式

## 三种协议
* UDP 传输协议
　　基于传统UDP协议进行远程日志传输，也是传统syslog使用的传输协议； 可靠性比较低，但性能损耗最少， 在网络情况比较差， 或者接收服务器压力比较高情况下，可能存在丢日志情况。 在对日志完整性要求不是很高，在可靠的局域网环境下可以使用。

* TCP 传输协议
　　基于传统TCP协议明文传输，需要回传进行确认，可靠性比较高； 但在接收服务器宕机或者两者之间网络出问题的情况下，会出现丢日志情况。 这种协议相比于UDP在可靠性方面已经好很多，并且rsyslog原生支持，配置简单， 同时针对可能丢日志情况，可以进行额外配置提高可靠性，因此使用比较广。

* RELP 传输协议
　　RELP（Reliable Event Logging Protocol）是基于TCP封装的可靠日志消息传输协议； 是为了解决TCP 与 UDP 协议的缺点而在应用层实现的传输协议，也是三者之中最可靠的。 需要多安装一个包rsyslog-relp以支持该协议。


## 命令参数

```bash
$ rsyslogd -v
$ service rsyslog restart
```

## 配置文件
* /etc/rsyslog.conf
* /etc/rsyslog.d/*.conf

## 配置相关概念

**日志记录格式**：\<facility\>.\<priority\>    <action\>

例如：`mail.info /var/log/mail.log`表示将mail的info级别的消息记录到文件`/var/log/mail.log`中。


### Facility
Facility是syslog的模块，通过facility概念来定义日志消息的来源，以方便对日志进行分类。
```
kern   内核消息
user	用户级消息
mail	邮件
daemon	系统服务
syslog	日志系统服务
security/authorization messages
line printer subsystem
network news subsystem
UUCP subsystem		uucp系统消息
clock daemon
security/authorization messages
FTP daemon 
NTP subsystem
log audit
log alert
clock daemon
local0 - local7
```

### Priority/Severity(日志等级)

```
debug 有调式信息的，日志信息最多
info 一般信息的日志，最常用
notice 最具有重要性的普通条件的信息
warning 警告级别
err 错误级别，阻止某个功能或者模块不能正常工作的信息
crit 严重级别，阻止整个系统或者整个软件不能正常工作的信息
alert 需要立刻修改的信息
emerg 内核崩溃等严重信息
none 什么都不记录
local 1~7   自定义的日志设备

从上到下，级别从低到高，记录的信息越来越少
```

### 连接符号

```
.xxx:   表示大于等于xxx级别的消息
.=xxx:  表示等于xxx级别的消息
.!xxx:  表示在xxx级别之外的消息
```

### Actions
* 记录到普通文件或设备文件中：
```
facility.priority   /var/log/file.log
facility.priority   /dev/pts/0

linux中的logger命令可用于产生日志：logger -p local3.info 'This is a logger message'
```
* 转发到远程
```
facility.priority   @172.16.0.1         # 使用UDP协议转发到172.16.0.1的514(默认)端口
facility.priority   @172.16.0.1:10514   # 使用TCP协议转发到172.16.0.1的10514(默认)端口
```

* 转发给用户
```
facility.priority   root        # 转发给root用户
facility.priority   root,user1  # 转发给多个用户
facility.priority   *           # 转发给所有用户
```

* 丢弃
```
facility.priority   ~           # 忽略所有facility类型的priority级别的消息
```

* 执行脚本
```
facility.priority   ^/tmp/a.sh  # ^号后跟可执行脚本或程序的绝对路径
                                # 日志内容可以作为脚本的第一个参数，日志记录的顺序有先后关系
```

### Template

通过template定义变量
```bash
# 定义变量local1_path, FROMHOST_IP表示日志来源的IP
$template local1_path,  "/data/rsyslog/%FROMHOST_IP%/history/%$YEAR%-%$MONTH%-%$DAY%.log"

# 定义变量remote_path
$template remote_path,  "/data/rsyslog/%FROMHOST_IP%/%syslogfacility-text%/%$YEAR%-%$MONTH%-%$DAY%.log"
```

## 配置文件参数

/etc/rsyslog.conf文件详解
```bash
$ModLoad imuxsock   # 支持本地系统日志记录，例如通过logger命令
$ModLoad imjournal  # 提供对systemd日志的访问
#$ModLoad imklog    # 提供内核日志记录支持（之前由rklogd完成）
#$ModLoad imard     # 提供了--MARK--消息功能

# 提供UDP系统日志接收
#$ModLoad imudp
#$UDPServerRun  514

# 提供TCP日志接收
#$ModLoad imtcp
#$InputTCPServerRun 514

#### Global Directives(全局设置) ####
$WorkDirectory  /var/lib/rsyslog    # 辅助文件路径
$ActionFileDefaultTemplate  RSYSLOG_TraditionalFileFormat   # 使用默认的时间戳格式

$IncludeConfig  /etc/rsyslog.d/*.conf   # 包含是/etc/rsyslog.d目录的所有配置

# 关闭本地日志消息，通过imjournal完成本地消息记录
$OmitLocalLogging on

$IMJournalStateFile imjournal.state # 存放日志文件位置

#### Rules ####

# 将所有内核消息记录到控制台
#kern.* /dev/console

# 记录级别消息或更高级别的任何消息（邮件除外）
# 不要记录私人认证消息！！！
*.info;mail.none;authpriv.none;cron.none /var/log/message

# authpriv文件具有受限的访问权限
authpriv.* /var/log/secure

# 记录所有的邮件消息
mail.*  -/var/log/maillog
# 其中，符号'-'表示异步写入，邮件量大占IO，在系统不忙时处理消息

# 日志计划任务的东西
cron.* /var/log/cron

# 每个用户都得到紧急消息
*.emerg *

# local7级别消息保存
local7.* /var/log/boot.log

# 让满足上述过滤器条件的消息不再匹配后续的规则。默认情况下，日志消息会按照顺序匹配rsyslog.conf的每条规则。"& ~"会让消息跳过后面的规则，这样消息不会再被记录到其他的日志文件中
& ~

$template remote_path, "/data/rsyslog/%FROMHOST_IP%/%syslogfacility-text%/%$YEAR%-%$MONTH%-%$DAY%.log"
$template remote_path2, "/data/rsyslog/%FROMHOST_IP%/%syslogfacility-text%/%$YEAR%-%$MONTH%-%$DAY%2.log"
$template local1_path, "/data/rsyslog/%FROMHOST_IP%/history/%$YEAR%-%$MONTH%-%$DAY%.log"

# 条件表达式，如果ip不等于127.0.0.1，则将消息记录到remote-path和remote-path2中
if $fromhost-ip != '127.0.0.1' then ?remote-path;remote-path2

```