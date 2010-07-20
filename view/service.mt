? extends 'base';
? block content => sub {
<h2>Service : <?= $service_obj->name ?></h2>

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
        title:'レスポンス速度平均グラフ[<?= $range_obj->start->ymd('/') ?> - <?= $range_obj->end->ymd('/') ?>]',
        axes:{
            xaxis:{
                renderer:$.jqplot.DateAxisRenderer,
                tickInterval:'1 day' ,
                tickOptions:{formatString:'%d'},
                min:'<?= $range_obj->start->ymd ?>',
                max:'<?= $range_obj->end->ymd ?>'
            },
            yaxis:{
                autoscale:true,
                tickOptions:{formatString:'%.02f'}
            },
            y2axis:{
                autoscale:true,
                tickOptions:{formatString:'%d'}
            }
        },
        legend:{  
              show:true,  
              location: 'nw',  
              },
        series:<?= Text::MicroTemplate::encoded_string $avg_chart->get_series_part()  ?>
    }
    );
</script>


<div>
? for my $tag_obj ( @{$service_obj->get_tag_objs} ){
? # last; # too much memory...
? my $chart_obj = $tag_obj->get_tag_range_log_chart_obj($range_obj);
    <h3><?=  Text::MicroTemplate::encoded_string $tag_fields->get_html_color($tag_obj->name) ?><?= $tag_fields->get_label($tag_obj->name) ?></h3>
    <div id="avg-tag-chart-<?= $tag_obj->name ?>"></div>
    <script>
    $.jqplot('avg-tag-chart-<?= $tag_obj->name ?>',<?=  Text::MicroTemplate::encoded_string $chart_obj->get_data_part() ; ?>
    ,{
        legend: {show: true, location: 'nw'},
        title: 'レスポンスレンジ率',
        series:<?= Text::MicroTemplate::encoded_string $chart_obj->get_series_part()  ?>,
        axes:{
            xaxis:{
                renderer:$.jqplot.DateAxisRenderer,
                tickInterval:'1 day' ,
                tickOptions:{formatString:'%d'},
                min:'<?= $range_obj->start->ymd ?>',
                max:'<?= $range_obj->end->ymd ?>'
            },
            yaxis:{
                numberTicks:12 ,
                tickOptions:{formatString:'%d%'},
                max:100,
                min:0 
            },
            y2axis:{
                autoscale:true,
                tickOptions:{formatString:'%d'}
            }
        }
    }
    ); 
    </script>
? }
</div>



? } 
