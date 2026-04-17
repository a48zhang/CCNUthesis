# CCNUthesis Typst 版本

本目录提供一个与原 LaTeX 模板结构对应的 Typst 版本，便于在 Typst 生态下进行论文写作与迁移。

## 目录结构

- `main.typ`：主入口
- `ccnu-setup.typ`：论文元信息配置
- `template.typ`：页面与封面等基础样式
- `front/`：摘要与符号表
- `body/`：正文各章
- `back/`：附录与致谢
- `validate-parity.sh`：LaTeX 与 Typst 编译产物像素级对比脚本

## 编译

在仓库根目录执行：

```bash
typst compile typst/main.typ
```

默认生成：`typst/main.pdf`

## 说明

- 保留与 LaTeX 版本接近的章节拆分方式（front/body/back）。
- 引文使用 `@文献键`，文献数据源使用 `typst/CCNUthesis-main.bib`（由仓库原始 bib 拷贝而来，便于独立编译）。
- 论文信息（题目、作者、导师等）集中在 `ccnu-setup.typ`，避免在版式代码中写死。
- `ccnu-setup.typ` 中的 `degree` 请按实际学位填写单一值（如：`本科`/`硕士`/`博士`）。
- `ccnu-setup.typ` 中可配置中英文字体族（`text_font`/`cjk_font`/`sans_font`/`mono_font`），用于对齐 LaTeX 字体效果。

## 像素级验收

在仓库根目录执行：

```bash
./typst/validate-parity.sh
```

若本机 LaTeX 使用了不同字体，可通过环境变量覆盖预检字体列表：

```bash
REQUIRED_FONTS="Times New Roman,Arial,Courier New" ./typst/validate-parity.sh
```

默认值为 `Times New Roman,Arial,Courier New`，定义在 `typst/validate-parity.sh` 中。
若你的 LaTeX 配置显式依赖 CJK 字体（如 SimSun），可改为：

```bash
REQUIRED_FONTS="Times New Roman,Arial,Courier New,SimSun" ./typst/validate-parity.sh
```

可先根据仓库根目录 `ccnu-setup.tex` 的 `font`/`cjk-font` 配置与 `main.log` 中的字体记录确认 LaTeX 实际使用字体，再设置 `REQUIRED_FONTS`。

脚本会：

1. 编译 `main.tex`（LaTeX）
2. 编译 `typst/main.typ`（Typst）
3. 栅格化为逐页 PNG
4. 逐页进行像素级比较（`AE == 0`）
