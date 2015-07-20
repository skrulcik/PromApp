/* Model
BarData
	- label : name of specific data
	- data  : numeric value
ChartSizer
	- data  : BarData array representing chart
	- height: height of whole chart
	- width : width of whole chart
	- label_width  : width of label area, left of bars
	- data_padding : minimum extra space to right of bar (for data label)
	- max_bar_width: length of longest bar, leaving space for label on left, data label on the right
	- scale : function to scale data to bar_width
*/

function BarDataMax(a, b) {
	if(a.data < b.data) {
		return b.data;
	}
	return a.data;
}
function BarDataArrMax(arr) {
	return d3.max(arr.map(function(bd){return bd.data}));
}

/* Chart sizer encapsulates size and scaling of a chart into 1 */
function CreateChartSizer(data,width, k_label, k_data) {
	return {
		data: data,
		width: width,
		get label_width()   { return this.width * k_label},
		get data_padding()  { return this.width * k_data },
		get max_bar_width() { return this.width - this.label_width - this.data_padding},
		get scale() { return d3.scale.linear().domain([0, BarDataArrMax(this.data)]).range([0, this.max_bar_width]) }
	}
}
// Prom Chart
var p_data = [{name:"Saratoga",		data:42},
			  {name:"Ballston Spa",	data:23}, 
			  {name:"Glens Falls",	data:16},
			  {name:"Shen",			data:8}];
var p_width = d3.select("#prom_percentage").style("width").match(/\d+/)[0];
var p_sizer = CreateChartSizer(p_data, p_width, .25, .10);

// Designer Chart
var d_data = [{name:"Faviana",		data:37},
			  {name:"Morrell Maxie",data:28},
			  {name:"Jovani",		data:12}, 
			  {name:"Terani",		data:12}];
var d_width = d3.select("#designer_percentage").style("width").match(/\d+/)[0];
var d_sizer = CreateChartSizer(d_data, d_width, .25, .10);


var bar_containers = d3.select("#prom_percentage")
						.selectAll("div")
						.data(p_data)
						.enter().append("div")
						.classed("bar_container", true);
// Add labels, then bars, then data
bar_containers.append("div")
    .classed("bar_label", true)
    .style("width", p_sizer.label_width)
    .style("height", "100%")
    .text(function(d) {return d.name;});
bar_containers.append("div")
    .classed("bar", true)
    .style("width",( function(d) { return p_sizer.scale(d.data) + "px"; }))
    .style("height", "100%");
bar_containers.append("div")
 	.classed("bar_data", true)
 	.style("width", function(d) { return (p_sizer.width - p_sizer.scale(d.data) - p_sizer.label_width + p_sizer.data_padding) + "px"})
 	.style("height", "100%")
    .text(function(d) { return d.data; });


bar_containers = d3.select("#designer_percentage")
						.selectAll("div")
						.data(d_data)
						.enter().append("div")
						.classed("bar_container", true);
// Add labels, then bars, then data
bar_containers.append("div")
    .classed("bar_label", true)
    .style("width", d_sizer.label_width)
    .style("height", "100%")
    .text(function(d) {return d.name;});
bar_containers.append("div")
    .classed("bar", true)
    .style("width",( function(d) { return d_sizer.scale(d.data) + "px"; }))
    .style("height", "100%");
bar_containers.append("div")
 	.classed("bar_data", true)
 	.style("width", function(d) { return (d_sizer.width - d_sizer.scale(d.data) - d_sizer.label_width + p_sizer.data_padding) + "px"})
 	.style("height", "100%")
    .text(function(d) { return d.data; });




