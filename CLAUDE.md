# CLAUDE.md - MaliangAIWriter 开发指南

## 项目概览

马良AI写作 (MaliangAIWriter) 是一个AI驱动的智能小说创作平台，采用前后端分离架构：

- **前端**: Flutter Web (AINoval目录)
- **后端**: Spring Boot WebFlux (AINovalServer目录)
- **数据库**: MongoDB 8.0 + Chroma向量数据库
- **部署**: Docker Compose 一键部署

## 核心功能

### 🎨 主要特性
- **智能写作**: 基于多种AI模型（OpenAI、Claude、Gemini等）的续写、扩写、润色
- **富文本编辑器**: 基于Flutter Quill，支持上千章节连续滚动
- **剧情推演**: AI辅助生成多个后续剧情走向，支持"抽卡"式选择
- **世界观构建**: AI生成结构化设定树，支持角色、地点、物品等设定管理
- **知识库拆书**: 从优秀小说中提取创作知识，支持番茄小说直连
- **管理后台**: 完整的用户管理、模型配置、LLM可观测性、积分计费系统

### 🏗️ 技术架构

#### 前端技术栈
- **框架**: Flutter (Web平台优先)
- **状态管理**: BLoC模式 (flutter_bloc)
- **UI组件**: Flutter Quill (富文本编辑器), fl_chart (图表)
- **网络请求**: Dio + 自定义ApiClient + SSE (Server-Sent Events)
- **本地存储**: Hive (状态持久化) + SharedPreferences
- **国际化**: flutter_localizations (支持中文)

#### 后端技术栈
- **框架**: Spring Boot 3.4.1 + WebFlux (响应式编程)
- **语言**: Java 21
- **AI集成**: LangChain4j (统一多AI模型接口)
- **数据库**: MongoDB 8.0 (响应式驱动)
- **向量数据库**: Chroma (RAG支持)
- **安全**: Spring Security + JWT
- **任务队列**: RabbitMQ (异步任务处理)
- **监控**: Micrometer + Prometheus + SkyWalking
- **缓存**: Caffeine

#### AI模型支持
- OpenAI (GPT-3.5, GPT-4系列)
- Anthropic (Claude系列)
- Google (Gemini系列)
- 智谱AI (GLM系列)
- 通义千问 (Qwen系列)
- OpenRouter (模型聚合)
- SiliconFlow, TogetherAI等

## 开发环境设置

### 快速启动 (Docker 一键部署)

```bash
# 1. 准备环境变量
cd deploy/open
cp production.env.example production.env
# 编辑 production.env，设置必要的配置

# 2. 下载后端JAR包
# 从GitHub releases下载 ainoval-server.jar 到 deploy/dist/ 目录

# 3. 启动服务
docker compose -f docker-compose.yml up -d

# 4. 初始化管理员账号
./init-admin.sh  # Linux/Mac
# 或
init-admin.bat  # Windows
```

访问地址：
- 主应用: http://localhost:18080/
- 管理后台: http://localhost:18080/admin
- API文档: http://localhost:18080/swagger-ui.html

默认管理员账号：
- 用户名: admin
- 密码: 123456

### 开发模式启动

#### 前端开发
```bash
cd AINoval
flutter pub get
flutter run -d chrome --web-port 3000
```

#### 后端开发
```bash
cd AINovalServer
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

## 项目结构详解

### 前端目录结构 (AINoval/)
```
AINoval/
├── lib/
│   ├── main.dart                    # 应用入口，包含所有BLoC初始化
│   ├── screens/                    # 页面组件
│   │   ├── editor/               # 编辑器页面
│   │   ├── novel_list/           # 小说列表页面
│   │   ├── chat/                 # AI聊天页面
│   │   ├── next_outline/         # 剧情推演页面
│   │   └── settings/            # 设置页面
│   ├── blocs/                      # 状态管理 (BLoC)
│   │   ├── auth_bloc.dart         # 用户认证状态
│   │   ├── novel_list_bloc.dart   # 小说列表状态
│   │   ├── chat_bloc.dart         # AI聊天状态
│   │   ├── editor_version_bloc.dart # 编辑器版本控制
│   │   └── ai_config_bloc.dart   # AI模型配置状态
│   ├── services/api_service/         # API调用层
│   │   ├── base/                 # ApiClient, SseClient基础类
│   │   └── repositories/         # 数据仓库接口及实现
│   ├── models/                      # 数据模型
│   ├── widgets/                     # 可复用组件
│   ├── utils/                       # 工具类
│   └── config/                      # 应用配置
├── assets/                           # 静态资源
└── pubspec.yaml                      # 依赖配置
```

### 后端目录结构 (AINovalServer/)
```
AINovalServer/
├── src/main/java/com/ainovel/server/
│   ├── AiNovelServerApplication.java  # 应用入口
│   ├── web/                         # Web层 (Controller)
│   │   ├── controller/              # REST API控制器
│   │   └── dto/                    # 数据传输对象
│   ├── service/                     # 业务服务层
│   │   ├── impl/                   # 服务实现
│   │   └── ai/                     # AI相关服务
│   ├── repository/                  # 数据访问层
│   ├── domain/                      # 领域模型 (Entity)
│   ├── config/                      # 配置类
│   ├── security/                    # 安全配置
│   └── common/                      # 通用工具类
├── src/main/resources/
│   ├── application.yml              # 主配置文件
│   ├── application-dev.yml         # 开发环境配置
│   └── static/                     # 静态资源
└── pom.xml                         # Maven配置
```

## 核心开发模式

### 1. BLoC状态管理模式

前端采用BLoC (Business Logic Component) 模式：

```dart
// 事件定义
abstract class NovelListEvent extends Equatable {}

class LoadNovels extends NovelListEvent {}
class AddNovel extends NovelListEvent { ... }

// 状态定义
abstract class NovelListState extends Equatable {}

class NovelListLoading extends NovelListState {}
class NovelListLoaded extends NovelListState { ... }

// BLoC实现
class NovelListBloc extends Bloc<NovelListEvent, NovelListState> {
  final NovelRepository repository;

  NovelListBloc({required this.repository}) : super(NovelListInitial()) {
    on<LoadNovels>(_onLoadNovels);
    on<AddNovel>(_onAddNovel);
  }
}
```

### 2. 响应式编程模式

后端采用Spring WebFlux响应式编程：

```java
// Controller层
@PostMapping("/create")
public Mono<ResponseEntity<NovelDto>> createNovel(
    @Valid @RequestBody CreateNovelRequest request,
    @CurrentUser String userId) {
    return novelService.createNovel(request, userId)
        .map(novel -> ResponseEntity.ok(novel))
        .onErrorResume(ex -> Mono.just(ResponseEntity.badRequest().build()));
}

// SSE流式响应
@GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
public Flux<ServerSentEvent<String>> streamEvents(
    @RequestParam String sessionId) {
    return chatService.streamMessages(sessionId)
        .map(data -> ServerSentEvent.builder(data)
            .event("chat-message")
            .build());
}
```

### 3. API调用规范

#### 统一请求规范
- **基础URL**: `AppConfig.apiBaseUrl` 已包含 `/api/v1/` 前缀
- **HTTP方法**: 除GET-SSE外，统一使用POST
- **认证头**: `Authorization: Bearer {token}` + `X-User-Id: {userId}`
- **SSE头**: `Accept: text/event-stream`, `Cache-Control: no-cache`

#### 前端调用示例
```dart
// 普通HTTP请求
final response = await apiClient.post('/novels/create', data: {
  'title': '新小说',
  'description': '描述'
});

// SSE流式请求
final eventStream = apiClient.postStream('/ai-chat/messages/stream', data: {
  'content': message,
  'sessionId': sessionId,
  'novelId': novelId
});

await for (final event in eventStream) {
  if (event.event == 'chat-message') {
    // 处理流式消息
  }
}
```

### 4. AI服务集成

#### 多Provider支持
```java
@Component
public class AIModelProviderFactory {

    public AIModelProvider createProvider(String provider, String model) {
        return switch (provider.toLowerCase()) {
            case "openai" -> new OpenAILangChain4jModelProvider(model);
            case "anthropic" -> new AnthropicLangChain4jModelProvider(model);
            case "gemini" -> new GeminiLangChain4jModelProvider(model);
            default -> throw new UnsupportedProviderException(provider);
        };
    }
}
```

#### 统一AI调用接口
```dart
// 前端统一调用
class UniversalAIRepository {
  Future<UniversalAIResponse> generateContent({
    required String prompt,
    required AIConfig config,
    bool stream = false
  }) async {
    return await _apiClient.post('/ai/universal/' + (stream ? 'stream' : 'request'), data: {
      'prompt': prompt,
      'aiConfig': config.toJson(),
      'stream': stream
    });
  }
}
```

## 关键业务流程

### 1. 用户认证流程
1. 用户登录/注册 → AuthBloc处理
2. JWT Token存储 → AuthService管理
3. 自动刷新Token → ApiClient拦截器处理
4. 401错误自动登出 → 全局异常处理

### 2. AI聊天流程
1. 创建聊天会话 → `/ai-chat/sessions/create`
2. 发送消息 → `/ai-chat/messages/stream` (SSE)
3. 流式接收响应 → 事件类型: `chat-message`
4. 自动保存历史 → 后端异步处理

### 3. 小说导入流程
1. 上传文件预览 → `/upload-preview` (Multipart)
2. 解析章节结构 → `/preview`
3. 确认导入 → `/confirm` → 返回jobId
4. 监听进度 → `/novels/import/{jobId}/status` (SSE)

### 4. 剧情推演流程
1. 生成推演选项 → `/novels/{id}/next-outlines/generate-stream`
2. 流式接收选项 → 事件类型: `outline-chunk`
3. 单独重生成选项 → `/regenerate-option`
4. 应用选定大纲 → 更新小说内容

## 开发命令汇总

### Docker部署
```bash
# 构建镜像
docker compose -f deploy/open/docker-compose.yml build

# 启动服务
docker compose -f deploy/open/docker-compose.yml up -d

# 查看日志
docker compose -f deploy/open/docker-compose.yml logs -f ainoval

# 重启服务
docker compose -f deploy/open/docker-compose.yml restart ainoval

# 停止服务
docker compose -f deploy/open/docker-compose.yml down
```

### 前端开发
```bash
cd AINoval

# 安装依赖
flutter pub get

# 运行Web版本
flutter run -d chrome --web-port 3000

# 构建生产版本
flutter build web --web-renderer canvaskit

# 代码生成 (JSON序列化)
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 后端开发
```bash
cd AINovalServer

# 开发模式启动
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# 构建JAR包
./mvnw clean package -DskipTests

# 运行测试
./mvnw test

# 性能测试
./mvnw gatling:test
```

## 重要配置说明

### 环境变量配置 (production.env)
```bash
# 数据库配置
SPRING_DATA_MONGODB_URI=mongodb://admin:admin123@mongo:27017/ainovel?replicaSet=rs0

# JWT配置
JWT_SECRET=changeme_in_production_environment

# AI模型API密钥
OPENAI_API_KEY=your_openai_key
ANTHROPIC_API_KEY=your_anthropic_key
GEMINI_API_KEY=your_gemini_key

# 阿里云配置
ALIYUN_SMS_ACCESS_KEY_ID=your_sms_access_key
ALIYUN_OSS_ACCESS_KEY_ID=your_oss_access_key

# 代理配置
PROXY_ENABLED=false
PROXY_HOST=localhost
PROXY_PORT=7890
```

### 关键功能开关
```yaml
# application.yml
ainovel:
  features:
    setting-tree-generation:
      init-on-startup: false  # 是否在启动时初始化设定树
  performance:
    virtual-threads:
      enabled: true  # 虚拟线程优化
  monitoring:
    enabled: true   # 监控开关
  version-control:
    enabled: true   # 版本控制功能
```

## 常见开发场景

### 添加新的AI模型提供商
1. 后端: 创建 `NewProviderModelProvider.java` 实现 `AIModelProvider`
2. 后端: 在 `AIModelProviderFactory` 中添加新的case
3. 前端: 在 `ai_config_bloc.dart` 中添加模型配置
4. 前端: 更新模型选择UI组件

### 添加新的AI功能
1. 后端: 在 `UniversalAIController` 中添加新端点
2. 后端: 在 `AIService` 中实现业务逻辑
3. 前端: 在 `UniversalAIRepository` 中添加API调用
4. 前端: 创建对应的BLoC和UI组件

### 扩展富文本编辑器
1. 前端: 修改 `editor/` 目录下的组件
2. 前端: 在 `editor_toolbar.dart` 中添加新工具
3. 前端: 通过 `Flutter Quill` 的自定义模块扩展功能

## 调试和监控

### 后端监控
- **健康检查**: http://localhost:18080/actuator/health
- **Prometheus指标**: http://localhost:18080/actuator/prometheus
- **应用信息**: http://localhost:18080/actuator/info
- **日志位置**: `logs/` 目录

### 前端调试
- **开发者工具**: Chrome DevTools
- **日志级别**: 通过 `AppConfig.logLevel` 配置
- **网络请求**: 在ApiClient中开启调试模式

### 常见问题排查
1. **SSE连接失败**: 检查CORS配置和代理设置
2. **AI调用超时**: 调整 `resilience.timeout.duration` 配置
3. **MongoDB连接失败**: 确认副本集配置和认证信息
4. **前端编译失败**: 检查Flutter版本和依赖兼容性

## 最佳实践

### 代码规范
- 前端遵循Dart官方代码规范，使用 `flutter_lints`
- 后端遵循Spring Boot最佳实践，使用Lombok减少样板代码
- 统一异常处理和错误响应格式
- API设计遵循RESTful原则

### 性能优化
- 前端使用代码分割和懒加载减少初始包大小
- 后端使用虚拟线程和响应式编程提高并发性能
- 合理使用缓存减少数据库访问
- AI调用使用限流和重试机制保证稳定性

### 安全考虑
- 所有API接口需要JWT认证
- 敏感配置使用环境变量管理
- API调用实施限流保护
- 用户数据严格隔离访问权限

---

本文档帮助开发者快速理解马良AI写作系统的架构和开发模式。更多详细信息请参考：
- 项目整体架构: `/ARCHITECTURE.md`
- 前端API指南: `/.cursor/rules/frontbackapiguide.mdc`
- 部署指南: `/deploy/open/README.md`