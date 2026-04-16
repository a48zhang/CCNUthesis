# CCNUthesis Typst 版本（示例）

本目录提供一个与原 LaTeX 模板结构对应的 Typst 版本示例，便于在 Typst 生态下进行论文写作与迁移。

## 目录结构

- `main.typ`：主入口
- `template.typ`：页面与封面等基础样式
- `front/`：摘要与符号表
- `body/`：正文各章
- `back/`：附录与致谢

## 编译

在仓库根目录执行：

```bash
typst compile typst/main.typ
```

默认生成：`typst/main.pdf`

## 说明

- 保留与 LaTeX 版本接近的章节拆分方式（front/body/back）。
- 引文使用 `@文献键`，文献数据源使用 `typst/CCNUthesis-main.bib`（由仓库原始 bib 拷贝而来，便于独立编译）。
- 本版本定位为“可编译的 Typst 起始模板”，便于后续继续补齐学校细节规范。
