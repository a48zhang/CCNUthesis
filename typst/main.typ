#import "template.typ": thesis, cover-page
#import "ccnu-setup.typ": meta

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

#bibliography("CCNUthesis-main.bib", title: [参考文献])

#pagebreak()

#include "back/acknowledgements.typ"
