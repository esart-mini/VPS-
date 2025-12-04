#!/bin/bash

# 定义选项和默认值
SWAP_OPTIONS=( "256M" "512M" "1G" "2G" "4G" )
DEFAULT_INDEX=3 # 2G 对应的索引 (从 0 开始计数)
DEFAULT_SIZE=${SWAP_OPTIONS[$DEFAULT_INDEX]}

# 定义交换文件路径
SWAPFILE="/swapfile"

# 检查是否以 root 权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "⚠️ 错误：此脚本必须使用 root 权限运行 (例如：sudo ./setup_swap.sh)。"
    exit 1
fi

echo "### 🚀 Linux 交换分区设置脚本 ###"
echo "请选择您希望设置的交换分区大小，默认值为 ${DEFAULT_SIZE} (按 Enter 键接受默认值):"
echo "-------------------------------------"
for i in "${!SWAP_OPTIONS[@]}"; do
    # 打印选项编号和大小
    printf "[%d] %s\n" $((i+1)) "${SWAP_OPTIONS[$i]}"
done
echo "-------------------------------------"

read -p "请输入编号 (1-${#SWAP_OPTIONS[@]}): " CHOICE

# 处理用户输入
if [[ -z "$CHOICE" ]]; then
    # 用户按 Enter 键，使用默认值
    SWAPSIZE=$DEFAULT_SIZE
elif [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "${#SWAP_OPTIONS[@]}" ]; then
    # 用户输入了有效数字
    SWAPSIZE=${SWAP_OPTIONS[$((CHOICE-1))]}
else
    echo "❌ 输入无效。脚本退出。"
    exit 1
fi

FSTAB_LINE="$SWAPFILE none swap sw 0 0"

echo "目标：创建并启用一个 ${SWAPSIZE} 大小的交换文件 (${SWAPFILE})"

# 步骤 1: 检查当前交换分区状态并关闭所有交换
echo -e "\n--- 1. 检查并关闭当前所有交换分区 ---"
swapon --show
echo "正在关闭所有当前启用的交换区..."
swapoff -a
echo "所有交换区已关闭。"

# 步骤 2: 创建选定大小的交换文件
echo -e "\n--- 2. 创建 ${SWAPSIZE} 交换文件 ---"
if command -v fallocate &> /dev/null; then
    echo "使用 fallocate 创建文件 (速度更快)..."
    fallocate -l ${SWAPSIZE} ${SWAPFILE}
else
    # 转换为 M 字节数给 dd
    if [[ "$SWAPSIZE" =~ G$ ]]; then
        DD_COUNT=$((${SWAPSIZE/G/} * 1024))
    elif [[ "$SWAPSIZE" =~ M$ ]]; then
        DD_COUNT=${SWAPSIZE/M/}
    else
        echo "❌ 错误：dd 无法处理此大小单位，请使用 fallocate。"
        exit 1
    fi
    echo "使用 dd 创建文件 (fallocate 不可用)..."
    dd if=/dev/zero of=${SWAPFILE} bs=1M count=${DD_COUNT}
fi

if [ $? -ne 0 ]; then
    echo "❌ 错误：交换文件创建失败！请检查磁盘空间。"
    exit 1
fi

# 步骤 3: 设置交换文件权限
echo -e "\n--- 3. 设置交换文件权限 ---"
chmod 600 ${SWAPFILE}
ls -lh ${SWAPFILE}

# 步骤 4: 将文件设置为交换区
echo -e "\n--- 4. 格式化文件为交换区 ---"
mkswap ${SWAPFILE}

# 步骤 5: 启用新的交换文件
echo -e "\n--- 5. 启用新的交换文件 ---"
swapon ${SWAPFILE}

# 步骤 6: 验证新的交换区
echo -e "\n--- 6. 验证新的交换区 ---"
echo "--- swapon --show 输出 ---"
swapon --show
echo "--- free -h 输出 ---"
free -h

# 步骤 7: 设置开机自动挂载
echo -e "\n--- 7. 设置开机自动挂载 (/etc/fstab) ---"
if grep -q "$SWAPFILE" /etc/fstab; then
    echo "✅ /etc/fstab 中已存在 ${SWAPFILE} 条目，跳过添加。"
else
    # 使用 tee -a 确保权限正确
    echo "${FSTAB_LINE}" | sudo tee -a /etc/fstab > /dev/null
    echo "✅ 已将以下行添加到 /etc/fstab:"
    echo "${FSTAB_LINE}"
fi

echo -e "\n### 🎉 设置完成！###"
echo "您的 ${SWAPFILE} 交换文件已创建并启用，并在下次重启时自动挂载。"
