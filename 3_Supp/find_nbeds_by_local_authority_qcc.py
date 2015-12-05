import pandas as pd

df = pd.read_csv(r'C:\Users\Tom\Documents\GitHub\Mar2015.csv')

#filter on

#location Type sector == scoial care org 9
#Service user band older people == 85
#Care Home ==y
print len(df)
df = df.copy()[df['Care home?']=='Y']
print len(df)
df = df.copy()[df['Service user band - Older People']=='Y']
print len(df)
df = df.copy()[df['Location Type/Sector']== 'Social Care Org']

df[['Location ID', 'Care homes beds','Local Authority']]
len(df)
df = df[['Care homes beds','Local Authority']]

group =df.groupby(by = 'Local Authority',axis =0 )
sm = group.sum()

print sm
