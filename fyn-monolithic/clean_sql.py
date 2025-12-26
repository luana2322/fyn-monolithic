
import re

def top_level_split(s):
    res = []
    start = 0
    depth = 0
    for i, c in enumerate(s):
        if c == '(': depth += 1
        elif c == ')': depth -= 1
        elif c == ',' and depth == 0:
            res.append(s[start:i])
            start = i + 1
    res.append(s[start:])
    return [r.strip() for r in res if r.strip()]

def clean_sql(input_file, output_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pre-filtering
    lines = content.splitlines()
    filtered_lines = []
    for line in lines:
        l = line.strip()
        if not l or l.startswith('--') or l.startswith('Owner:') or l.startswith('SET ') or \
           l.startswith('SELECT ') or l.startswith('ALTER SCHEMA') or l.startswith('ALTER TYPE') or \
           l.startswith('ALTER FUNCTION') or l.startswith('COMMENT ON'):
            continue
        filtered_lines.append(line)
        
    content = '\n'.join(filtered_lines)
    
    blocks = content.split(';')
    output = []
    
    for block in blocks:
        clean_block = block.strip()
        if not clean_block: continue
        
        # Keep CREATE TYPE
        if re.search(r'CREATE\s+TYPE\s+.*?\s+AS\s+ENUM', clean_block, re.IGNORECASE | re.DOTALL):
            clean_block = re.sub(r'public\.', '', clean_block)
            output.append(clean_block + ';')
            continue
            
        # Keep CREATE TABLE
        if re.search(r'CREATE\s+TABLE', clean_block, re.IGNORECASE):
            clean_block = re.sub(r'public\.', '', clean_block)
            
            match = re.search(r'CREATE\s+TABLE\s+(.*?)\s*\((.*)\)', clean_block, re.IGNORECASE | re.DOTALL)
            if not match: continue
            
            table_name = match.group(1).strip()
            table_body = match.group(2).strip()
            
            body_lines = top_level_split(table_body)
            new_lines = []
            for line in body_lines:
                # Ignore constraints
                if any(line.upper().startswith(kw) for kw in ['CONSTRAINT', 'CHECK', 'UNIQUE', 'PRIMARY KEY']):
                    continue
                
                parts = line.split()
                if len(parts) < 2: continue
                
                col_name = parts[0]
                # Join the rest and clean up
                rest = ' '.join(parts[1:]).upper()
                
                if 'CHARACTER VARYING' in rest or 'VARCHAR' in rest:
                    col_type = 'VARCHAR(255)'
                elif 'TIMESTAMP' in rest:
                    col_type = 'TIMESTAMP'
                elif 'GEOMETRY' in rest:
                    col_type = 'TEXT'
                elif 'JSON' in rest:
                    col_type = 'JSON'
                elif 'UUID' in rest:
                    col_type = 'UUID'
                elif 'NUMERIC' in rest or 'DECIMAL' in rest or 'DOUBLE' in rest:
                    col_type = 'DECIMAL'
                elif 'BIGINT' in rest:
                    col_type = 'BIGINT'
                elif 'INTEGER' in rest or 'INT' in rest:
                    col_type = 'INT'
                elif 'BOOLEAN' in rest:
                    col_type = 'BOOLEAN'
                elif 'TEXT' in rest:
                    col_type = 'TEXT'
                else:
                    # Fallback to the first word if type is unknown
                    col_type = parts[1].upper()
                
                new_lines.append(f"    {col_name} {col_type}")
            
            new_body = ',\n'.join(new_lines)
            output.append(f"CREATE TABLE {table_name} (\n{new_body}\n);")
            continue
            
        # Keep ALTER TABLE FK
        if re.search(r'ALTER\s+TABLE\s+.*?\s+ADD\s+CONSTRAINT\s+.*?\s+FOREIGN\s+KEY', clean_block, re.IGNORECASE | re.DOTALL):
            clean_block = re.sub(r'public\.', '', clean_block)
            output.append(clean_block + ';')
            continue

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n\n'.join(output))

if __name__ == "__main__":
    clean_sql('fyn_schema.sql', 'fyn_schema_clean.sql')
