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

# 4. 创建 package.json
echo -e "${GREEN}4. 创建 package.json${NC}"
cat > /var/www/food-manage/package.json << EOL
{
  "name": "food-manage",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "@types/node": "^20.0.0",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "autoprefixer": "^10.4.0",
    "lucide-react": "^0.294.0",
    "next": "14.0.3",
    "postcss": "^8.4.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "tailwindcss": "^3.3.0",
    "typescript": "^5.0.0"
  }
}
EOL

# 5. 复制项目文件
echo -e "${GREEN}5. 复制项目文件${NC}"
cp -r app components types utils /var/www/food-manage/

# 6. 创建必要的配置文件
echo -e "${GREEN}6. 创建配置文件${NC}"
cat > /var/www/food-manage/next.config.js << EOL
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  output: 'standalone'
}
module.exports = nextConfig
EOL

cat > /var/www/food-manage/tsconfig.json << EOL
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOL

cat > /var/www/food-manage/postcss.config.js << EOL
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOL

cat > /var/www/food-manage/tailwind.config.js << EOL
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOL

# 7. 安装依赖和构建
echo -e "${GREEN}7. 安装依赖和构建${NC}"
cd /var/www/food-manage
. $NVM_DIR/nvm.sh && npm install
. $NVM_DIR/nvm.sh && npm run build

# 8. 配置 Caddy
echo -e "${GREEN}8. 配置 Caddy${NC}"
mkdir -p /etc/caddy/Caddyfile.d
cat > /etc/caddy/Caddyfile << EOL
import /etc/caddy/Caddyfile.d/*
EOL

cat > /etc/caddy/Caddyfile.d/food.conf << EOL
f.076095598.xyz {
    tls /etc/ssl/web.crt /etc/ssl/web.key
    reverse_proxy localhost:3000
}
EOL

# 9. 重载 Caddy 配置
echo -e "${GREEN}9. 重载 Caddy 配置${NC}"
systemctl reload caddy

# 10. 使用 pm2 启动服务
echo -e "${GREEN}10. 启动服务${NC}"
cd /var/www/food-manage
. $NVM_DIR/nvm.sh && pm2 delete food-manage 2>/dev/null || true
. $NVM_DIR/nvm.sh && pm2 start npm --name "food-manage" -- start
. $NVM_DIR/nvm.sh && pm2 save

# 11. 设置开机自启
echo -e "${GREEN}11. 设置开机自启${NC}"
. $NVM_DIR/nvm.sh && pm2 startup systemd
. $NVM_DIR/nvm.sh && pm2 save

echo -e "${GREEN}部署完成！${NC}"
echo -e "您现在可以通过 https://f.076095598.xyz 访问食材管理系统" 