// explorer.js: two linked panels per parameter. Left: final share of cooperators
// against the parameter. Right: share of cooperators over rounds for the selected value.
(() => {
  const NETWORKS = ["Close-knit", "Small world", "Random", "Hubs"];
  const DASHES = { "Close-knit": null, "Small world": "6 4", "Random": "2 3", "Hubs": "10 3 2 3" };
  const W = 460, H = 300, M = { top: 16, right: 16, bottom: 44, left: 44 };
  const pct = d3.format(".0%");
  const num = d3.format("~g");

  // One panel: a title and an svg that scales with its container
  function panel(container, title) {
    const wrap = container.append("div").attr("class", "cx-panel");
    wrap.append("p").attr("class", "cx-title").text(title);
    return wrap.append("svg").attr("viewBox", `0 0 ${W} ${H}`);
  }

  // Axes: share of cooperators on y (with faint gridlines), the given scale on x
  function axes(svg, x, y, label) {
    svg.append("g").attr("class", "cx-axis")
      .attr("transform", `translate(0,${H - M.bottom})`)
      .call(d3.axisBottom(x).ticks(6, "~g"));
    svg.append("g").attr("class", "cx-axis")
      .attr("transform", `translate(${M.left},0)`)
      .call(d3.axisLeft(y).ticks(5).tickFormat(pct).tickSize(-(W - M.left - M.right)))
      .call(g => g.select(".domain").remove());
    svg.append("text").attr("class", "cx-axis-label")
      .attr("x", (M.left + W - M.right) / 2).attr("y", H - 8)
      .attr("text-anchor", "middle").text(label);
  }

  async function explorer(el) {
    const { param, label, log, sensitivity, evolution } = el.dataset;
    const [sens, evo] = await Promise.all([
      d3.csv(sensitivity, d3.autoType),
      d3.csv(evolution, d3.autoType)
    ]);

    const values = [...new Set(sens.map(d => d.value))].sort((a, b) => a - b);
    const closest = v => values.reduce((a, b) => Math.abs(b - v) < Math.abs(a - v) ? b : a);
    let selected = closest(+el.dataset.default);

    const sensBy = d3.group(sens, d => d.network);
    sensBy.forEach(rows => rows.sort((a, b) => a.value - b.value));
    const evoBy = d3.group(evo, d => d.network, d => d.value);

    // Layout: legend, two panels, slider
    const root = d3.select(el);
    const legend = root.append("div").attr("class", "cx-legend");
    const panels = root.append("div").attr("class", "cx-panels");
    const left = panel(panels, `Final share of cooperators, by ${param}`);
    const right = panel(panels, "Share of cooperators, round by round");
    const control = root.append("div").attr("class", "cx-control");

    // Scales
    const x1 = (log === "true" ? d3.scaleLog() : d3.scaleLinear())
      .domain(d3.extent(values)).range([M.left, W - M.right]);
    const x2 = d3.scaleLinear()
      .domain([0, d3.max(evo, d => d.round)]).range([M.left, W - M.right]);
    const y = d3.scaleLinear().domain([0, 1]).range([H - M.bottom, M.top]);
    axes(left, x1, y, label);
    axes(right, x2, y, "Round");

    // Left panel: spread band (shown on hover), lines, selection marker, dots
    const band = d3.area().x(d => x1(d.value)).y0(d => y(d.low)).y1(d => y(d.high));
    const line1 = d3.line().x(d => x1(d.value)).y(d => y(d.mean));
    const bands = left.append("g").selectAll("path").data(NETWORKS).join("path")
      .attr("class", "cx-band").attr("d", n => band(sensBy.get(n)));
    const lines1 = left.append("g").selectAll("path").data(NETWORKS).join("path")
      .attr("class", "cx-line").attr("stroke-dasharray", n => DASHES[n])
      .attr("d", n => line1(sensBy.get(n)));
    const marker = left.append("line").attr("class", "cx-marker")
      .attr("y1", M.top).attr("y2", H - M.bottom);
    const dots = left.append("g").selectAll("circle").data(NETWORKS).join("circle")
      .attr("class", "cx-dot").attr("r", 4);

    // Right panel: one line per network, redrawn for the selected value
    const line2 = d3.line().x(d => x2(d.round)).y(d => y(d.cooperation));
    const lines2 = right.append("g").selectAll("path").data(NETWORKS).join("path")
      .attr("class", "cx-line").attr("stroke-dasharray", n => DASHES[n]);

    // Legend: a line sample and a name for each network
    const items = legend.selectAll("span").data(NETWORKS).join("span")
      .attr("class", "cx-legend-item");
    items.append("svg").attr("width", 34).attr("height", 10)
      .append("line").attr("class", "cx-line")
      .attr("x1", 0).attr("x2", 34).attr("y1", 5).attr("y2", 5)
      .attr("stroke-dasharray", n => DASHES[n]);
    items.append("span").text(n => n);

    // Slider over the computed values
    control.append("label").text(label);
    const slider = control.append("input")
      .attr("type", "range").attr("min", 0).attr("max", values.length - 1).attr("step", 1)
      .on("input", function () { selected = values[+this.value]; update(false); });
    const valueText = control.append("span").attr("class", "cx-value");

    // Highlight one network in both panels
    function setFocus(n) {
      root.selectAll(".cx-line, .cx-dot, .cx-legend-item")
        .classed("cx-dim", d => n !== null && d !== n);
      bands.classed("cx-show", d => d === n);
    }
    [items, lines1, lines2].forEach(sel => sel
      .on("mouseenter", (event, n) => setFocus(n))
      .on("mouseleave", () => setFocus(null)));

    // Clicking the left panel selects the nearest value
    left.on("click", event => {
      const [mx] = d3.pointer(event);
      selected = values.reduce((a, b) => Math.abs(x1(b) - mx) < Math.abs(x1(a) - mx) ? b : a);
      update(true);
    });

    // Redraw everything that depends on the selected value
    function update(animate) {
      const t = d3.transition().duration(animate ? 400 : 0);
      marker.transition(t).attr("x1", x1(selected)).attr("x2", x1(selected));
      dots.transition(t)
        .attr("cx", x1(selected))
        .attr("cy", n => y(sensBy.get(n).find(d => d.value === selected).mean));
      lines2.transition(t).attr("d", n => line2(evoBy.get(n).get(selected)));
      slider.property("value", values.indexOf(selected));
      valueText.text(`${param} = ${num(selected)}`);
    }

    update(false);
  }

  document.querySelectorAll(".coop-explorer").forEach(explorer);
})();
