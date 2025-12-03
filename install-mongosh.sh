#!/bin/bash
# MongoDB Shell (mongosh) 安装脚本

set -e

echo "正在添加 MongoDB APT 仓库源..."

# 添加 MongoDB 仓库源
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list

echo "正在更新包列表..."
apt update

echo "正在安装 mongosh..."
apt install -y mongodb-mongosh

echo ""
echo "✅ mongosh 安装完成！"
echo ""
echo "验证安装："
mongosh --version

echo ""
echo "连接 MongoDB 的示例命令："
echo "mongosh 'mongodb://admin:admin123@localhost:27017/ainovel?authSource=admin'"
echo ""
echo "或者分步连接："
echo "mongosh"
echo "# 然后在 mongosh 中执行："
echo "# use admin"
echo "# db.auth('admin', 'admin123')"
echo "# use ainovel"

