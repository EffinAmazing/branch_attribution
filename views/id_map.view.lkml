view: id_map {
  derived_table: {
    persist_for: "12 hours"
    sql:
      with i as (
        select
          user_id,
          cp_id,
          timestamp,
          row_number() over (partition by cp_id order by timestamp) as rn
        from ${identifies.SQL_TABLE_NAME}
        where user_id is not null
          and cp_id is not null
      )
      select *
      from i
      where rn = 1 /* only get the first time each cp_id is associated with a user_id */
    ;;
  }


  #
  # KEYS
  #

  dimension: cp_id {
    type: string
    primary_key: yes
    sql: ${TABLE}.cp_id ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }


  #
  # DIMENSIONS
  #

  dimension_group: first_identify {
    type: time
    description: "The time of the first identify call for the given cp_id."
    timeframes: [raw, time, date]
    sql: ${TABLE}.timestamp ;;
  }

}
