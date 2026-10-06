import os

directory = 'lib/l10n'
for filename in os.listdir(directory):
    if filename.endswith('.arb'):
        filepath = os.path.join(directory, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        if ' 😍' in content:
            content = content.replace(' 😍', '')
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'Updated {filepath}')
