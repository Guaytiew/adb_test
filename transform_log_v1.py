
import pandas as pd
import numpy as np
import json

pd.set_option('display.max_colwidth', None)

# df = pd.read_csv('D:/WisdomDEV-DF-01_Pipeline runs 30day.csv') # 'D:/WisdomDEV-DF-01_Pipeline runs1.csv'
def main():
  df = pd.read_csv('C:/Users/Khlang-Thinnarat/Downloads/pipeline_timeline_input.csv')
  df['Pipeline name'].unique()

  keep_col = ['Pipeline name', 'Run start', 'Run end', 'Parameters']
  terminate_pipeline = ['00_Init_Mapping', '00_Init_Migration'] # , '72_create_temp_table', 'fulload_migrate_delta_lake', 'update_delta_query'
  exclude_status = ['In progress']
  df2 = df.loc[~df['Pipeline name'].isin(terminate_pipeline) &
              ~df['Status'].isin(exclude_status),
                keep_col]

  df2['source_name'] = df2['Parameters'].apply(lambda x: extract_source_name(x))
  df2.drop(columns=['Parameters'], inplace=True)

  df2['Run start'] = pd.to_datetime(df2['Run start'], format='%m/%d/%Y, %I:%M:%S %p')
  df2['Run end'] = pd.to_datetime(df2['Run end'], format='%m/%d/%Y, %I:%M:%S %p')
  df2 = df2[(df2['Run start'] >= '2024-06-05 00:00:00') 
            & (df2['Run start'] < '2024-06-14 00:00:00')
            & (df2['Run end'] >= '2024-05-05 00:00:00') 
            & (df2['Run end'] < '2024-06-14 00:00:00') ]


  duration = df2['Run end'].max() - df2['Run start'].min()
  hours, remainder = divmod(duration.total_seconds(), 3600)
  minutes, _ = divmod(remainder, 60)
  print(duration,hours,minutes)
  df2['Overall duration'] = f"{int(hours)}h {int(minutes)}m"


  df2_sorted = df2.loc[df2['source_name'] != 'WISDOM'].sort_values(['source_name', 'Pipeline name'])
  df_wd = df2.loc[df2['source_name'] == 'WISDOM'].sort_values(['source_name', 'Pipeline name'])
  df2_sorted['Run end'] = np.where(df2_sorted['source_name'] != df2_sorted['source_name'].shift(-1), df2_sorted['Run end'], df2_sorted.groupby('source_name')['Run start'].shift(-1))

  df2_sorted['Run start'] = df2_sorted.groupby('source_name')['Run start'].transform(add_minutes)
  df2_sorted.reindex(columns=['source_name'])

  df2_sorted['Duration'] = (df2_sorted['Run end'] - df2_sorted['Run start']).apply(format_duration)
  df_wd['Duration'] = (df_wd['Run end'] - df_wd['Run start']).apply(format_duration)
  df_combined = pd.concat([df2_sorted, df_wd], ignore_index=True)

  df_combined['Date parameter'] = df_combined['Run start'].dt.date
  df_combined = df_combined.rename(columns={'source_name': 'Source name', 'Duration': 'Cal duration'})
  df_combined['Type pipeline'] = pd.factorize(df_combined['Pipeline name'])[0]
  this_time = pd.Timestamp.now().strftime("%Y-%m-%d_%H-%M-%S")
  df_combined.to_csv(f'pipeline_runtime_log_{this_time}.csv', index=False)
  df_combined


def extract_source_name(param):
    if isinstance(param, str):
        param_dict = json.loads(param)
        for key in ['source_name', 'schema_name', 'target_schema_name', 'source_schema_name']:
            if key in param_dict:
                return param_dict[key]
    return None

def add_minutes(series):
    series.iloc[1:] = series.iloc[1:]+ pd.Timedelta(minutes=2)
    return series

def format_duration(duration):
    hours, remainder = divmod(duration.total_seconds(), 3600)
    minutes, _ = divmod(remainder, 60)
    if int(hours) == 0 :
      return f"{int(minutes)}m"
    elif int(hours) > 0 and int(minutes) == 0 :
      return f"{int(hours)}h"
    else :
      return f"{int(hours)}h {int(minutes)}m"
  

if __name__ == "__main__":
   main()