view: identifies {
  derived_table: {
    persist_for: "12 hours"
    sql:
      with web_i as (
        select id, cp_id, past_cp_id, user_id, timestamp,
          row_number() over (partition by id order by loaded_at desc) as rn,
          'Web' as platform
        from @{segment_web_schema_name}.identifies
      ),
      android_i as (
        select id, cp_id, past_cp_id, user_id, timestamp,
          row_number() over (partition by id order by loaded_at desc) as rn,
          'Android' as platform
        from @{segment_android_schema_name}.identifies
      ),
      ios_i as (
        select id, cp_id, past_cp_id, user_id, timestamp,
          row_number() over (partition by id order by loaded_at desc) as rn,
          'iOS' as platform
        from @{segment_ios_schema_name}.identifies
      )
      select * from web_i where rn = 1
      union all
      select * from ios_i where rn = 1
      union all
      select * from android_i where rn = 1
    ;;
  }


  #
  # KEYS
  #

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: cp_id {
    type: string
    sql: ${TABLE}.cp_id ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }


  #
  # DIMENSIONS
  #

  dimension: data_source {
    type: string
    sql: ${TABLE}.data_source ;;
  }


  dimension_group: timestamp {
    type: time
    description: "Time when the identify call was fired."
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.timestamp ;;
  }


  #
  # MEASURES
  #

  measure: count {
    type: count
  }

}
