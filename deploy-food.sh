#!/bin/bash

# 颜色变量
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# 错误处理函数
handle_error() {
    echo -e "${RED}错误: $1${NC}"
    exit 1
}

echo -e "${GREEN}开始部署食材管理系统...${NC}"

# 1. 安装 nvm 和 Node.js
echo -e "${GREEN}1. 安装 nvm 和 Node.js${NC}"

# 确保 nvm 目录存在
export NVM_DIR="/root/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    echo "安装 nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    source $NVM_DIR/nvm.sh
    source $NVM_DIR/bash_completion
fi

# 重新加载 shell 配置
source ~/.bashrc

# 加载 nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 安装并使用 Node.js
echo "安装 Node.js 18..."
nvm install 18 || handle_error "Node.js 安装失败"
nvm use 18 || handle_error "Node.js 切换失败"
nvm alias default 18

# 验证安装
node_path=$(which node)
echo "Node.js 路径: $node_path"
echo "Node.js 版本: $(node -v)"
echo "npm 版本: $(npm -v)"

# 2. 安装 pm2
echo -e "${GREEN}2. 安装 pm2${NC}"
npm install -g pm2 || handle_error "pm2 安装失败"

# 3. 创建项目目录
echo -e "${GREEN}3. 创建项目目录${NC}"
rm -rf /var/www/food-manage
mkdir -p /var/www/food-manage || handle_error "创建项目目录失败"

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

# 验证 package.json 是否创建成功
if [ ! -f "/var/www/food-manage/package.json" ]; then
    handle_error "package.json 创建失败"
fi
echo "package.json 创建成功"

# 5. 复制项目文件
echo -e "${GREEN}5. 复制项目文件${NC}"
for dir in app components types utils; do
    if [ -d "$dir" ]; then
        cp -r $dir /var/www/food-manage/ || handle_error "复制 $dir 目录失败"
        echo "$dir 目录复制成功"
    else
        echo "警告: $dir 目录不存在"
    fi
done

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
cd /var/www/food-manage || handle_error "切换到项目目录失败"
echo "当前目录: $(pwd)"
echo "目录内容:"
ls -la

npm install || handle_error "npm install 失败"
npm run build || handle_error "npm build 失败"

# 8. 配置 Caddy
echo -e "${GREEN}8. 配置 Caddy${NC}"
mkdir -p /etc/caddy/Caddyfile.d || handle_error "创建 Caddy 配置目录失败"

cat > /etc/caddy/Caddyfile << EOL
{
    admin off
}

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
systemctl reload caddy || handle_error "Caddy 重载失败"

# 10. 使用 pm2 启动服务
echo -e "${GREEN}10. 启动服务${NC}"
cd /var/www/food-manage || handle_error "切换到项目目录失败"
pm2 delete food-manage 2>/dev/null || true
pm2 start npm --name "food-manage" -- start || handle_error "启动服务失败"
pm2 save || handle_error "保存 pm2 配置失败"

# 11. 设置开机自启
echo -e "${GREEN}11. 设置开机自启${NC}"
pm2 startup || handle_error "设置开机自启失败"
pm2 save || handle_error "保存 pm2 配置失败"

echo -e "${GREEN}部署完成！${NC}"
echo -e "您现在可以通过 https://f.076095598.xyz 访问食材管理系统" 