#!/usr/bin/env python
"""
ROMS native reader
==================================
"""
from datetime import datetime, timedelta
import numpy as np
from opendrift.readers import reader_ROMS_native
from opendrift.models.LO_Drift import LO_Drift

o = LO_Drift(loglevel=20) # debugging info
o.max_speed = 12
#%%
# Creating and adding reader 
LO_native = reader_ROMS_native.Reader(o.test_data_folder() +
     'HoodCanal/HC24_202106_000*.nc')
o.add_reader(LO_native)
o.set_config('general:coastline_action', 'previous')  # land boundary
o.set_config('drift:advection_scheme','runge-kutta4')
o.set_config('drift:vertical_mixing',  True)
o.set_config('vertical_mixing:diffusivitymodel', 'environment')
o.set_config('drift:vertical_advection',  True)
o.set_config('general:use_auto_landmask', False)  # use ROMS landmask
o.set_config('general:seafloor_action', 'previous')  # default: lift_to_seafloor (elements are lifted to sea floor level) 
#o.set_config('drift:horizontal_diffusivity', 0.1) #default=0, add horizontal diffusivity (random walk) 
#o.set_config('processes:dispersion', True)
#o.disable_vertical_motion()
#%%
# Seeding elements on a grid
#lons = np.linspace(-124.9223079, -124.9327348, 100)
#lats = np.linspace(48.5105913, 48.5150912, 100)
#lons, lats = np.meshgrid(lons, lats)
#lon = lons.ravel()
#lat = lats.ravel()
time = LO_native.start_time

import xarray as xr
import numpy as np

fn = './release_2021.06.01_100k_7day.nc'
tracker = xr.open_dataset(fn)
z0 = tracker['z'].values[0,:]
lon = tracker['lon'].values[0,:]
lat = tracker['lat'].values[0,:]

o.seed_elements(lon, lat, radius=0, number=len(lon), z=z0, time=time)
# Running model
o.run(duration=timedelta(days=7),time_step=300,time_step_output=3600, outfile='opendrift_hc.nc',
     export_variables=['lon','lat','z','sea_water_temperature','sea_water_salinity','sea_floor_depth_below_sea_level'])

#%%
# Print and plot results, with lines colored by particle depth
print(o)
#o.plot(linecolor='z', fast=True)
#o.animation()
