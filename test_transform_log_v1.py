from transform_log_v1 import *
from datetime import timedelta 

def test_extract_source_name():
    param1 = json.dumps({'source_name': 'source_value'})
    param2 = '{"schema_name": "schema_value"}' # json.dumps({'schema_name': 'schema_value'})
    param3 = json.dumps({'target_schema_name': 'target_schema_value'})
    param4 = json.dumps({'source_schema_name': 'source_schema_value'})
    param5 = None
    assert extract_source_name(param1) == 'source_value'
    assert extract_source_name(param2) == 'schema_value'
    assert extract_source_name(param3) == 'target_schema_value'
    assert extract_source_name(param4) == 'source_schema_value'

def test_add_minutes():
    original_series = pd.Series(pd.to_datetime([
        '2023-01-01 00:00:00', 
        '2023-01-02 01:00:00', 
        '2023-01-03 02:00:00'
    ]))
    expected_series = pd.Series(pd.to_datetime([
        '2023-01-01 00:00:00', 
        '2023-01-02 01:02:00', 
        '2023-01-03 02:02:00'
    ]))

    result_series = add_minutes(original_series.copy())
    pd.testing.assert_series_equal(result_series, expected_series)

def test_format_duration():
    input1 ={
       2:2,
       1:3,
    #    55:100,
    }
    
    assert format_duration(timedelta(hours=0, minutes=5)) == "5m"
    assert format_duration(timedelta(hours=5, minutes=0)) == "5h"
    for k, v in input1.items():
        assert format_duration(timedelta(hours=int(k), minutes=int(v))) == f"{int(k)}h {int(v)}m"