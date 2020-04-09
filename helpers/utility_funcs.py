#!/usr/bin/env python
# coding: utf-8

# In[12]:


import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
import random


# In[6]:


# Generate 9 folds with random pairs of patients for cross validation
def get_folds(data):
    keynames = list(data.keys()) # get the key names that represent individual patients
    random.shuffle(keynames) # shuffle them into a random order
    folds = np.reshape(keynames, [9,2]) # pair them off into 9 folds
    return folds


# In[7]:


## intakes training and test predictors, then scales them all down to be 0 mean and 1 variance (according to what is observed in training set)

def scale_data(xtrain,xtest):
    scaler = StandardScaler() # generate scaler
    xtrain.loc[:,:] = scaler.fit_transform(xtrain) # fit and transform on training
    xtest.loc[:,:] = scaler.transform(xtest) # naively transform test data without fitting to it
    return xtrain, xtest, scaler


# In[8]:


### takes in the by patient data and the folds by which to seperate, outputs training features/labels and testing features/labels for the current fold being tested 
def get_train_test(data,folds,current_fold):
    ## get the test data
    
    # extract patients in current fold for testing
    test_data1 = data[folds[current_fold,0]]
    test_data2 = data[folds[current_fold,1]]
    # combine into one testing df
    test_data = pd.concat([test_data1,test_data2],ignore_index=True)
    # split into predictors and labels
    test_y = test_data['BG_PH']
    test_x = test_data.drop(columns=['BG_PH'])
    
    
    ## extract patients not in current fold for training
    
    # drop the testing fold and flatten the patient array for iteration
    train_pats = np.delete(folds,current_fold,axis=0).flatten()
    train_data = pd.DataFrame() # holder df for training data
    # combine into one training df
    for pat in train_pats:
        train_data = pd.concat([train_data,data[pat]], ignore_index=True)
    train_y = train_data['BG_PH']
    train_x = train_data.drop(columns=['BG_PH'])
    
    train_x, test_x, scaler = scale_data(train_x,test_x)
    
    return test_y, test_x, train_y, train_x, scaler


# In[9]:


def get_RMSE(actual,predicted):
    return np.sqrt(np.mean((actual-predicted)**2))


# In[13]:


def PCA_transform(train_x, test_x):
    train_x, test_x, __ = scale_data(train_x, test_x)
    pca = PCA() # full PCA with no automatic truncation
    train_pca = pca.fit_transform(train_x) # fit the pca and transform the training values
    test_pca = pca.transform(test_x) # transform the test data without looking at it fr adjusting pca
    print(train_x.head())
    return train_pca, test_pca, pca.explained_variance_ratio_


# In[ ]:




