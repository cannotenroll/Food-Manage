#!/bin/bash

# 颜色变量
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}开始部署食材管理系统...${NC}"

# 1. 安装 nvm 和 Node.js
echo -e "${GREEN}1. 安装 nvm 和 Node.js${NC}"

# 确保 nvm 目录存在
export NVM_DIR="/root/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    echo "安装 nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
fi

# 加载 nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 安装并使用 Node.js
echo "安装 Node.js 18..."
. $NVM_DIR/nvm.sh && nvm install 18
. $NVM_DIR/nvm.sh && nvm use 18
. $NVM_DIR/nvm.sh && nvm alias default 18

# 验证安装
node_path=$(which node)
echo "Node.js 路径: $node_path"
echo "Node.js 版本: $(node -v)"
echo "npm 版本: $(npm -v)"

# 2. 安装 pm2
echo -e "${GREEN}2. 安装 pm2${NC}"
. $NVM_DIR/nvm.sh && npm install -g pm2

# 3. 创建项目目录
echo -e "${GREEN}3. 创建项目目录${NC}"
mkdir -p /var/www/food-manage

# 4. 复制项目文件
echo -e "${GREEN}4. 复制项目文件${NC}"
cp -r * /var/www/food-manage/

# 5. 安装依赖和构建
echo -e "${GREEN}5. 安装依赖和构建${NC}"
cd /var/www/food-manage
. $NVM_DIR/nvm.sh && npm install
. $NVM_DIR/nvm.sh && npm run build

# 6. 配置 Caddy
echo -e "${GREEN}6. 配置 Caddy${NC}"
mkdir -p /etc/caddy/Caddyfile.d
sudo tee /etc/caddy/Caddyfile.d/food.conf > /dev/null << EOL
f.076095598.xyz {
    tls /etc/ssl/web.crt /etc/ssl/web.key
    reverse_proxy localhost:3000
}
EOL

# 7. 重载 Caddy 配置
echo -e "${GREEN}7. 重载 Caddy 配置${NC}"
systemctl reload caddy

# 8. 使用 pm2 启动服务
echo -e "${GREEN}8. 启动服务${NC}"
. $NVM_DIR/nvm.sh && pm2 delete food-manage 2>/dev/null || true
. $NVM_DIR/nvm.sh && pm2 start npm --name "food-manage" -- start
. $NVM_DIR/nvm.sh && pm2 save

# 9. 设置开机自启
echo -e "${GREEN}9. 设置开机自启${NC}"
. $NVM_DIR/nvm.sh && pm2 startup debian
env PATH=$PATH:/root/.nvm/versions/node/v18/bin /root/.nvm/versions/node/v18/lib/node_modules/pm2/bin/pm2 startup debian -u root --hp /root

echo -e "${GREEN}部署完成！${NC}"
echo -e "您现在可以通过 https://f.076095598.xyz 访问食材管理系统" 