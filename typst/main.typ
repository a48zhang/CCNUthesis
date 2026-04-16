#import "template.typ": thesis, cover-page

#let meta = (
  title: "华中师范大学学位论文 Typst 模板",
  title_en: "CCNU Thesis Typst Template",
  author: "你的姓名",
  supervisor: "教师姓名 职称",
  department: "数学与统计学学院",
  major: "应用统计",
  degree: "本科 / 硕士 / 博士",
  date: datetime.today().display("[year]-[month]-[day]"),
  keywords: ("关键词1", "关键词2", "关键词3"),
)

#show: doc => thesis(meta, doc)

#cover-page(meta)
#pagebreak()

#include "front/abstract.typ"

#pagebreak()

= 符号表
#include "front/notation.typ"

#pagebreak()

#outline(title: [目 录])

#pagebreak()

#include "body/chapter0.typ"
#include "body/chapter1.typ"
#include "body/chapter2.typ"
#include "body/chapter3.typ"
#include "body/chapter4.typ"

#pagebreak()

#include "back/appendix.typ"

#pagebreak()

#bibliography("../CCNUthesis-main.bib", title: [参考文献])

#pagebreak()

#include "back/acknowledgements.typ"
