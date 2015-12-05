import pandas as pd
import seaborn as sb
import os
import sys

folder = r'C:\Users\Tom\Documents\GitHub\Which-Futures-Data-and-Code\1_Model'
#meta = []
#for i,x in enumerate(os.listdir(folder)):
#    try:
#        meta[i] = pd.read_csv(folder+'//' + x) 
#    except:
#        pass
fileList = ['STG - Total Occupacy 2014.csv','SRC - CLEAN - HSCIC LA-Funded Occupancy 2014.csv','SRC - CLEAN - CHC NHS-funded Occupancy 2014.csv','SRC - CLEAN - ONS Population Projections by Age - 02.csv']
        
TotOcc = pd.read_csv(folder+'//'+'STG - Total Occupacy 2014.csv')
HsicOcc = pd.read_csv(folder+'//'+'SRC - CLEAN - HSCIC LA-Funded Occupancy 2014.csv')
ChcNhsOcc =  pd.read_csv(folder+'//'+'SRC - CLEAN - CHC NHS-funded Occupancy 2014.csv')
PopProj =  pd.read_csv(folder+'//'+'SRC - CLEAN - ONS Population Projections by Age - 02.csv')

ChcNhsOcc['ONS.LA.Code'] = ChcNhsOcc['LA Code']
PopProj['ONS.LA.Code'] = PopProj['ONSLACode']

df = pd.merge(TotOcc,HsicOcc, on = 'ONS.LA.Code')


df = pd.merge(df,ChcNhsOcc, on = 'ONS.LA.Code')#, left_on = 'ONS.LA.Code',right_on ='LA Code')# right_on ='LA Code')
df = pd.merge(df,PopProj, on = 'ONS.LA.Code')#, left_on = 'ONS.LA.Code', right_on = 'LA Code')

df['PopAge85pl_2014'] = df['PopAge85p_2014l']
df.drop('PopAge85p_2014l',axis = 1)
#ratio = df['PopAge6574']/df['PopAge6574_2014']
df['LA.Funded.Occupancy.65-74_Nursing']     = df['65_74_Nursing']*df['PopAge6574']/df['PopAge6574_2014']
df['LA.Funded.Occupancy.65-74_Resi']         = df['65_74_Res']*df['PopAge6574']/df['PopAge6574_2014']

df['LA.Funded.Occupancy.75-84_Nursing']     = df['75_84_Nursing']*df['PopAge7584']/df['PopAge7584_2014']
df['LA.Funded.Occupancy.75-84_Resi']         = df['75_84_Res']*df['PopAge7584']/df['PopAge7584_2014']

df['LA.Funded.Occupancy.85pl_Nursing']         = df['85_pl_Nursing']*df['PopAge85pl']/df['PopAge85pl_2014']
df['LA.Funded.Occupancy.85pl_Resi']         = df['85_pl_Res']*df['PopAge85pl']/df['PopAge85pl_2014']

df['ratio'] = (df['PopAge6574']+df['PopAge7584']+df['PopAge85pl'])/(df['PopAge6574_2014']+df['PopAge7584_2014']+df['PopAge85pl_2014'])

df['Estimated.NHS.Funded.Occupancy'] = df['Sum of number of NHS-funded occupants']*df['ratio']

df['Estimated.Self.Funded.Occupancy'] = df['CQC.HSCA.CareHomeBeds.Occ90'] - (df['65_74_Nursing']+df['65_74_Res'] + df['75_84_Nursing']+ df['75_84_Res'] +df['85_pl_Res']+df['85_pl_Nursing'])- df['Sum of number of NHS-funded occupants']
df['Estimated.Self.Funded.Occupancy'] = df['Estimated.Self.Funded.Occupancy']* df['ratio']


#merge to costs on year and code
costcare = pd.read_csv(folder+ '//'+ r'STG - Projected LA Cost of Care.csv')
#costcare['"HSCICMaster.HSCIC.Year"'] = costcare['"HSCICMaster.HSCIC.Year"'].apply(lambda x: x[:4]) #assume that start year is relevant year
#sys.exit()
df = df.merge(costcare, left_on = ['ONS.LA.Code','Year'] ,right_on = ['"HSCICMaster.ONS.LA.Code"','"HSCICMaster.HSCIC.Year"'])

sys.exit()
##calc more shit
#df['LA.Funded.Occupancy.65-74_Nursing']  =
#df['LA.Funded.Occupancy.65-74_Resi']      = 
#
#df['LA.Funded.Occupancy.75-84_Nursing']    =
#df['LA.Funded.Occupancy.75-84_Resi']        =
#
#df['LA.Funded.Occupancy.85pl_Nursing']      =
#df['LA.Funded.Occupancy.85pl_Resi']   =
#


trgHeaders = pd.read_csv(r'C:\Users\Tom\Documents\GitHub\Which-Futures-Data-and-Code\2_Vis\Data\DUMMY_DATA -- TRG - Projected Occupancy and Costs.csv')
trgheaders = trgHeaders.columns

df[:1]
