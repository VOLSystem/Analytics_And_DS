import pandas as pd
from natsort import natsorted
import numpy as np
import re


# import the data, create a dataframe, create a copy of the dataframe to write cleaned data to
url = 'https://data.sfgov.org/api/views/wr8u-xric/rows.csv'
dates = ['Incident Date', 'Alarm DtTm', 'Arrival DtTm', 'Close DtTm']
fire_incidents = pd.read_csv(url, dtype=dtypes, parse_dates=dates) # parse dates as datetime objects
fi_copy = fire_incidents


# add dtypes for columns so that pandas can run efficiently
dtypes = {'Incident Number': 'Int64', 'Exposure Number': 'Int64', 'ID': 'Int64', 'Address': 'str',
          'Incident Date': 'str',
          'Call Number': 'Int64', 'Alarm DtTm': 'str', 'Arrival DtTm': 'str', 'Close DtTm': 'str', 'City': 'str',
          'zipcode': 'str',
          'Battalion': 'str', 'Station Area': 'str', 'Box': 'str', 'Suppression Units': 'Int64',
          'Suppression Personnel': 'Int64',
          'EMS Units': 'Int64', 'EMS Personnel': 'Int64', 'Other Units': 'Int64', 'Other Personnel': 'Int64',
          'First Unit On Scene': 'str',
          'Estimated Property Loss': 'float64', 'Estimated Contents Loss': 'float64', 'Fire Fatalities': 'Int64',
          'Fire Injuries': 'Int64',
          'Civilian Fatalities': 'Int64', 'Civilian Injuries': 'Int64', 'Number of Alarms': 'Int64',
          'Primary Situation': 'str',
          'Mutual Aid': 'str', 'Action Taken Primary': 'str', 'Action Taken Secondary': 'str',
          'Action Taken Other': 'str',
          'Detector Alerted Occupants': 'str', 'Property Use': 'str', 'Area of Fire Origin': 'str',
          'Ignition Cause': 'str',
          'Ignition Factor Primary': 'str', 'Ignition Factor Secondary': 'str', 'Heat Source': 'str',
          'Item First Ignited': 'str',
          'Human Factors Associated with Ignition': 'str', 'Structure Type': 'str', 'Structure Status': 'str',
          'Floor of Fire Origin': 'str', 'Fire Spread': 'str', 'No Flame Spead': 'str',
          'Number of floors with minimum damage': 'Int64', 'Number of floors with significant damage': 'Int64',
          'Number of floors with heavy damage': 'Int64', 'Number of floors with extreme damage': 'Int64',
          'Detectors Present': 'str',
          'Detector Type': 'str', 'Detector Operation': 'str', 'Detector Effectiveness': 'str',
          'Detector Failure Reason': 'str',
          'Automatic Extinguishing System Present': 'str', 'Automatic Extinguishing Sytem Type': 'str',
          'Automatic Extinguishing Sytem Perfomance': 'str', 'Automatic Extinguishing Sytem Failure Reason': 'str',
          'Number of Sprinkler Heads Operating': 'Int64', 'Supervisor District': 'Int64',
          'neighborhood_district': 'str',
          'point': 'object'}


ignore = ['Incident Date', 'Address','zipcode', 'Alarm DtTm', 'Arrival DtTm', 'Close DtTm', 'point',
'Station Area', 'Box']


#print out unique values for categorical columns; natsorted can sort over all dtypes and properly sort delimited number values
for column in fire_incidents.columns:
    if fire_incidents[f'{column}'].dtype == 'object':
        if f'{column}' not in ignore: #exclude additional irrelevant columns
            entries = natsorted(list(fire_incidents[f'{column}'].unique()))
            print(f'{column} unique entries:\n {entries}')
            # prompt user to avoid excessive output at one time
            keyword = input('Press any key to continue, press q to quit.')
            if keyword == 'q':
                break
            else:
                continue
                

# columns to standardize
standardize = ['Primary Situation', 'Action Taken Primary', 'Action Taken Secondary', 'Action Taken Other', 'Mutual Aid', 
'Detector Alerted Occupants', 'Property Use', 'Area of Fire Origin', 'Ignition Cause', 'Ignition Factor Primary',
'Ignition Factor Secondary', 'Heat Source', 'Item First Ignited', 'Human Factors Associated with Ignition',
'Structure Type', 'Structure Status', 'Fire Spread', 'Detectors Present', 'Detector Type', 'Detector Operation',
'Detector Effectiveness', 'Detector Failure Reason', 'Automatic Extinguishing System Present',
'Automatic Extinguishing Sytem Type', 'Automatic Extinguishing Sytem Perfomance', 'Automatic Extinguishing Sytem Failure Reason']

for entry in standardize:
    entries = natsorted(list(fire_incidents[entry].unique()))
    print(entry, f'unique entries:\n {entries}')
    # prompt user to avoid excessive output at one time
    keyword = input('Press any key to continue, press q to quit.')
    if keyword == 'q':
        break
    else:
        continue

# create patterns for data correction        
hypen_only_pattern = re.compile('-')
space_hyphen_pattern = re.compile(r'^\S+\s-[A-Z].*') #fixes 1 -Open Hallway
any_space_capital_pattern = re.compile(r'^\S+\s[A-Z]') #fixes UU Reason, 4 System
word_word_pattern = re.compile(r'^\w\s\w.*')

# loop through all entries in the column and replace improperly formatted fields in the copied dataframe
for entry in standardize:
    for i in range(0, len(fire_incidents)):
        val = str(fire_incidents.at[i, entry])
        # remove entries that are just hyphens
        if val == '-':
            fi_copy.at[i, entry] = np.NaN
        # if pattern of any # of chars then space then hyphen then character, i.e., 1 -Open Hallway, U -Undetermined, is matched
        elif space_hyphen_pattern.match(val) is not None:   
            fi_copy.at[i, entry] = '- '.join((val).split('-', maxsplit=1)) 
        # if pattern of something space capital is matched, i.e., NN None present
        elif any_space_capital_pattern.match(val) is not None:   
            fi_copy.at[i, entry] = ' - '.join((val).split(' ', maxsplit=1)) 
            
# check to see if changes are correct
for entry in standardize:
    entries = natsorted(list(fi_copy[entry].unique()))
    print(entry, f'unique entries:\n {entries}')
    # prompt user to avoid excessive output at one time
    keyword = input('Press any key to continue, press q to quit.')
    if keyword == 'q':
        break
    else:
        continue
        
        
# rename columns with misspellings, neaten at discretion 
fi_copy.rename(columns={'Automatic Extinguishing Sytem Failure Reason':'Automatic Extinguishing System Failure Reason',
'Automatic Extinguishing Sytem Type':'Automatic Extinguishing System Type',
'Automatic Extinguishing Sytem Perfomance':'Automatic Extinguishing System Perfomance',
'No Flame Spead':'No Flame Spread', 'neighborhood_district':'Neighborhood District'}, inplace=True)

fi_copy.columns
