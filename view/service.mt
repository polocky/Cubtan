? extends 'base';
? block content => sub {
<h2>Service : <?= $service_obj->name ?></h2>
<div>
? for my $tag_obj ( @{$service_obj->get_tag_objs} ){
    <h3><?= $tag_obj->name ?></h3>
? }
<div>
? } 
