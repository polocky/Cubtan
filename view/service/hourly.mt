? extends 'base';
? block content => sub {
<h2>Service : <?= $service_obj->name ?> Hourly</h2>

<div>
<form>
    <input type="text" name="start" value="<?= $range_obj->start->ymd ?>" />
    - <input type="text" name="end" value="<?= $range_obj->end->ymd ?>" />
    <input type="submit" value="検索" />
</form>
</div>
<div id="avg-chart" style="height:500px"></div>
<script>
    $.jqplot('avg-chart',  <?= Text::MicroTemplate::encoded_string $avg_chart->get_data_part(); ?>
    ,{
        title:'レスポンス速度平均Hourlyグラフ[<?= $range_obj->start->ymd('/') ?> - <?= $range_obj->end->ymd('/') ?>]',
        axes:{
            xaxis:{
                tickOptions:{formatString:'%d'},
                min: 0,
                max: 23,
            },
            yaxis:{
                autoscale:true,
                tickOptions:{formatString:'%.02f'}
            },
        },
        legend:{  
              show:true,  
              location: 'nw',  
              },
        series:<?= Text::MicroTemplate::encoded_string $avg_chart->get_series_part()  ?>
    }
    );
</script>

? } 
