#!/usr/bin/env python
# coding: utf-8

# In[1]:


import opendatasets as od


# In[5]:


dataset = 'https://www.kaggle.com/datasets/najir0123/walmart-10k-sales-datasets'


# In[7]:


od.download(dataset)


# In[33]:


import os
import pandas as pd

from sqlalchemy import create_engine
#psql
import psycopg2


# In[9]:


data_dir='walmart-10k-sales-datasets'


# In[10]:


os.listdir(data_dir)


# In[13]:


df=pd.read_csv("walmart-10k-sales-datasets/Walmart.csv")


# In[15]:


df.head()


# In[17]:


df.describe()


# In[18]:


df.info()


# In[19]:


df.duplicated().sum()


# In[22]:


df.drop_duplicates(inplace=True)
df.duplicated().sum()


# In[21]:


df.isnull().sum()


# In[23]:


df.dropna(inplace=True)


# In[24]:


df.isnull().sum()


# In[25]:


df.dtypes


# In[27]:


#erase the $ sugn from unit_price

df['unit_price']=df['unit_price'].str.replace('$','').astype(float)
df.head()


# In[28]:


df.dtypes


# In[29]:


df['Total_amount']=df['unit_price']*df['quantity']


# In[30]:


df.head()


# In[31]:


df.columns = df.columns.str.lower()
df.columns


# In[34]:


df.to_csv('walmart_clean_data.csv', index=False)


# In[41]:


#from sqlalchemy import create_engine

host = 'localhost'
port = 5432
user = 'postgres'
password = 'superuser'  # URL-encoded @ symbol
db_name = 'walmart_db'

# Create the connection engine
engine_psql = create_engine(f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{db_name}")

try:
    # Test the connection
    with engine_psql.connect() as conn:
        print("Connection Successful to PostgreSQL")
except Exception as e:
    print("Unable to connect:", e)


# In[42]:


df.to_sql(name='walmart', con=engine_psql, if_exists='replace', index=False)


# In[ ]:




