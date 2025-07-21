---
theme: dashboard
toc: false
sql:
  tenders: ./lib/count-commune-year.parquet
---

# Tenders by Commune and Year

```js
const communes = await sql`select distinct commune, sum(n) as total from tenders group by commune order by total desc`;
// const munic = view(Inputs.select(communes, {label: "Commune"}))
```

```js
function communeLinePlot(data, {width} = {}) {
  return Plot.lineY(tenders, {x: "t", y: "n"}).plot({
    y: {grid: true},
    title: " Number of yearly tenders in " + commune
  });
}
```

```js
const chl = FileAttachment("./lib/CHL-2.json").json();
// display(await chl);
```

```js
function communeMapPlot(data, {height, width} = {}) {
  return Plot.plot({
    // projection: "mercator",
    height: height,
    width: width,
    x: {domain: [-76, -66]},
    marks: [
      Plot.geo(data, {
        tip: true,
        channels: {
          Region: d => d.properties.NAME_1,
          Commune: d => d.properties.NAME_2,
        }
      }),
    ]
  });
}
```

```js
const commune = Mutable("Arauco");
const mapPlot = communeMapPlot(chl, {height: 900, width: 400})

mapPlot.addEventListener("click", (event) => {
  commune.value = mapPlot.value.properties.NAME_2;
});
```

```sql id=tenders
select * from tenders
where commune = ${commune} and t > 2006
order by commune, t;
```


<div class="grid grid-cols-4 grid-rows-4">
  <div class="card grid-colspan-1 grid-rowspan-4">
    ${mapPlot}
  </div>
  <div class="card grid-colspan-3 grid-rowspan-2">
    ${resize((width) => communeLinePlot(tenders, {width}))}
  </div>
  <div class="card grid-colspan-3 grid-rowspan-2">
    ${resize((width) => communeLinePlot(tenders, {width}))}
  </div>
</div>

<!-- <div class="grid grid-cols-4"> -->
<!--   <div class="card grid-colspan-1">${mapPlot}</div> -->
<!--   <div class="card grid-colspan-3 grid-rowspan-2">${resize((width) => communeLinePlot(tenders, {width}))}</div> -->
<!--   <div class="card grid-colspan-3 grid-rowspan-2">${resize((width) => communeLinePlot(tenders, {width}))}</div> -->
<!-- </div> -->

