---
theme: dashboard
toc: false
sql:
  tenders: ./lib/data-years-communes-regions-municpalities.parquet
---

```js
const communes = await sql`select distinct commune, region, sum(n) as total from tenders group by commune, region order by total desc`;
const region = await sql`select distinct region, sum(n) as total from tenders group by region order by total desc`
```

```js
const chl = await FileAttachment("./lib/CHL-3.json").json().then(data => ({
  type: "FeatureCollection",
  features: data.features.filter(d => d.properties.NAME_2 != "IsladePascua").filter(d => d.properties.NAME_1.toLowerCase() === dropdownViewRegion)
}));
const filteredCommunes = communes.toArray().filter(
  c => c.region?.toLowerCase() === dropdownViewRegion.toLowerCase()
);
```

# Tenders by Commune and Year

```js
function communeMapPlot(data, {height, selectedCommune} = {}) {
  return Plot.plot({
    projection: {
      type: "mercator",
      domain:  data,
      inset: 20
    },
    height: height,
    width: height * 0.4,
    marks: [
      Plot.geo(data, {
        fill: d => d.properties.NAME_3.toLowerCase() === selectedCommune ? "steelblue" : "lightgrey",
        stroke: "white",
        strokeWidth: 0.5,
        tip: true,
        channels: {
          Region: d => d.properties.NAME_1,
          Commune: d => d.properties.NAME_3,
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
const regionDropdown = Inputs.select(region, {
  label: "Select Region",
  value: "Santiago",
  format: d => d.region,
  valueof: d => d.region
});

const dropdownViewRegion = view(regionDropdown);

// setCommune(dropdownView);
```

```js
const communeDropdown = Inputs.select(filteredCommunes, {
  label: "Select Commune",
  value: "Santiago",
  format: d => d.commune,
  valueof: d => d.commune,
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
  return Plot.lineY(data, {x: "year_creation", y: "n"}).plot({
    y: {grid: true},
    title: "Number of yearly tenders in " + dropdownView
  });
}
```

```sql id=tenders
select commune, year_creation, cast(sum(n) as int) as n from tenders
where commune = ${dropdownView} and year_creation > 2006
group by year_creation, commune
order by year_creation, commune;
```

```js
const dataTable = display(Inputs.table(tenders));
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
      ${regionDropdown}
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
${dataTable}

