# PKGM-Web 项目记忆

> **绑定时间**: 2026-04-16  
> **群聊 ID**: `chat:oc_a1075829be1b03f1a41ff11b7b56e7f4`  
> **项目路径**: `/workspace/project/PKGM-Web`

---

## 项目概述

- **项目名**: PKGM-Web
- **类型**: Web 应用（PKGM 展示层）
- **技术栈**: Next.js + SQLite FTS5 + chokidar + SSE
- **架构文档**: `docs/ARCHITECTURE.md` v5.0

---

## 活跃任务

- [ ] 启动 Docker 容器（阻塞所有验证）
- [ ] Phase 0-4 验证（按顺序）
- [ ] 多用户端到端测试
- [ ] PKGM-Manager Agent（代码未实现）

---

## 当前状态（2026-04-22）

### 代码完成度
- Phase 0: ✅ docker-compose 完成
- Phase 1: ✅ Indexer 代码完成
- Phase 2: ✅ Next.js Build 完成
- Phase 3: ✅ 中文分词 + SSE（search highlighting 已 fix）
- Phase 4: 🔄 Docker 镜像构建完成，容器未启动

### 阻塞项
- **Docker 容器未启动** — `docker ps` 无输出，所有服务离线

### Git 历史
```
9a28794 update gitignore
0cbc49b remove unwanted
20c342c fix: phase3 search highlighting
42d2bbd checkpoint: phase3 pre-fix
70386e2 pkgm-web
9792eb0 feat: PKGM-Web MVP initial commit
```

---

## 关键决策

- 物理隔离多租户：每用户独立目录 + 独立 Agent + 独立 SQLite
- 文件系统是唯一数据源，SQLite 只是索引缓存
- Indexer 单实例多用户：chokidar 逐目录 watch + 按用户分组写入

---

## 待讨论事项

- PKGM-Manager Agent 代码实现（架构已定义）
- 多用户注册流程端到端测试
- 公网 HTTPS 部署

---

## 进度文档

- **MVP 进度报告**: `MVP-PROGRESS.md`（2026-04-22 新建）

**最后更新**: 2026-04-22 12:13