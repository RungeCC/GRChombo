import yt

suffix = '000050'
type = 'Plot'

dfn = f'../output/hdf5/BinaryBH{type}_{suffix}.3d.hdf5'
ds = yt.load(dfn)

print(f'Available fields: {ds.field_list}')
print(f'Derived fields: {ds.derived_field_list}')

normal = 'z'
var = 'Weyl4_Re'
center = [256, 256, 0]

plot = yt.SlicePlot(ds, normal=normal, fields=var, center=center)

plot.save(f'../plots/{var[1] if isinstance(var, tuple) else var}_{type}_{suffix}_slice.png')