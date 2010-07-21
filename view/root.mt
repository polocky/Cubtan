? extends 'base';
? block content => sub {


<div>
<form>
    <input type="text" name="start" value="<?= $range_obj->start->ymd ?>" />
    - <input type="text" name="end" value="<?= $range_obj->end->ymd ?>" />
    <input type="submit" value="検索" />
</form>
</div>



<div id="chart-total-page" style="height:500px"></div>

<ul>
?    for my $service_obj ( @$service_objs ){
        <li style="list-style-type:none"><?=  Text::MicroTemplate::encoded_string $service_fields->get_html_color($service_obj->name) ?><a href="/service/<?= $service_obj->id ?>/"><?= $service_fields->get_label($service_obj->name) ?></a>[<?= $sample->{$service_obj->name} ?> <font size="2">サンプル</font>]</li>
?    }
</ul>

<table class="listing">
    <caption>レスポンス速度平均</caption>
    <thead>
    <tr>
        <th>日付</th>
? for my $key (@{$service_fields->get_field_keys}) {
        <th><?= Text::MicroTemplate::encoded_string $service_fields->get_html_label($key) ?></th>
? }
    </tr>
    </thead>
    <tbody>
? for (@{$avg_chart->{range}}){
    <tr>
    <td><?= $_ ?></td>
? for my $key (@{$service_fields->get_field_keys}) {
    <td align="right"><?= $avg_chart->{data}{$key}{$_} || 0 ?></td>
? }
    </tr>
? }
    </tbody>
</table>

<script>
    $.jqplot('chart-total-page',  <?= Text::MicroTemplate::encoded_string $avg_chart->get_data_part(); ?>
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
              location: 'nw'
        },
        series:<?= Text::MicroTemplate::encoded_string $avg_chart->get_series_part()  ?>
    }
    );
</script>

? } 


