import pandas as pd

# Read the dataframe from the text file
df = pd.read_csv('named_groups_1.5_freq_only1stop_wtdbg.txt', sep='\t')

# Create new dataframes based on the conditions
df_scur_0 = df[(df['scurscur'] > 0) & (df['scurviri'] == 0) & (df['scurzebr'] == 0)]
df_viri_0 = df[(df['scurscur'] == 0) & (df['scurviri'] > 0) & (df['scurzebr'] == 0)]
df_zebr_0 = df[(df['scurscur'] == 0) & (df['scurviri'] == 0) & (df['scurzebr'] > 0)]

# Save the new dataframes to text files
df_scur_0.to_csv('scurscur_greater_than_0.txt', sep='\t', index=False)
df_viri_0.to_csv('scurviri_greater_than_0.txt', sep='\t', index=False)
df_zebr_0.to_csv('scurzebr_greater_than_0.txt', sep='\t', index=False)

# Display the new dataframes
print("Dataframe where scurscur > 0 and other columns are 0:")
print(df_scur_0)
print("\nDataframe where scurviri > 0 and other columns are 0:")
print(df_viri_0)
print("\nDataframe where scurzebr > 0 and other columns are 0:")
print(df_zebr_0)
