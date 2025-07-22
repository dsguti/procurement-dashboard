---
theme: dashboard
toc: false
sql:
  tenders: ./lib/count-commune-year.parquet
---

```js
const communes = await sql`select distinct commune, sum(n) as total from tenders group by commune order by total desc`;
```

```js
const chl = await FileAttachment("./lib/CHL-2.json").json().then(data => ({
  type: "FeatureCollection",
  features: data.features.filter(d => d.properties.NAME_2 != "IsladePascua")
}));
```

# Tenders by Commune and Year

```js
function communeMapPlot(data, {height, selectedCommune} = {}) {
  return Plot.plot({
    projection: {
      type: "mercator",
      domain: data,
      inset: 20
    },
    height: height,
    width: height * 0.4,
    marks: [
      Plot.geo(data, {
        fill: d => d.properties.NAME_2 === selectedCommune ? "steelblue" : "lightgrey",
        stroke: "white",
        strokeWidth: 0.5,
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

<!-- ```js -->
<!-- const commune = Mutable("Arauco"); -->
<!-- const setCommune = (value) => commune.value = value; -->
<!-- ``` -->

```js
const communeDropdown = Inputs.select(communes, {
  label: "Select Commune",
  value: "Santiago",
  format: d => d.commune,
  valueof: d => d.commune
});

const dropdownView = view(communeDropdown);

// setCommune(dropdownView);
```

```js
const mapPlot = communeMapPlot(chl, {
  height: 900,
  selectedCommune: dropdownView
});

// const mapView = view(mapPlot);
```

```js
function communeLinePlot(data, {width, communeName} = {}) {
  return Plot.lineY(data, {x: "t", y: "n"}).plot({
    y: {grid: true},
    title: "Number of yearly tenders in " + dropdownView
  });
}
```

```sql id=tenders
select * from tenders
where commune = ${dropdownView} and t > 2006
order by commune, t;
```

<style>
.map-container .card {
  background: transparent;
  border: none;
  box-shadow: none;
}
</style>

<div class="grid grid-cols-4 grid-rows-4">
  <div class="map-container grid-colspan-1 grid-rowspan-4">
    <div class="card">
      ${communeDropdown}
      ${mapPlot}
    </div>
  </div>

  <div class="card grid-colspan-2 grid-rowspan-2">
    ${resize((width) => communeLinePlot(tenders, {width}))}
  </div>
  <div class="card grid-colspan-1 grid-rowspan-2">
  </div>

  <div class="card grid-colspan-2 grid-rowspan-2">
    ${resize((width) => communeLinePlot(tenders, {width}))}
  </div>
  <div class="card grid-colspan-1 grid-rowspan-2">
  </div>

</div>


