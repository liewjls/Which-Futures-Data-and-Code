var dataDiveMap = (function ($) {
    return {};
}(jQuery));

dataDiveMap.Renderer = (function ($, d3, topojson) {
    var colNameLocalAuth = "ONS.LA.Code",
        colNameGeoLocalAuth = "CTYUA14CD",
        renderer = function (svg, svgGrouping, topojsonData, localAuthGeoInfo, modelData) {
            var projection;
            this.svg = svg;
            this.svgGrouping = svgGrouping;
            this.topojsonData = topojsonData;
            this._indexedData = null;
            this.localAuthGeoInfo = localAuthGeoInfo;
            this.modelData = modelData;
            this.colorScale = d3.scale.linear()
                .domain([0, 50])
                // .domain([0, 800])
                .range(["red", "green"]);

            projection = d3.geo.mercator()
                .center([0, 5 ])
                .scale(5000)
                .rotate([3,-48]);
            this.projection = projection;

            this.path = d3.geo.path()
                .projection(projection);

            // Index the data by year and local authority code to
            // make look ups quicker
            this._indexedData = _indexData(this.modelData);
            console.log("this._indexedData", this._indexedData);
        },
        _indexData = function (modelData) {
            var indexedData = {};
            var yearData;

            modelData.forEach(function (row) {
                var year = row.Year,
                localAuthCode = row[colNameLocalAuth];
                // index by year and la code
                if (typeof indexedData[year] === "undefined") {
                    indexedData[year] = {};
                }
                yearData = indexedData[year];
                yearData[localAuthCode] = row;
            });

            return indexedData;
        },
        _drawCountryOutline = function (svgGrouping, path, topology) {
            // The country outlines
            svgGrouping.selectAll("path")
                    .data(topojson.object(topology, topology.objects.countries)
                        .geometries)
                .enter()
                    .append("path")
                    .attr("d", path);
        },
        _extractDataValue = function(indexedData, displayYear, localAuthCode) {
            console.log("extracting data", displayYear, localAuthCode)
            var row = indexedData[displayYear][localAuthCode];
            var val;
            if (row) {
                val = +(row[data_column]);
            } else {
                val = 0;
            }
            // console.log("val", val, laCode, indexed_data[displayYear])
            return val;
        },
        _drawDataPoints = function  (svg, projection, colorScale, lat_long, indexed_data, displayYear) {
            console.log("drawing points", displayYear)
            // Clear old points
            svg.selectAll("circle").remove();
            svg.selectAll("text").remove();

            // Good circles
            svg.selectAll("circle")
                .data(lat_long).enter()
                .append("circle")
                .attr("data-id", function (d) { return d.X; })
                .attr("cx", function (d) { return projection([d.X, d.Y])[0]; })
                // .attr("cx", function (d) { console.log(projection([d.X, d.Y])); return projection([d.X, d.Y])[0]; })
                .attr("cy", function (d) { return projection([d.X, d.Y])[1]; })
                .attr("r", "4px")
                .attr("fill", function (d) {
                    var laCode = d[colNameGeoLocalAuth],
                    val = _extractDataValue(indexed_data, displayYear, laCode);
                    return dataDiveMap.colours.hexStrToRGBStr(colorScale(val));
                })
                .attr("onmouseover", "hoverOver(evt)")
                .attr("onmouseout", "hoverOut(evt)");

            // Text
            svg.selectAll("text")
                    .data(lat_long)
                .enter()
                    .append("svg:text")
                    .attr("data-id", function (d) { return d.X; })
                    .text(function(d){
                        var laCode = d[colNameGeoLocalAuth],
                        val = _extractDataValue(indexed_data, displayYear, laCode);
                        return d.CTYUA14NM + ":" + val;
                    })
                    .attr("x", function(d){
                        return projection([d.X, d.Y])[0];
                    })
                    .attr("y", function(d){
                        return projection([d.X, d.Y])[1];
                    })
                    .attr("text-anchor","middle")
                    .attr('font-size','18pt')
                    .attr('font-family', "Verdana")
                    .attr("fill", "rgb(70, 70, 70)")
                    .attr('visibility', 'hidden');
            };

    renderer.prototype.colorScale = function () {
        return this.colorScale;
    };

    renderer.prototype.render = function (year) {
        
        // console.log("year", year);

        _drawCountryOutline(this.svgGrouping, this.path, this.topojsonData);
        _drawDataPoints(this.svg, this.projection, this.colorScale, this.localAuthGeoInfo, this._indexedData, year);
    };

    return renderer;
}(jQuery, d3, topojson));


dataDiveMap.colours = (function (d3) {
    var hexStrToRGBStr = function (hexValue) {
            var rgbVal = d3.rgb(hexValue);
            return "rgb(" + rgbVal.r + "," + rgbVal.g + "," + rgbVal.b + ")";
        };

    return {
        hexStrToRGBStr: hexStrToRGBStr
    };
}(d3));