#!/bin/bash

# 颜色变量
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}开始部署食材管理系统...${NC}"

# 1. 安装 nvm 和 Node.js
echo -e "${GREEN}1. 安装 nvm 和 Node.js${NC}"
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
else
    # 确保 nvm 命令可用
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    echo "nvm 已安装"
fi

# 确保使用正确的 Node.js 版本
nvm install 18
nvm use 18

# 2. 安装 pm2
echo -e "${GREEN}2. 安装 pm2${NC}"
npm install -g pm2

# 3. 创建项目目录
echo -e "${GREEN}3. 创建项目目录${NC}"
sudo mkdir -p /var/www/food-manage
sudo chown -R $USER:$USER /var/www/food-manage

# 4. 复制项目文件
echo -e "${GREEN}4. 复制项目文件${NC}"
cp -r * /var/www/food-manage/

# 5. 安装依赖和构建
echo -e "${GREEN}5. 安装依赖和构建${NC}"
cd /var/www/food-manage
npm install
npm run build

# 6. 配置 Caddy
echo -e "${GREEN}6. 配置 Caddy${NC}"
sudo tee /etc/caddy/Caddyfile.d/food.conf > /dev/null << EOL
f.076095598.xyz {
    tls /etc/ssl/web.crt /etc/ssl/web.key
    reverse_proxy localhost:3000
}
EOL

# 7. 重载 Caddy 配置
echo -e "${GREEN}7. 重载 Caddy 配置${NC}"
sudo systemctl reload caddy

# 8. 使用 pm2 启动服务
echo -e "${GREEN}8. 启动服务${NC}"
export PATH=$PATH:/home/$USER/.nvm/versions/node/v18/bin
pm2 delete food-manage 2>/dev/null || true
pm2 start npm --name "food-manage" -- start
pm2 save

# 9. 设置开机自启
echo -e "${GREEN}9. 设置开机自启${NC}"
pm2 startup debian
sudo env PATH=$PATH:/home/$USER/.nvm/versions/node/v18/bin /home/$USER/.nvm/versions/node/v18/lib/node_modules/pm2/bin/pm2 startup debian -u $USER --hp /home/$USER

echo -e "${GREEN}部署完成！${NC}"
echo -e "您现在可以通过 https://f.076095598.xyz 访问食材管理系统" 