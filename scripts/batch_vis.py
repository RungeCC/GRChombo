import yt
import glob
import imageio
from pathlib import Path

# Configuration
var = 'chi'
normal = 'z'
center = [256, 256, 0]
output_dir = Path('../plots')
output_dir.mkdir(exist_ok=True)

# Find all Plot HDF5 files
files = sorted(glob.glob('../output/hdf5/*Plot_*.3d.hdf5'))
print(f'Found {len(files)} files')

# Generate PNGs
png_files = []
for fn in files:
    ds = yt.load(fn)
    suffix = Path(fn).stem.split('_')[1]

    plot = yt.SlicePlot(ds, normal=normal, fields=var, center=center)
    png_path = output_dir / f'{var}_Plot_{suffix}_slice.png'
    plot.save(str(png_path))

    png_files.append(str(png_path.with_suffix('.png')))
    print(f'Generated {png_path.name}')

# Create GIF animation
if png_files:
    images = [imageio.imread(f) for f in png_files]
    imageio.mimsave(output_dir / f'{var}_animation.gif', images, duration=0.2)
    print(f'Created animation: {var}_animation.gif')
