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

<br /><br />

<font size="+1">レスポンス速度平均グラフ[<?= $range_obj->start->ymd('/') ?> - <?= $range_obj->end->ymd('/') ?>]</font>
<div id="avg_chart"></div>
? my $graphs;
? my $i = 0;
? for my $tag_obj ( @$tag_objs ) {
?     $graphs .= sprintf '<graph gid="%s"><title>%s</title></graph>', $i++, $tag_fields->get_label( $tag_obj->name );
? }
? my $settings = sprintf '<settings><data_type>csv</data_type><csv_separator>,</csv_separator><graphs>%s</graphs></settings>', $graphs;
? my $data = join '\n', @$lines;
<script language="javascript" type="text/javascript">
var so = new SWFObject("/static/amline/amline.swf", "amline", "640", "400", "8", "#FFFFFF");
so.addVariable("path", "/static/amline/");
so.addVariable("chart_settings", "<?= $settings ?>");
so.addVariable("chart_data", "<?= $data ?>");
so.write("avg_chart");
</script>

? for my $tag_obj ( @$tag_objs ){
?     my $graphs;
?     my $i = 0;
?     for my $range ( @{ $tag_range_of->{ $tag_obj->name }->{ ranges } } ) {
?         $graphs .= sprintf '<graph gid="%s"><title>%s</title></graph>', $i++, $range;
?     }
?     my $settings = sprintf '<settings><data_type>csv</data_type><csv_separator>,</csv_separator><graphs>%s</graphs></settings>', $graphs;
?     my $data = join '\n', @{ $tag_range_of->{ $tag_obj->name }->{ lines } };
<br /><br />
<font size="+1"><?= $tag_fields->get_label($tag_obj->name) ?>[サンプル数: <?= $sample->{$tag_obj->name} ?>]</font>
<div id="avg_tag_chart_<?= $tag_obj->name ?>"></div>
<script language="javascript" type="text/javascript">
var so = new SWFObject("/static/amline/amline.swf", "amline", "640", "400", "8", "#FFFFFF");
so.addVariable("path", "/static/amline/");
so.addVariable("chart_settings", "<?= $settings ?>");
so.addVariable("chart_data", "<?= $data ?>");
so.write("avg_tag_chart_<?= $tag_obj->name ?>");
</script>
? }

? }
