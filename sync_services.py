with open('services.html', 'r') as f:
    services_content = f.read()

with open('index.html', 'r') as f:
    index_content = f.read()

start_tag = '<div class="services-grid">'
end_tag = '            </div>\n        </div>\n    </section>'

s_start = services_content.find(start_tag)
s_end = services_content.find(end_tag, s_start)

if s_start != -1 and s_end != -1:
    grid_content = services_content[s_start:s_end]
    
    i_start = index_content.find(start_tag)
    i_end = index_content.find(end_tag, i_start)
    
    if i_start != -1 and i_end != -1:
        new_index = index_content[:i_start] + grid_content + index_content[i_end:]
        with open('index.html', 'w') as f:
            f.write(new_index)
        print("Successfully synced services.")
    else:
        print("Could not find grid in index.html")
else:
    print("Could not find grid in services.html")
