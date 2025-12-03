FROM eclipse-temurin:21-jdk-jammy

# 安装基础工具
RUN apt-get update && \
    apt-get install -y zsh git curl wget && \
    rm -rf /var/lib/apt/lists/*

# 设置 zsh 为默认 shell
RUN chsh -s $(which zsh)

# 设置环境变量
ENV ZSH=/root/.oh-my-zsh
ENV SHELL=/bin/zsh

# 安装 oh-my-zsh（非交互式）
RUN sh -c "$(curl -fsSL https://install.ohmyz.sh/)" "" --unattended

# 安装 powerlevel10k 主题
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# 安装 zsh 插件
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 https://github.com/zdharma-continuum/history-search-multi-word.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/history-search-multi-word

COPY dev/.zshrc.example /root/.zshrc

# 安装 Maven
RUN apt-get update && \
    apt-get install -y maven && \
    rm -rf /var/lib/apt/lists/*

# 安装 mongosh
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
    gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | \
    tee /etc/apt/sources.list.d/mongodb-org-8.0.list && \
    apt-get update && \
    apt-get install -y mongodb-mongosh && \
    rm -rf /var/lib/apt/lists/*

# 安装 Flutter SDK
RUN apt-get update && \
    apt-get install -y \
    wget \
    unzip \
    xz-utils \
    libglu1-mesa \
    libgtk-3-0 \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxi6 \
    libxtst6 \
    libnss3 \
    libcups2 \
    libxss1 \
    libxrandr2 \
    libasound2 \
    libpangocairo-1.0-0 \
    libatk1.0-0 \
    libcairo-gobject2 \
    libgtk-3-0 \
    libgdk-pixbuf2.0-0 && \
    rm -rf /var/lib/apt/lists/*

# 下载并安装Flutter SDK（使用git clone方式支持arm64）
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1 /opt/flutter

# 设置Flutter环境变量
ENV PATH="/opt/flutter/bin:${PATH}"
ENV FLUTTER_ROOT="/opt/flutter"
ENV FLUTTER_WEB_AUTO_DETECT=true
ENV FLUTTER_WEB_USE_SKIA=true

# 添加 git safe.directory 配置（解决权限警告）
RUN git config --global --add safe.directory /opt/flutter

# 配置Flutter（使用 || true 避免 doctor 检查失败导致构建中断）
RUN flutter config --enable-web && \
    flutter config --enable-linux && \
    flutter doctor || true

# 安装Chromium（用于Flutter Web开发）
RUN apt-get update && \
    apt-get install -y chromium-browser && \
    rm -rf /var/lib/apt/lists/*

# 设置Chromium环境变量
ENV CHROME_EXECUTABLE=/usr/bin/chromium-browser
ENV CHROME_NO_SANDBOX=1
