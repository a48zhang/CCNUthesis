#let thesis(meta, body) = {
  set document(
    title: meta.title,
    author: meta.author,
    keywords: meta.keywords,
  )
  set page(
    paper: "a4",
    margin: (top: 2.8cm, bottom: 2.8cm, left: 3cm, right: 2.5cm),
    numbering: "1",
  )
  set text(
    size: 12pt,
    lang: "zh",
    font: meta.text_font + meta.cjk_font + meta.sans_font + meta.mono_font,
  )
  set par(first-line-indent: 2em, justify: true)
  set math.equation(numbering: "(1)")

  show heading.where(level: 1): it => [
    #v(0.6em)
    #align(center)[#text(16pt, weight: "bold")[#it.body]]
    #v(0.3em)
  ]
  show heading.where(level: 2): it => [
    #v(0.3em)
    #text(14pt, weight: "semibold")[#it.body]
    #v(0.2em)
  ]

  body
}

#let cover-page(meta) = [
  #set align(center)
  #v(1.2cm)
  #text(18pt, weight: "bold", font: meta.cover_title_font)[#meta.university_name]
  #text(15pt)[#meta.thesis_label]

  #v(2.5cm)
  #text(20pt, weight: "bold")[#meta.title]
  #v(0.6cm)
  #text(12pt)[#meta.title_en]

  #v(2.5cm)
  #table(
    columns: (auto, auto),
    align: (left, left),
    inset: 6pt,
    [作者], [#meta.author],
    [导师], [#meta.supervisor],
    [院系], [#meta.department],
    [专业], [#meta.major],
    [学位类型], [#meta.degree],
    [日期], [#meta.date],
  )
]
