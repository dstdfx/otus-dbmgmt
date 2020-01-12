# Start

```sh
docker-compose up otusdb
```

# Connect

```sh
docker-compose exec otusdb mysql -u root -p12345 otusdb
```

# Stop

```sh
docker-compose down -v --remove-orphans
```

## Analyze and profiling

Primary query, shows product with max and min price for each category:
```sql
select
    bin_to_uuid(c.id) as category_id,
    bin_to_uuid((
        select
            p.id
        from products as p
            inner join provider_products as pp on pp.product_id = p.id
            inner join prices as pr on pr.id = pp.price_id
        where c.id = p.category_id
        group by p.id
        order by max(pr.amount) DESC
        limit 1
        )) as most_exp,
    (
        select
            max(pr.amount)
        from products as p
            inner join provider_products as pp on pp.product_id = p.id
            inner join prices as pr on pr.id = pp.price_id
        where c.id = p.category_id
        group by p.id
        order by max(pr.amount) DESC
        limit 1
    ) as most_exp_price,
    bin_to_uuid((
        select
            p.id
        from products as p
            inner join provider_products as pp on pp.product_id = p.id
            inner join prices as pr on pr.id = pp.price_id
        where c.id = p.category_id
        group by p.id
        order by min(pr.amount)
        limit 1
    )) as most_cheap,
    (
        select
            min(pr.amount)
        from products as p
            inner join provider_products as pp on pp.product_id = p.id
            inner join prices as pr on pr.id = pp.price_id
        where c.id = p.category_id
        group by p.id
        order by min(pr.amount)
        limit 1
    ) as most_cheap_price
from categories as c
having most_exp is not null and most_cheap is not null;
```

Explain with default format:
```sql
*************************** 1. row ***************************
           id: 1
  select_type: PRIMARY
        table: c
   partitions: NULL
         type: index
possible_keys: NULL
          key: idx_categories_parent_id
      key_len: 17
          ref: NULL
         rows: 4
     filtered: 100.00
        Extra: Using index
*************************** 2. row ***************************
           id: 5
  select_type: DEPENDENT SUBQUERY
        table: p
   partitions: NULL
         type: ref
possible_keys: PRIMARY,idx_products_created_at,idx_products_category_id,idx_products_brand_id
          key: idx_products_category_id
      key_len: 16
          ref: otusdb.c.id
         rows: 1
     filtered: 100.00
        Extra: Using index; Using temporary; Using filesort
*************************** 3. row ***************************
           id: 5
  select_type: DEPENDENT SUBQUERY
        table: pp
   partitions: NULL
         type: ref
possible_keys: idx_provider_products_product_id_provider_id,idx_provider_products_price_id
          key: idx_provider_products_product_id_provider_id
      key_len: 16
          ref: otusdb.p.id
         rows: 1
     filtered: 100.00
        Extra: NULL
*************************** 4. row ***************************
           id: 5
  select_type: DEPENDENT SUBQUERY
        table: pr
   partitions: NULL
         type: eq_ref
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 16
          ref: otusdb.pp.price_id
         rows: 1
     filtered: 100.00
        Extra: NULL
*************************** 5. row ***************************
           id: 4
  select_type: DEPENDENT SUBQUERY
        table: p
   partitions: NULL
         type: ref
possible_keys: PRIMARY,idx_products_created_at,idx_products_category_id,idx_products_brand_id
          key: idx_products_category_id
      key_len: 16
          ref: otusdb.c.id
         rows: 1
     filtered: 100.00
        Extra: Using index; Using temporary; Using filesort
*************************** 6. row ***************************
           id: 4
  select_type: DEPENDENT SUBQUERY
        table: pp
   partitions: NULL
         type: ref
possible_keys: idx_provider_products_product_id_provider_id,idx_provider_products_price_id
          key: idx_provider_products_product_id_provider_id
      key_len: 16
          ref: otusdb.p.id
         rows: 1
     filtered: 100.00
        Extra: NULL
*************************** 7. row ***************************
           id: 4
  select_type: DEPENDENT SUBQUERY
        table: pr
   partitions: NULL
         type: eq_ref
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 16
          ref: otusdb.pp.price_id
         rows: 1
     filtered: 100.00
        Extra: NULL
*************************** 8. row ***************************
           id: 3
  select_type: DEPENDENT SUBQUERY
        table: p
   partitions: NULL
         type: ref
possible_keys: PRIMARY,idx_products_created_at,idx_products_category_id,idx_products_brand_id
          key: idx_products_category_id
      key_len: 16
          ref: otusdb.c.id
         rows: 1
     filtered: 100.00
        Extra: Using index; Using temporary; Using filesort
*************************** 9. row ***************************
           id: 3
  select_type: DEPENDENT SUBQUERY
        table: pp
   partitions: NULL
         type: ref
possible_keys: idx_provider_products_product_id_provider_id,idx_provider_products_price_id
          key: idx_provider_products_product_id_provider_id
      key_len: 16
          ref: otusdb.p.id
         rows: 1
     filtered: 100.00
        Extra: NULL
*************************** 10. row ***************************
           id: 3
  select_type: DEPENDENT SUBQUERY
        table: pr
   partitions: NULL
         type: eq_ref
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 16
          ref: otusdb.pp.price_id
         rows: 1
     filtered: 100.00
        Extra: NULL
*************************** 11. row ***************************
           id: 2
  select_type: DEPENDENT SUBQUERY
        table: p
   partitions: NULL
         type: ref
possible_keys: PRIMARY,idx_products_created_at,idx_products_category_id,idx_products_brand_id
          key: idx_products_category_id
      key_len: 16
          ref: otusdb.c.id
         rows: 1
     filtered: 100.00
        Extra: Using index; Using temporary; Using filesort
*************************** 12. row ***************************
           id: 2
  select_type: DEPENDENT SUBQUERY
        table: pp
   partitions: NULL
         type: ref
possible_keys: idx_provider_products_product_id_provider_id,idx_provider_products_price_id
          key: idx_provider_products_product_id_provider_id
      key_len: 16
          ref: otusdb.p.id
         rows: 1
     filtered: 100.00
        Extra: NULL
*************************** 13. row ***************************
           id: 2
  select_type: DEPENDENT SUBQUERY
        table: pr
   partitions: NULL
         type: eq_ref
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 16
          ref: otusdb.pp.price_id
         rows: 1
     filtered: 100.00
        Extra: NULL
13 rows in set, 5 warnings (0.00 sec)
```

Explain tree format:
```sql
*************************** 1. row ***************************
EXPLAIN: -> Filter: ((most_exp is not null) and (most_cheap is not null))
    -> Index scan on c using idx_categories_parent_id  (cost=0.65 rows=4)
    -> Select #2 (subquery in condition; dependent)
        -> Limit: 1 row(s)
            -> Sort: <temporary>.tmp_field_0 DESC, limit input to 1 row(s) per chunk
                -> Table scan on <temporary>
                    -> Aggregate using temporary table
                        -> Nested loop inner join  (cost=1.05 rows=1)
                            -> Nested loop inner join  (cost=0.70 rows=1)
                                -> Index lookup on p using idx_products_category_id (category_id=c.id)  (cost=0.35 rows=1)
                                -> Index lookup on pp using idx_provider_products_product_id_provider_id (product_id=p.id)  (cost=0.35 rows=1)
                            -> Single-row index lookup on pr using PRIMARY (id=pp.price_id)  (cost=0.35 rows=1)
    -> Select #4 (subquery in condition; dependent)
        -> Limit: 1 row(s)
            -> Sort: <temporary>.tmp_field_0, limit input to 1 row(s) per chunk
                -> Table scan on <temporary>
                    -> Aggregate using temporary table
                        -> Nested loop inner join  (cost=1.05 rows=1)
                            -> Nested loop inner join  (cost=0.70 rows=1)
                                -> Index lookup on p using idx_products_category_id (category_id=c.id)  (cost=0.35 rows=1)
                                -> Index lookup on pp using idx_provider_products_product_id_provider_id (product_id=p.id)  (cost=0.35 rows=1)
                            -> Single-row index lookup on pr using PRIMARY (id=pp.price_id)  (cost=0.35 rows=1)
-> Select #2 (subquery in projection; dependent)
    -> Limit: 1 row(s)
        -> Sort: <temporary>.tmp_field_0 DESC, limit input to 1 row(s) per chunk
            -> Table scan on <temporary>
                -> Aggregate using temporary table
                    -> Nested loop inner join  (cost=1.05 rows=1)
                        -> Nested loop inner join  (cost=0.70 rows=1)
                            -> Index lookup on p using idx_products_category_id (category_id=c.id)  (cost=0.35 rows=1)
                            -> Index lookup on pp using idx_provider_products_product_id_provider_id (product_id=p.id)  (cost=0.35 rows=1)
                        -> Single-row index lookup on pr using PRIMARY (id=pp.price_id)  (cost=0.35 rows=1)
-> Select #3 (subquery in projection; dependent)
    -> Limit: 1 row(s)
        -> Sort: <temporary>.max(pr.amount) DESC, limit input to 1 row(s) per chunk
            -> Table scan on <temporary>
                -> Aggregate using temporary table
                    -> Nested loop inner join  (cost=1.05 rows=1)
                        -> Nested loop inner join  (cost=0.70 rows=1)
                            -> Index lookup on p using idx_products_category_id (category_id=c.id)  (cost=0.35 rows=1)
                            -> Index lookup on pp using idx_provider_products_product_id_provider_id (product_id=p.id)  (cost=0.35 rows=1)
                        -> Single-row index lookup on pr using PRIMARY (id=pp.price_id)  (cost=0.35 rows=1)
-> Select #4 (subquery in projection; dependent)
    -> Limit: 1 row(s)
        -> Sort: <temporary>.tmp_field_0, limit input to 1 row(s) per chunk
            -> Table scan on <temporary>
                -> Aggregate using temporary table
                    -> Nested loop inner join  (cost=1.05 rows=1)
                        -> Nested loop inner join  (cost=0.70 rows=1)
                            -> Index lookup on p using idx_products_category_id (category_id=c.id)  (cost=0.35 rows=1)
                            -> Index lookup on pp using idx_provider_products_product_id_provider_id (product_id=p.id)  (cost=0.35 rows=1)
                        -> Single-row index lookup on pr using PRIMARY (id=pp.price_id)  (cost=0.35 rows=1)
-> Select #5 (subquery in projection; dependent)
    -> Limit: 1 row(s)
        -> Sort: <temporary>.min(pr.amount), limit input to 1 row(s) per chunk
            -> Table scan on <temporary>
                -> Aggregate using temporary table
                    -> Nested loop inner join  (cost=1.05 rows=1)
                        -> Nested loop inner join  (cost=0.70 rows=1)
                            -> Index lookup on p using idx_products_category_id (category_id=c.id)  (cost=0.35 rows=1)
                            -> Index lookup on pp using idx_provider_products_product_id_provider_id (product_id=p.id)  (cost=0.35 rows=1)
                        -> Single-row index lookup on pr using PRIMARY (id=pp.price_id)  (cost=0.35 rows=1)

1 row in set, 4 warnings (0.00 sec)
```

Explain json format:
```sql
*************************** 1. row ***************************
EXPLAIN: {
  "query_block": {
    "select_id": 1,
    "cost_info": {
      "query_cost": "0.65"
    },
    "table": {
      "table_name": "c",
      "access_type": "index",
      "key": "idx_categories_parent_id",
      "used_key_parts": [
        "parent_id"
      ],
      "key_length": "17",
      "rows_examined_per_scan": 4,
      "rows_produced_per_join": 4,
      "filtered": "100.00",
      "using_index": true,
      "cost_info": {
        "read_cost": "0.25",
        "eval_cost": "0.40",
        "prefix_cost": "0.65",
        "data_read_per_join": "4K"
      },
      "used_columns": [
        "id"
      ]
    },
    "select_list_subqueries": [
      {
        "dependent": true,
        "cacheable": false,
        "query_block": {
          "select_id": 5,
          "cost_info": {
            "query_cost": "1.05"
          },
          "ordering_operation": {
            "using_filesort": true,
            "grouping_operation": {
              "using_temporary_table": true,
              "using_filesort": false,
              "nested_loop": [
                {
                  "table": {
                    "table_name": "p",
                    "access_type": "ref",
                    "possible_keys": [
                      "PRIMARY",
                      "idx_products_created_at",
                      "idx_products_category_id",
                      "idx_products_brand_id"
                    ],
                    "key": "idx_products_category_id",
                    "used_key_parts": [
                      "category_id"
                    ],
                    "key_length": "16",
                    "ref": [
                      "otusdb.c.id"
                    ],
                    "rows_examined_per_scan": 1,
                    "rows_produced_per_join": 1,
                    "filtered": "100.00",
                    "using_index": true,
                    "cost_info": {
                      "read_cost": "0.25",
                      "eval_cost": "0.10",
                      "prefix_cost": "0.35",
                      "data_read_per_join": "1K"
                    },
                    "used_columns": [
                      "id",
                      "category_id"
                    ]
                  }
                },
                {
                  "table": {
                    "table_name": "pp",
                    "access_type": "ref",
                    "possible_keys": [
                      "idx_provider_products_product_id_provider_id",
                      "idx_provider_products_price_id"
                    ],
                    "key": "idx_provider_products_product_id_provider_id",
                    "used_key_parts": [
                      "product_id"
                    ],
                    "key_length": "16",
                    "ref": [
                      "otusdb.p.id"
                    ],
                    "rows_examined_per_scan": 1,
                    "rows_produced_per_join": 1,
                    "filtered": "100.00",
                    "cost_info": {
                      "read_cost": "0.25",
                      "eval_cost": "0.10",
                      "prefix_cost": "0.70",
                      "data_read_per_join": "88"
                    },
                    "used_columns": [
                      "id",
                      "product_id",
                      "price_id"
                    ]
                  }
                },
                {
                  "table": {
                    "table_name": "pr",
                    "access_type": "eq_ref",
                    "possible_keys": [
                      "PRIMARY"
                    ],
                    "key": "PRIMARY",
                    "used_key_parts": [
                      "id"
                    ],
                    "key_length": "16",
                    "ref": [
                      "otusdb.pp.price_id"
                    ],
                    "rows_examined_per_scan": 1,
                    "rows_produced_per_join": 1,
                    "filtered": "100.00",
                    "cost_info": {
                      "read_cost": "0.25",
                      "eval_cost": "0.10",
                      "prefix_cost": "1.05",
                      "data_read_per_join": "56"
                    },
                    "used_columns": [
                      "id",
                      "amount"
                    ]
                  }
                }
              ]
            }
          }
        }
      },
      {
        "dependent": true,
        "cacheable": false,
        "query_block": {
          "select_id": 4,
          "cost_info": {
            "query_cost": "1.05"
          },
          "ordering_operation": {
            "using_filesort": true,
            "grouping_operation": {
              "using_temporary_table": true,
              "using_filesort": false,
              "nested_loop": [
                {
                  "table": {
                    "table_name": "p",
                    "access_type": "ref",
                    "possible_keys": [
                      "PRIMARY",
                      "idx_products_created_at",
                      "idx_products_category_id",
                      "idx_products_brand_id"
                    ],
                    "key": "idx_products_category_id",
                    "used_key_parts": [
                      "category_id"
                    ],
                    "key_length": "16",
                    "ref": [
                      "otusdb.c.id"
                    ],
                    "rows_examined_per_scan": 1,
                    "rows_produced_per_join": 1,
                    "filtered": "100.00",
                    "using_index": true,
                    "cost_info": {
                      "read_cost": "0.25",
                      "eval_cost": "0.10",
                      "prefix_cost": "0.35",
                      "data_read_per_join": "1K"
                    },
                    "used_columns": [
                      "id",
                      "category_id"
                    ]
                  }
                },
                {
                  "table": {
                    "table_name": "pp",
                    "access_type": "ref",
                    "possible_keys": [
                      "idx_provider_products_product_id_provider_id",
                      "idx_provider_products_price_id"
                    ],
                    "key": "idx_provider_products_product_id_provider_id",
                    "used_key_parts": [
                      "product_id"
                    ],
                    "key_length": "16",
                    "ref": [
                      "otusdb.p.id"
                    ],
                    "rows_examined_per_scan": 1,
                    "rows_produced_per_join": 1,
                    "filtered": "100.00",
                    "cost_info": {
                      "read_cost": "0.25",
                      "eval_cost": "0.10",
                      "prefix_cost": "0.70",
                      "data_read_per_join": "88"
                    },
                    "used_columns": [
                      "id",
                      "product_id",
                      "price_id"
                    ]
                  }
                },
                {
                  "table": {
                    "table_name": "pr",
                    "access_type": "eq_ref",
                    "possible_keys": [
                      "PRIMARY"
                    ],
                    "key": "PRIMARY",
                    "used_key_parts": [
                      "id"
                    ],
                    "key_length": "16",
                    "ref": [
                      "otusdb.pp.price_id"
                    ],
                    "rows_examined_per_scan": 1,
                    "rows_produced_per_join": 1,
                    "filtered": "100.00",
                    "cost_info": {
                      "read_cost": "0.25",
                      "eval_cost": "0.10",
                      "prefix_cost": "1.05",
                      "data_read_per_join": "56"
                    },
                    "used_columns": [
                      "id",
                      "amount"
                    ]
                  }
                }
              ]
            }
          }
        }
      },
      {
        "dependent": true,
        "cacheable": false,
        "query_block": {
          "select_id": 3,
          "cost_info": {
            "query_cost": "1.05"
          },
          "ordering_operation": {
            "using_filesort": true,
            "grouping_operation": {
              "using_temporary_table": true,
              "using_filesort": false,
              "nested_loop": [
                {
                  "table": {
                    "table_name": "p",
                    "access_type": "ref",
                    "possible_keys": [
                      "PRIMARY",
                      "idx_products_created_at",
                      "idx_products_category_id",
                      "idx_products_brand_id"
                    ],
                    "key": "idx_products_category_id",
                    "used_key_parts": [
                      "category_id"
                    ],
                    "key_length": "16",
                    "ref": [
                      "otusdb.c.id"
                    ],
                    "rows_examined_per_scan": 1,
                    "rows_produced_per_join": 1,
                    "filtered": "100.00",
                    "using_index": true,
                    "cost_info": {
                      "read_cost": "0.25",
                      "eval_cost": "0.10",
                      "prefix_cost": "0.35",
                      "data_read_per_join": "1K"
                    },
                    "used_columns": [
                      "id",
                      "category_id"
                    ]
                  }
                },
                {
                  "table": {
                    "table_name": "pp",
                    "access_type": "ref",
                    "possible_keys": [
                      "idx_provider_products_product_id_provider_id",
                      "idx_provider_products_price_id"
                    ],
                    "key": "idx_provider_products_product_id_provider_id",
                    "used_key_parts": [
                      "product_id"
                    ],
                    "key_length": "16",
                    "ref": [
                      "otusdb.p.id"
                    ],
                    "rows_examined_per_scan": 1,
                    "rows_produced_per_join": 1,
                    "filtered": "100.00",
                    "cost_info": {
                      "read_cost": "0.25",
                      "eval_cost": "0.10",
                      "prefix_cost": "0.70",
                      "data_read_per_join": "88"
                    },
                    "used_columns": [
                      "id",
                      "product_id",
                      "price_id"
                    ]
                  }
                },
                {
                  "table": {
                    "table_name": "pr",
                    "access_type": "eq_ref",
                    "possible_keys": [
                      "PRIMARY"
                    ],
                    "key": "PRIMARY",
                    "used_key_parts": [
                      "id"
                    ],
                    "key_length": "16",
                    "ref": [
                      "otusdb.pp.price_id"
                    ],
                    "rows_examined_per_scan": 1,
                    "rows_produced_per_join": 1,
                    "filtered": "100.00",
                    "cost_info": {
                      "read_cost": "0.25",
                      "eval_cost": "0.10",
                      "prefix_cost": "1.05",
                      "data_read_per_join": "56"
                    },
                    "used_columns": [
                      "id",
                      "amount"
                    ]
                  }
                }
              ]
            }
          }
        }
      },
      {
        "dependent": true,
        "cacheable": false,
        "query_block": {
          "select_id": 2,
          "cost_info": {
            "query_cost": "1.05"
          },
          "ordering_operation": {
            "using_filesort": true,
            "grouping_operation": {
              "using_temporary_table": true,
              "using_filesort": false,
              "nested_loop": [
                {
                  "table": {
                    "table_name": "p",
                    "access_type": "ref",
                    "possible_keys": [
                      "PRIMARY",
                      "idx_products_created_at",
                      "idx_products_category_id",
                      "idx_products_brand_id"
                    ],
                    "key": "idx_products_category_id",
                    "used_key_parts": [
                      "category_id"
                    ],
                    "key_length": "16",
                    "ref": [
                      "otusdb.c.id"
                    ],
                    "rows_examined_per_scan": 1,
                    "rows_produced_per_join": 1,
                    "filtered": "100.00",
                    "using_index": true,
                    "cost_info": {
                      "read_cost": "0.25",
                      "eval_cost": "0.10",
                      "prefix_cost": "0.35",
                      "data_read_per_join": "1K"
                    },
                    "used_columns": [
                      "id",
                      "category_id"
                    ]
                  }
                },
                {
                  "table": {
                    "table_name": "pp",
                    "access_type": "ref",
                    "possible_keys": [
                      "idx_provider_products_product_id_provider_id",
                      "idx_provider_products_price_id"
                    ],
                    "key": "idx_provider_products_product_id_provider_id",
                    "used_key_parts": [
                      "product_id"
                    ],
                    "key_length": "16",
                    "ref": [
                      "otusdb.p.id"
                    ],
                    "rows_examined_per_scan": 1,
                    "rows_produced_per_join": 1,
                    "filtered": "100.00",
                    "cost_info": {
                      "read_cost": "0.25",
                      "eval_cost": "0.10",
                      "prefix_cost": "0.70",
                      "data_read_per_join": "88"
                    },
                    "used_columns": [
                      "id",
                      "product_id",
                      "price_id"
                    ]
                  }
                },
                {
                  "table": {
                    "table_name": "pr",
                    "access_type": "eq_ref",
                    "possible_keys": [
                      "PRIMARY"
                    ],
                    "key": "PRIMARY",
                    "used_key_parts": [
                      "id"
                    ],
                    "key_length": "16",
                    "ref": [
                      "otusdb.pp.price_id"
                    ],
                    "rows_examined_per_scan": 1,
                    "rows_produced_per_join": 1,
                    "filtered": "100.00",
                    "cost_info": {
                      "read_cost": "0.25",
                      "eval_cost": "0.10",
                      "prefix_cost": "1.05",
                      "data_read_per_join": "56"
                    },
                    "used_columns": [
                      "id",
                      "amount"
                    ]
                  }
                }
              ]
            }
          }
        }
      }
    ]
  }
}
1 row in set, 5 warnings (0.00 sec)
```

Create histograms:
```sql
mysql> analyze table products update histogram on category_id;
+-----------------+-----------+----------+--------------------------------------------------------+
| Table           | Op        | Msg_type | Msg_text                                               |
+-----------------+-----------+----------+--------------------------------------------------------+
| otusdb.products | histogram | status   | Histogram statistics created for column 'category_id'. |
+-----------------+-----------+----------+--------------------------------------------------------+
1 row in set (0.03 sec)

mysql> analyze table provider_products update histogram on product_id;
+--------------------------+-----------+----------+-------------------------------------------------------+
| Table                    | Op        | Msg_type | Msg_text                                              |
+--------------------------+-----------+----------+-------------------------------------------------------+
| otusdb.provider_products | histogram | status   | Histogram statistics created for column 'product_id'. |
+--------------------------+-----------+----------+-------------------------------------------------------+
1 row in set (0.02 sec)

mysql> analyze table provider_products update histogram on price_id;
+--------------------------+-----------+----------+-----------------------------------------------------+
| Table                    | Op        | Msg_type | Msg_text                                            |
+--------------------------+-----------+----------+-----------------------------------------------------+
| otusdb.provider_products | histogram | status   | Histogram statistics created for column 'price_id'. |
+--------------------------+-----------+----------+-----------------------------------------------------+
1 row in set (0.01 sec)

mysql> analyze table prices update histogram on amount;
+---------------+-----------+----------+---------------------------------------------------+
| Table         | Op        | Msg_type | Msg_text                                          |
+---------------+-----------+----------+---------------------------------------------------+
| otusdb.prices | histogram | status   | Histogram statistics created for column 'amount'. |
+---------------+-----------+----------+---------------------------------------------------+
1 row in set (0.02 sec)
```

Show statistics: 
```sql
mysql> select SCHEMA_NAME, TABLE_NAME, COLUMN_NAME, JSON_PRETTY(HISTOGRAM) from information_schema.column_statistics\G
*************************** 1. row ***************************
           SCHEMA_NAME: otusdb
            TABLE_NAME: products
           COLUMN_NAME: category_id
JSON_PRETTY(HISTOGRAM): {
  "buckets": [
    [
      "base64:type254:bU+1ajPZEeqEFAJCrBUAAg==",
      0.3333333333333333
    ],
    [
      "base64:type254:bU+1wDPZEeqEFAJCrBUAAg==",
      0.6666666666666666
    ],
    [
      "base64:type254:bU+2FTPZEeqEFAJCrBUAAg==",
      1.0
    ]
  ],
  "data-type": "string",
  "null-values": 0.0,
  "collation-id": 63,
  "last-updated": "2020-01-12 15:01:44.902348",
  "sampling-rate": 1.0,
  "histogram-type": "singleton",
  "number-of-buckets-specified": 100
}
*************************** 2. row ***************************
           SCHEMA_NAME: otusdb
            TABLE_NAME: provider_products
           COLUMN_NAME: product_id
JSON_PRETTY(HISTOGRAM): {
  "buckets": [
    [
      "base64:type254:bVFUCTPZEeqEFAJCrBUAAg==",
      0.09523809523809523
    ],
    [
      "base64:type254:bVFUfTPZEeqEFAJCrBUAAg==",
      0.23809523809523808
    ],
    [
      "base64:type254:bVFU4jPZEeqEFAJCrBUAAg==",
      0.3333333333333333
    ],
    [
      "base64:type254:bVFVRDPZEeqEFAJCrBUAAg==",
      0.42857142857142855
    ],
    [
      "base64:type254:bVFVpjPZEeqEFAJCrBUAAg==",
      0.5714285714285714
    ],
    [
      "base64:type254:bVFWCDPZEeqEFAJCrBUAAg==",
      0.6666666666666666
    ],
    [
      "base64:type254:bVFWazPZEeqEFAJCrBUAAg==",
      0.7619047619047619
    ],
    [
      "base64:type254:bVFWzjPZEeqEFAJCrBUAAg==",
      0.9047619047619047
    ],
    [
      "base64:type254:bVFXMTPZEeqEFAJCrBUAAg==",
      0.9999999999999999
    ]
  ],
  "data-type": "string",
  "null-values": 0.0,
  "collation-id": 63,
  "last-updated": "2020-01-12 15:07:36.725682",
  "sampling-rate": 1.0,
  "histogram-type": "singleton",
  "number-of-buckets-specified": 100
}
*************************** 3. row ***************************
           SCHEMA_NAME: otusdb
            TABLE_NAME: provider_products
           COLUMN_NAME: price_id
JSON_PRETTY(HISTOGRAM): {
  "buckets": [
    [
      "base64:type254:bVDo6jPZEeqEFAJCrBUAAg==",
      0.09523809523809523
    ],
    [
      "base64:type254:bVDpUTPZEeqEFAJCrBUAAg==",
      0.2857142857142857
    ],
    [
      "base64:type254:bVDpuDPZEeqEFAJCrBUAAg==",
      0.5714285714285714
    ],
    [
      "base64:type254:bVDqHjPZEeqEFAJCrBUAAg==",
      0.7142857142857142
    ],
    [
      "base64:type254:bVDqhTPZEeqEFAJCrBUAAg==",
      0.9999999999999999
    ]
  ],
  "data-type": "string",
  "null-values": 0.0,
  "collation-id": 63,
  "last-updated": "2020-01-12 15:07:43.063833",
  "sampling-rate": 1.0,
  "histogram-type": "singleton",
  "number-of-buckets-specified": 100
}
*************************** 4. row ***************************
           SCHEMA_NAME: otusdb
            TABLE_NAME: prices
           COLUMN_NAME: amount
JSON_PRETTY(HISTOGRAM): {
  "buckets": [
    [
      350.00,
      0.1
    ],
    [
      375.00,
      0.2
    ],
    [
      1799.00,
      0.30000000000000004
    ],
    [
      2490.80,
      0.4
    ],
    [
      3499.00,
      0.5
    ],
    [
      5499.00,
      0.6
    ],
    [
      5999.00,
      0.7
    ],
    [
      6599.00,
      0.7999999999999999
    ],
    [
      6999.00,
      0.8999999999999999
    ],
    [
      7499.00,
      0.9999999999999999
    ]
  ],
  "data-type": "decimal",
  "null-values": 0.0,
  "collation-id": 8,
  "last-updated": "2020-01-12 15:13:06.820356",
  "sampling-rate": 1.0,
  "histogram-type": "singleton",
  "number-of-buckets-specified": 100
}
4 rows in set (0.00 sec)
```