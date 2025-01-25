#!/bin/bash

# 颜色变量
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 错误处理函数
handle_error() {
    echo -e "${RED}错误: $1${NC}"
    echo "当前目录: $(pwd)"
    echo "目录内容:"
    ls -la
    exit 1
}

# 检查文件是否存在
check_file() {
    if [ ! -f "$1" ]; then
        handle_error "文件不存在: $1"
    else
        echo -e "${GREEN}文件存在: $1${NC}"
        echo -e "${YELLOW}文件内容:${NC}"
        cat "$1"
        echo -e "${YELLOW}------------------------${NC}"
    fi
}

# 调试信息函数
debug_info() {
    echo -e "${YELLOW}调试信息: $1${NC}"
    echo "当前目录: $(pwd)"
    echo "目录内容:"
    ls -la
    echo -e "${YELLOW}------------------------${NC}"
}

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
cd /var/www/food-manage || handle_error "切换到项目目录失败"
debug_info "项目目录创建完成"

# 4. 创建 package.json
echo -e "${GREEN}4. 创建 package.json${NC}"
echo "正在创建 package.json..."
cat > package.json << 'EOL'
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
check_file "package.json"
debug_info "package.json 创建完成"

# 5. 创建项目结构
echo -e "${GREEN}5. 创建项目结构${NC}"
mkdir -p app components types utils || handle_error "创建项目结构失败"
debug_info "项目结构创建完成"

# 6. 创建基本组件和页面
echo -e "${GREEN}6. 创建基本组件和页面${NC}"

# 创建 layout.tsx
echo "创建 app/layout.tsx..."
cat > app/layout.tsx << 'EOL'
import './globals.css'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="zh">
      <body>{children}</body>
    </html>
  )
}
EOL
check_file "app/layout.tsx"

# 创建 globals.css
echo "创建 app/globals.css..."
cat > app/globals.css << 'EOL'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOL
check_file "app/globals.css"

# 创建 page.tsx
echo "创建 app/page.tsx..."
cat > app/page.tsx << 'EOL'
import Link from "next/link"

export default function Home() {
  return (
    <div className="min-h-screen bg-gray-50 flex flex-col items-center justify-center p-4">
      <main className="bg-white rounded-lg shadow-md p-8 w-full max-w-md">
        <h1 className="text-3xl font-bold text-center mb-8">食材管理系统</h1>
        <nav className="space-y-4">
          <Link href="/inventory" className="block">
            <button className="w-full p-2 text-left hover:bg-gray-100 rounded">
              📦 库存管理
            </button>
          </Link>
          <Link href="/purchase" className="block">
            <button className="w-full p-2 text-left hover:bg-gray-100 rounded">
              🛒 采购管理
            </button>
          </Link>
          <Link href="/usage" className="block">
            <button className="w-full p-2 text-left hover:bg-gray-100 rounded">
              🍽️ 领用管理
            </button>
          </Link>
          <Link href="/reports" className="block">
            <button className="w-full p-2 text-left hover:bg-gray-100 rounded">
              📊 报表生成
            </button>
          </Link>
        </nav>
      </main>
    </div>
  )
}
EOL
check_file "app/page.tsx"

# 7. 创建配置文件
echo -e "${GREEN}7. 创建配置文件${NC}"

# 创建 next.config.js
echo "创建 next.config.js..."
cat > next.config.js << 'EOL'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  output: 'standalone'
}
module.exports = nextConfig
EOL
check_file "next.config.js"

# 创建 tsconfig.json
echo "创建 tsconfig.json..."
cat > tsconfig.json << 'EOL'
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
check_file "tsconfig.json"

# 创建 postcss.config.js
echo "创建 postcss.config.js..."
cat > postcss.config.js << 'EOL'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOL
check_file "postcss.config.js"

# 创建 tailwind.config.js
echo "创建 tailwind.config.js..."
cat > tailwind.config.js << 'EOL'
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
check_file "tailwind.config.js"

# 8. 安装依赖和构建
echo -e "${GREEN}8. 安装依赖和构建${NC}"
debug_info "准备安装依赖"

# 再次确认 package.json 存在
check_file "package.json"

echo "开始安装依赖..."
npm install || handle_error "npm install 失败"
debug_info "依赖安装完成"

echo "开始构建项目..."
npm run build || handle_error "npm build 失败"
debug_info "项目构建完成"

# 9. 配置 Caddy
echo -e "${GREEN}9. 配置 Caddy${NC}"
mkdir -p /etc/caddy/Caddyfile.d || handle_error "创建 Caddy 配置目录失败"

echo "创建主 Caddyfile..."
cat > /etc/caddy/Caddyfile << 'EOL'
{
    admin off
}

import /etc/caddy/Caddyfile.d/*
EOL
check_file "/etc/caddy/Caddyfile"

echo "创建 food.conf..."
cat > /etc/caddy/Caddyfile.d/food.conf << 'EOL'
f.076095598.xyz {
    tls /etc/ssl/web.crt /etc/ssl/web.key
    reverse_proxy localhost:3000
}
EOL
check_file "/etc/caddy/Caddyfile.d/food.conf"

# 10. 重载 Caddy 配置
echo -e "${GREEN}10. 重载 Caddy 配置${NC}"
systemctl reload caddy || handle_error "Caddy 重载失败"

# 11. 使用 pm2 启动服务
echo -e "${GREEN}11. 启动服务${NC}"
cd /var/www/food-manage || handle_error "切换到项目目录失败"
debug_info "准备启动服务"

pm2 delete food-manage 2>/dev/null || true
pm2 start npm --name "food-manage" -- start || handle_error "启动服务失败"
pm2 save || handle_error "保存 pm2 配置失败"

# 12. 设置开机自启
echo -e "${GREEN}12. 设置开机自启${NC}"
pm2 startup || true
pm2 save || handle_error "保存 pm2 配置失败"

echo -e "${GREEN}部署完成！${NC}"
echo -e "您现在可以通过 https://f.076095598.xyz 访问食材管理系统" 