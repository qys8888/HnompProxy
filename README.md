# minerProxy
已内置加密证书，可以自定义ssl证书,在程序目录下放入server.key和server.pem文件即可；

开发费恒定千三！无论你抽3%还是30%，甚至80%，都是0.3%开发费！
支持ETC转发！

# 更新日志
```bigquery
2022-04-17 18:00    1.5.2b>>> 优化抽水逻辑，抽水更平稳
2022-04-14 18:00    1.5.1>>> 优化中转性能、优化内存占用、优化小算力矿机抽水比例
2022-04-08 18:00    1.5.0>>> 优化抽水算法、优化控制台日志打印、提升性能
2022-04-05 17:00    1.4.2>>> 修复某些情况下代理抽水异常的BUG、优化逻辑，提升性能
2022-03-30 16:00    1.3.0>>> 增加服务硬件信息概况、增加矿池延时信息、优化界面、提升性能
2022-03-25 16:00    1.2.0>>> 增强安全性、增加ETC币种、优化图表展示、性能优化
2022-03-24 17:00    1.1.1>>> 优化折线图、优化数据展示、优化矿机列表
2022-03-22 23:00    1.1.0>>> 修复：抽水矿机名问题，曲线图展示问题，端口列表里面显示离线设备数量
2022-03-15 19:00    1.0.0>>>第一个版本发布
```
# windows版本下载:
[点击下载 ](https://github.com/ethminerpro/minerproxy/raw/main/ethminerproxy_windows.exe) 。
# 新增linux一件脚本安装
```
bash <( curl -s -L https://raw.githubusercontent.com/ethminerpro/MinerProxy/main/install.sh )
```

交流电报群https://t.me/trexminerproxy

![5.png](5.png)


## 重要说明
```bigquery
建议不要使用国内厂商的服务器，尽量选用国外运营商的服务器，
为了安全，必须开启ssl端口
开发者抽水恒定0.3%！！目前运行最稳定的软件；欢迎实测！
不建议抽太多，做到可持续发展，托管时请一定告知客户存在托管费

ETH/ETC的归集功能由于跨池存在难度、协议不一致等原因，可能导致你抽到的算力过大/过小甚至于无法抽取等情况

4核心4G内存的搬瓦工，带机6000台，测试4天，机器稳定不掉线
```

# 如果你算力不准：
①第一检查挖矿软件配置及内核配置，是否设置超过多少分钟没有成功提交重启内核

②查看你服务器的硬件配置及软件带宽，配置过低可能导致转发性能不足，导致重发及超时

③检查你服务器的网络是否占用超过60%以上，是的话加带宽
