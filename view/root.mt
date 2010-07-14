? extends 'base';
? block content => sub {
<ul>
?    for my $service_obj ( @$service_objs ){
        <li><a href="/service/<?= $service_obj->id ?>/"><?= $service_obj->name ?></a></li>
    </div>
?    }
</ul>
? } 
