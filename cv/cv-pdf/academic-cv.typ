// academic-cv.typ
// Compile from the cv-pdf folder:
//   quarto typst compile academic-cv.typ --font-path fonts

// ---------- Style ----------
#let ink = rgb("#4e1d4c")
#let body-ink = rgb("#1f1a20")

#set document(
  title: "Mohamed Hsin Bennour – Academic CV",
  author: "Mohamed Hsin Bennour",
  keywords: ("regional development", "technological diversification",
             "economic geography", "machine learning", "network analysis",
             "spatial econometrics", "R"),
)

#set page(
  paper: "a4",
  margin: (x: 2cm, y: 1.8cm),
  footer: context [
    #set text(size: 8pt, fill: ink)
    Mohamed Hsin Bennour · Academic CV · Updated November 2026
    #h(1fr)
    #counter(page).display("1 / 1", both: true)
  ],
)

#set text(
  font: ("Literata 12pt", "Literata"),
  size: 10pt,
  fill: body-ink,
  lang: "en",
  ligatures: false,
  hyphenate: false,
)
#set par(justify: false, leading: 0.62em)
#set list(indent: 0.4em, body-indent: 0.6em, marker: [–])
#show link: set text(fill: ink)

#show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, width: 100%)[
  #text(size: 11.5pt, weight: "bold", fill: ink, it.body)
  #v(-0.6em)
  #line(length: 100%, stroke: 0.5pt + ink)
]

// One entry: title and date on the first line, details below
#let entry(title, when, where: none, note: none, extra: none) = block(
  breakable: false, width: 100%, below: 1.05em,
)[
  #text(weight: "semibold", title) #h(1fr) #text(fill: ink, when)
  #if where != none [ \ #emph(where) ]
  #if note != none [ \ #note ]
  #if extra != none [ \ #text(size: 0.88em, extra) ]
]

// One workflow stage
// One methods area: name, description, then tools
#let skill(name, body, tools) = block(below: 0.85em)[
  #text(weight: "semibold", name) \
  #body \
  #text(size: 0.88em, tools)
]

// ---------- Header ----------
#block(below: 1.5em)[
  #text(size: 22pt, weight: "bold", fill: ink)[Mohamed Hsin Bennour] \
  #text(size: 11pt)[PhD Candidate in Regional Development · University of Pécs, Hungary] \
  #text(size: 9.5pt)[
    #link("mailto:hsin.bennour@gmail.com")[hsin.bennour\@gmail.com] ·
    #link("https://www.bennour.tn")[bennour.tn] ·
    #link("https://github.com/bennour007")[github.com/bennour007] ·
    #link("https://www.linkedin.com/in/bennour-medhsin")[linkedin.com/in/bennour-medhsin]
  ]
]

// ---------- Content ----------
= Summary

PhD candidate in Regional Development at the University of Pécs - Faculty of Business and Economics. I study how European regions diversify into new technologies, combining machine learning, network analysis and spatial econometrics to predict which technologies a region can realistically enter, and why. Published in _Journal of Physics: Complexity_ (2026) and _Society and Economy_ (2025).

= Education

#entry([PhD Candidate, Regional Development], [2022 – present],
  where: [Doctoral School of Regional Policy and Economics, Faculty of Business and Economics, University of Pécs])

#block(inset: (left: 0.8em), below: 1.2em)[
  // TODO: confirm the thesis title
  *Dissertation:* _Contextualising Regional Technological Diversification in European Regions: Network Structure, Industrial Alignment, Entrepreneurial Ecosystems, and Spatial Interdependence._

  Reframes technological relatedness as a prediction problem: machine learning models trained on European patent data estimate each region's technological potential for every technology and yield a directed technology network. Using these, the thesis distinguishes bridging and enabling technologies and tests how network position, industrial alignment, national entrepreneurial ecosystems and spatial dependence shape which diversification options are feasible.
  ETA for final defense: Feb 2027
]

#entry([MSc in Business Analytics], [Dec 2020],
  where: [Tunis Business School],
  note: [Efficiency analysis and modelling, computational statistics.])

#entry([BSc in Econometrics], [Jul 2018],
  where: [ISG Sousse],
  note: [Probability and statistics, econometrics and operations research.])

= Publications

#entry([Regional potential and friction for technological diversification: a machine learning frontier approach], [Jan 2026],
  where: [Journal of Physics: Complexity, 7(1), 015005. Open access.],
  extra: [#link("https://doi.org/10.1088/2632-072X/ae35bc")[doi.org/10.1088/2632-072X/ae35bc]])

#entry([Efficiency of Eastern European schools and the role of their context], [2025],
  where: [Society and Economy, 47(3), 318–337.],
  extra: [#link("https://doi.org/10.1556/204.2025.00005")[doi.org/10.1556/204.2025.00005]])

= Conference presentations

#entry([How European regions optimise their complexity through technological diversification], [Sep 2026],
  where: [EconNet Workshop, Faculty of Business and Economics, University of Pécs])

#entry([Foreign Direct Investment and the Limits of Regional Upgrading: Evidence from GVC Roles in Central and Eastern Europe], [Aug 2026],
  where: [ERSA 2026 Congress, Sofia, Bulgaria],
  note: [With Zoltán Gál.])

#entry([Contextualising Regional Technological Diversification in European Regions: Network Structure, Industrial Alignment, Entrepreneurial Ecosystems, and Spatial Interdependence], [May 2026],
  where: [MKE Doctoral Workshop, Faculty of Business and Economics, University of Pécs])

#entry([Regional potential and friction for technological diversification], [Jan 2026],
  where: [8th Geography of Innovation Conference, Corvinus University of Budapest, Hungary])

#entry([Predicting regional patents diversification and their triggers: an explainable machine learning approach], [Aug 2025],
  where: [64th ERSA Congress, Athens, Greece])

#entry([Structural Challenges and GVC Positions in FDI Dependent Economies: Insights from the V4 Regions], [Jun 2025],
  where: [XVII Finance Days in Pécs, Finance and Accounting International Scientific Conference, Pécs, Hungary],
  note: [With Zoltán Gál.])

#entry([Adoption of digital web technology, inequality and the role of space], [May 2024],
  where: [RKK40 Anniversary Conference, HUN-REN Institute for Regional Studies, Pécs, Hungary],
  note: [With Stefan Apostol and András Gyimesi.])

#entry([How Hungarian Universities and Research Institutions Can Expand Their Scientific Expertise?], [Apr 2024],
  where: [MKE Doctoral Workshop, Faculty of Business and Economics, University of Pécs])

#entry([Visegrad Countries and Education Challenges: An Efficiency Analysis], [Mar 2024],
  where: [Globalisation, Integration, Cooperation Conference, University of Szeged, Hungary])

= Funding

#entry([Stipendium Hungaricum Scholarship], [2022 – present],
  where: [Tempus Public Foundation, Hungary],
  note: [Scholarship for doctoral studies at the University of Pécs.])

= Teaching

#entry([Seminar Instructor, Quantitative Methods (BA)], [Sep 2026 – present],
  where: [Faculty of Business and Economics, University of Pécs],
  note: [Teaching the seminars of the introductory course in algebra and calculus.])

#entry([Teaching Assistant], [Jan – Jul 2020],
  where: [Tunis Business School],
  note: [Tutored the introductory course in descriptive statistics and probability.])

= Applied and policy experience

#entry([Data Analyst Consultant, Severity Assessment], [Oct 2024 – Jun 2025],
  where: [Internal Displacement Monitoring Centre (IDMC), Geneva, Switzerland],
  note: [Built a config-driven targets pipeline for REACH and IOM needs-assessment data from 15 countries: survey-weighted estimates, group tests and disaggregations, with small cells suppressed automatically, merged into a 2022–2024 severity dataset.],
  extra: [R · targets · srvyr])

#entry([Consultant], [Aug – Dec 2023],
  where: [The Graph Network, Geneva, Switzerland],
  note: [Designed and recorded data science courses.],
  extra: [R])

#entry([Consultant], [Sep 2022 – Jan 2023],
  where: [Geomatys, Montpellier, France],
  note: [Refactored and redesigned R code bases, optimising running time and memory use.],
  extra: [R · data.table])

#entry([Data Officer], [Apr – Sep 2022],
  where: [REACH Initiative, Tunis, Tunisia],
  note: [Designed data pipelines and monitoring dashboards for several teams, and coordinated inputs on data collection.],
  extra: [R · Python · PostgreSQL · Azure])

#entry([Database Specialist], [Jan 2021 – Jan 2022],
  where: [National Pen, Tunis, Tunisia],
  note: [Automated key processes, and cleaned and managed company data.],
  extra: [SQL Server · MS Access])

#entry([Data Analyst], [Mar – Aug 2020],
  where: [EMRHOD Consulting, Tunis, Tunisia],
  note: [Developed client proposals, and designed and ran quantitative and qualitative studies, including focus groups.],
  extra: [SPSS · R · Python · Power BI])

#entry([Operations Intern], [Jun – Aug 2019],
  where: [N3XT Tunisie, Tunis, Tunisia],
  note: [Implemented SAP S/4HANA operations modules to match clients' business needs.])

= Methods and Software

#skill([Statistical modelling and machine learning],
  [Random forest classification with rolling train–test designs; fixed-effects and multilevel panel models; spatial econometrics (spatial lag and spatial error panel models); network analysis.],
  [tidymodels · ranger · fixest · lme4 · pspatreg · spdep · igraph])

#skill([Survey analysis],
  [Design-based estimation under complex sampling (stratification, clustering, weights), group comparisons and multi-level disaggregation of needs-assessment data.],
  [survey · srvyr])

#skill([Data processing],
  [Processing and linkage of large patent, administrative and survey datasets, including European patent records (REGPAT) for 30 countries at NUTS 2 level.],
  [data.table · tidyverse · arrow · sf])

#skill([Reproducible research workflows],
  [Modular, documented analysis pipelines with dependency tracking and parallel execution: six linked pipelines for the doctoral research and a multi-country survey-analysis pipeline for IDMC.],
  [targets · tarchetypes · crew · purrr · Git])

#skill([Visualisation and reporting],
  [Publication-quality figures, maps and regression tables produced within the analysis pipeline.],
  [ggplot2 · ggraph · gt · modelsummary · Quarto])

#skill([Programming languages],
  [R (primary), Python, SQL (PostgreSQL, SQL Server), LaTeX, Typst.],
  [])
= Community

#entry([Team Lead, Analysis], [2019 – 2020],
  where: [Data-colab])

#entry([Co-founder and Board Member], [2018 – 2020],
  where: [TBS Data Science Club, Tunis Business School])
