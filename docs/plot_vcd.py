"""Extract this project's Icarus VCD into a static SVG waveform (not a GUI screenshot)."""
from pathlib import Path
import html

source = Path('build/lfsr_wave.vcd')
traces = {key: [] for key in ['"', '%', '#', '!']}
time = 0
for line in source.read_text().splitlines():
    if line.startswith('#'):
        time = int(line[1:]) / 1000  # VCD timescale is 1 ps; plot ns.
    elif line.startswith('b'):
        value, key = line[1:].split()
        if key in traces:
            traces[key].append((time, value.rjust(4, value[0] if value[0] in 'xz' else '0')))
    elif line and line[0] in '01xz' and line[1:] in traces:
        traces[line[1:]].append((time, line[0]))

parts = ['<svg xmlns="http://www.w3.org/2000/svg" width="1120" height="330" viewBox="0 0 1120 330">',
         '<rect width="1120" height="330" fill="#fff"/>',
         '<g font-family="monospace" font-size="14" fill="#17212b">',
         '<text x="20" y="25">Actual Icarus VCD traces: reset and hold (0–80 ns)</text>']
x = lambda t: 130 + t * 12
for t in range(0, 81, 5):
    parts.append(f'<path d="M{x(t)} 45 V285" stroke="#e0e4e8"/><text x="{x(t)-6}" y="310">{t}</text>')
for row, (key, label) in enumerate([('"','clk'),('%','rst'),('#','enable'),('!','lfsr_out')]):
    y = 75 + row*60
    parts.append(f'<text x="15" y="{y+5}">{label}</text>')
    data = [(t,v) for t,v in traces[key] if t <= 80]
    for idx, (t,v) in enumerate(data):
        end = data[idx+1][0] if idx+1<len(data) else 80
        if end <= t:
            continue
        if key == '!':
            parts.append(f'<path d="M{x(t)} {y-12} H{x(end)} M{x(t)} {y+12} H{x(end)} M{x(t)} {y-12} V{y+12}" fill="none" stroke="#156c46"/>')
            parts.append(f'<text x="{(x(t)+x(end))/2}" y="{y+5}" text-anchor="middle">{html.escape(v)}</text>')
        else:
            level = y-12 if v=='1' else y+12
            parts.append(f'<path d="M{x(t)} {level} H{x(end)}" stroke="#235fa4"/>')
            if idx:
                prev = y-12 if data[idx-1][1]=='1' else y+12
                parts.append(f'<path d="M{x(t)} {prev} V{level}" stroke="#235fa4"/>')
parts.append('<text x="1060" y="328">ns</text></g></svg>')
Path('docs/vcd-reset-hold.svg').write_text('\n'.join(parts))
print('Generated docs/vcd-reset-hold.svg directly from build/lfsr_wave.vcd')
for key in traces:
    print(key, [(t,v) for t,v in traces[key] if t<=80])
