{% macro snapshot_timestamp_with_deletes_strategy(node, snapshotted_rel, current_rel, config, target_exists) %}
    {% set primary_key = config['unique_key'] %}
    {% set updated_at = config['updated_at'] %}
    -- here is what we changed
    {% set row_changed_expr -%}
        ({{ snapshotted_rel }}.{{ updated_at }} < {{ current_rel }}.{{ updated_at }}
            or {{ snapshotted_rel }}.{{primary_key}} not in (select {{ primary_key}} from {{ current_rel }})
        )
    {%- endset %}

    {% set scd_id_expr = snapshot_hash_arguments([primary_key, updated_at]) %}

    {% do return({
        "unique_key": primary_key,
        "updated_at": updated_at,
        "row_changed": row_changed_expr,
        "scd_id": scd_id_expr
    }) %}
{% endmacro %}
