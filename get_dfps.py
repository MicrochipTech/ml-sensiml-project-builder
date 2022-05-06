'''
Grab the latest DFPs from the Microchip packs website
'''
#%%
import bs4
import requests as rq
import re
import warnings
import os

#%%
page = rq.get('https://packs.download.microchip.com/')
soup = bs4.BeautifulSoup(page.content, 'html.parser')

#%%
p = re.compile(r'^\s*Microchip ([A-Za-z0-9\-]+) Series Device Support \((\d+\.\d+\.\d+)\)$')
parts = re.compile(r'PIC|dsPIC|XMEGA|AVR|SAM|AT')
for el in soup.find_all('h3', class_='panel-title pull-left'):
    txt = el.get_text().replace(u'\xa0', u' ')
    m = p.search(txt)
    if (m is None) or (parts.match(m.group(1)) is None):
        continue
    name, version = m.groups()

    # print(' '.join(m.groups()))

    if name.startswith('PIC32'):
        bits = 32
    elif name.startswith('SAM'):
        bits = 32
    elif name.startswith('dsPIC'):
        bits = 16
    elif name.startswith('PIC24'):
        bits = 16
    elif name.startswith('PIC'):
        bits = 8
    elif name.startswith('XMEGA'):
        bits = 8
    elif name.startswith('AVR'):
        bits = 8
    elif name.startswith('AT'):
        bits = 8
    else:
        warnings.warn("Unknown platform '%s'" % name)
        bits = -1
        continue

    # print(name, version, bits)
    with open(os.path.join('args', name + '.args'), 'w', newline='\n') as fh:
        varnames = 'DFP_NAME DFP_VERSION XC_NUMBER_BITS'.split()
        varvals = (name + '_DFP', version, str(bits))
        fh.write('\n'.join(
            ['='.join(xy) for xy in zip(varnames, varvals)]
            ))


# %%
