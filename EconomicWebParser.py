import requests, bs4

#___Current_day________

t=requests.get('https://24timezones.com/world_directory/time_in_london.php')
bt=bs4.BeautifulSoup(t.text, "html.parser")

Toda=bt.select('#currentTime')
Today = Toda[0].getText()
Days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']

d = 0
Current_day = 0
while(d<len(Days)):
    if (Today.find(Days[d])!=-1):
        Current_day = d+2
    d = d+1
Current_day = Current_day-1
#___//_Current_day______

s=requests.get('https://www.dailyfx.com/calendar')

b=bs4.BeautifulSoup(s.text, "html.parser")

tb=b.select('.dfx-calendar-table')
current_table = tb[Current_day]

sg = current_table.select('tr')
sg_l = len(sg)
year = []
month = []
day = []
timme = []

Currency = []
Level = []

Strring = []

x = 1
while(x<(sg_l-1)):
    st = sg[x]
    lets = st.select('td')
    lets_l = len(lets)
    #__Block if_________
    if(lets_l>2):        
        year.append(lets[1].getText()[0:4])
        month.append(lets[1].getText()[5:7])
        day.append(lets[1].getText()[8:10])
        timme.append(lets[1].getText()[11:16])

        Currency.append(lets[3].getText()[5:8])

        Level.append(lets[4].select('span')[0].getText())
    x = x+1

n = 0
while(n<len(Level)):
    nstr = (year[n]+'.'+month[n]+'.'+day[n]+' '+timme[n]+';'+Currency[n]+';'+Level[n])
    Strring.append(nstr)
    n = n+1

f = open('Economic_Calendar.txt', 'w')

indx = 0
while(indx<len(Strring)):
    f.write(Strring[indx] + '\n')
    print(indx+1,Strring[indx])
    indx = indx+1
f.close()
