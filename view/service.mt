? extends 'base';
? block content => sub {
<h2>Service : <?= $service_obj->name ?></h2>
<div>
? for my $tag_obj ( @{$service_obj->get_tag_objs} ){
    <h3><?= $tag_obj->name ?></h3>
? }
<div>
    <div class="jqPlot" id="chart1" style="height:320px; width:480px;"></div>
    <script>
line1 = [1,4, 9, 16];
plot2 = $.jqplot('chart1', [line1], {
    legend:{show:true, location:'ne', xoffset:55},
    title:'Bar Chart With Options',
    seriesDefaults:{
        renderer:$.jqplot.BarRenderer, 
        rendererOptions:{barPadding: 8, barMargin: 20}
    },
    series:[
        {label:'Profits'}, 
        {label:'Expenses'}, 
        {label:'Sales'}
    ],
    axes:{
        xaxis:{
            renderer:$.jqplot.CategoryAxisRenderer, 
            ticks:['1st Qtr', '2nd Qtr', '3rd Qtr', '4th Qtr']
        }, 
        yaxis:{min:0}
    }
});
</script>
? } 
