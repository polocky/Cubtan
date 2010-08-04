? extends 'base';
? block content => sub {

<div>
<form>
    <input type="text" name="start" value="<?= $range_obj->start->ymd ?>" />
    - <input type="text" name="end" value="<?= $range_obj->end->ymd ?>" />
    <input type="submit" value="検索" />
</form>
</div>

<br /><br />

<div id="avg"></div>
? my $graphs;
? my $i = 0;
? for my $service_obj ( @$service_objs ) {
?     $graphs .= sprintf( '<graph gid="%s"><title>%s</title></graph>', $i++, $service_obj->name );
? }
? my $settings = sprintf '<settings><data_type>csv</data_type><csv_separator>,</csv_separator><graphs>%s</graphs></settings>', $graphs;
? my $data = join '\n', @$lines;
<script language="javascript" type="text/javascript">
var so = new SWFObject("/static/amline/amline.swf", "amline", "640", "400", "8", "#FFFFFF");
so.addVariable("path", "/static/amline/");
so.addVariable("chart_settings", "<?= $settings ?>")
so.addVariable("chart_data", "<?= $data ?>");
so.write("avg");
</script>

<ul>
?    for my $service_obj ( @$service_objs ){
        <li style="list-style-type:none"><a href="/service/<?= $service_obj->id ?>/"><?= $service_fields->get_label($service_obj->name) ?></a>[サンプル数: <?= $sample->{$service_obj->name} ?>]<a href="/service/<?= $service_obj->id ?>/hourly/">hourly</a></li>
?    }
</ul>

<table class="listing">
    <caption>レスポンス速度平均</caption>
    <thead>
    <tr>
        <th>日付</th>
? for my $service_obj ( @$service_objs ) {
        <th><?= Text::MicroTemplate::encoded_string $service_fields->get_html_label($service_obj->name) ?></th>
? }
    </tr>
    </thead>
    <tbody>
? for my $date ( @{ $range_obj->range_array } ) {
    <tr>
          <td><?= $date ?></td>
?     for my $service_obj ( @$service_objs ) {
          <td align="right"><?= $summary->{$service_obj->name}->{$date} || 0 ?></td>
?     }
    </tr>
? }
    </tbody>
</table>

? }

