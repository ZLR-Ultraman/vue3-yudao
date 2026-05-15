# 阶段 1: 构建阶段
FROM node:20-alpine AS builder

WORKDIR /app

# 安装 pnpm
RUN npm install -g pnpm

# 复制所有配置文件
COPY package.json pnpm-lock.yaml tsconfig.json vite.config.ts index.html ./
COPY .eslintrc.js .prettierignore ./
COPY build ./build
COPY types ./types

# 安装依赖
RUN pnpm install --frozen-lockfile

# 复制源代码和公共文件
COPY src ./src
COPY public ./public

# 构建生产版本
RUN pnpm run build:prod

# 阶段 2: 运行阶段
FROM nginx:1.27-alpine

# 删除默认 nginx 配置
RUN rm /etc/nginx/conf.d/default.conf

# 复制自定义 nginx 配置
COPY nginx.conf /etc/nginx/conf.d/nginx.conf

# 复制构建产物到 nginx 文件服务目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 暴露端口
EXPOSE 80

# 启动 nginx
CMD ["nginx", "-g", "daemon off;"]
