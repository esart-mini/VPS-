# VPS
用于垃圾小鸡 快捷安装  TCP加速


## 基本安装(基本够用)
### 1. 安装233singbox脚本
> 系统支持：Ubuntu，Debian，CentOS，推荐使用 Ubuntu 22，谨慎使用 CentOS，脚本可能无法正常运行！
```bash
bash <(wget -qO- -o- https://github.com/233boy/sing-box/raw/main/install.sh)
```
### 2. 安装3x-ui面板
```bash
bash <(wget -qO- -o- https://github.com/233boy/sing-box/raw/main/install.sh)
```

### 3. 线路连接不好、Hy2有Qos， 可以尝试勇哥开启CDN优选的节点运行脚本(添加Argo 临时隧道/固定隧道)
#### Vmess-ws-argo临时隧道CDN优选节点
```bash
vmpt="" argo="vmpt" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```
#### Vless-ws-vision-enc-argo临时隧道CDN优选节点
```bash
vwpt="" argo="vwpt" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

## swap扩大
```bash
wget -q https://raw.githubusercontent.com/esart-mini/VPS-/main/setup_swap.sh -O swap.sh && bash swap.sh
```



## BBR加速（推荐V3版本）
### 安装一键加速脚本
```bash
wget https://raw.githubusercontent.com/byJoey/Actions-bbr-v3/refs/heads/main/install.sh
./install.sh
```
- 选择 1: 安装BBR V3内核， 重启
- 先测速，如果速度不行在选择后面方案(fq | CAKE ...)， 线路不同加速效果也不同
