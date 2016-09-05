{% set shards = mongo_shard_nodes.split(',') %}
{% for shard in shards %}
sh.addShard( "{{shard}}")
{% endfor %}

db.createUser({user:"{{ db_masterusername }}", pwd: "{{db_masterpassword }}", roles: ["userAdminAnyDatabase"] })
sh.enableSharding("admin")
