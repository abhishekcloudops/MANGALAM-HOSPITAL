new_grid = '''<div class="services-grid">
                <!-- Service Card 1 -->
                <div class="service-card">
                    <div class="service-icon"><i data-lucide="activity"></i></div>
                    <h3 class="service-title">Emergency & Critical Care</h3>
                    <p class="service-desc">Providing rapid response and critical care when it matters most.</p>
                    <ul class="service-list">
                        <li>ICU</li>
                        <li>AC Emergency Ward</li>
                        <li>Burn Unit</li>
                        <li>Ambulance Services</li>
                    </ul>
                </div>
                <!-- Service Card 2 -->
                <div class="service-card">
                    <div class="service-icon"><i data-lucide="scissors"></i></div>
                    <h3 class="service-title">Surgical Services</h3>
                    <p class="service-desc">State-of-the-art surgical interventions by expert surgeons.</p>
                    <ul class="service-list">
                        <li>General & Ortho Surgery</li>
                        <li>Neuro & Spinal Surgery</li>
                        <li>Plastic Surgery</li>
                        <li>Laproscopy</li>
                        <li>Ortho Dental Surgery</li>
                    </ul>
                </div>
                <!-- Service Card 3 -->
                <div class="service-card">
                    <div class="service-icon"><i data-lucide="stethoscope"></i></div>
                    <h3 class="service-title">Medical Specialists</h3>
                    <p class="service-desc">Comprehensive diagnosis and treatment of complex diseases.</p>
                    <ul class="service-list">
                        <li>General Medicine</li>
                        <li>Cardiologist</li>
                        <li>Gastroenterologist</li>
                        <li>Nephrologist & Urologist</li>
                        <li>Gynecologist</li>
                    </ul>
                </div>
                <!-- Service Card 4 -->
                <div class="service-card">
                    <div class="service-icon"><i data-lucide="microscope"></i></div>
                    <h3 class="service-title">Diagnostics</h3>
                    <p class="service-desc">Accurate and timely testing utilizing modern laboratory technology.</p>
                    <ul class="service-list">
                        <li>Pathology</li>
                        <li>ECG</li>
                        <li>ECHO</li>
                    </ul>
                </div>
                <!-- Service Card 5 -->
                <div class="service-card">
                    <div class="service-icon"><i data-lucide="bed-double"></i></div>
                    <h3 class="service-title">Accommodations & Care</h3>
                    <p class="service-desc">Comfortable and hygienic stays designed for speedy patient recovery.</p>
                    <ul class="service-list">
                        <li>OPD & IPD</li>
                        <li>AC Room</li>
                        <li>AC General Ward</li>
                        <li>Dialysis</li>
                    </ul>
                </div>
                <!-- Service Card 6 -->
                <div class="service-card special-card">
                    <div class="service-icon"><i data-lucide="heart-handshake"></i></div>
                    <h3 class="service-title">Community Care</h3>
                    <p class="service-desc">Special offers and dedicated medical support for those in need.</p>
                    <ul class="service-list">
                        <li>FREE Saturday OPD</li>
                        <li>FREE Full Body Checkup</li>
                        <li>Special Needy Packages</li>
                        <li>FREE ICU Bed & Room</li>
                    </ul>
                </div>
            </div>'''

def replace_grid(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    start_tag = '<div class="services-grid">'
    end_tag = '            </div>\n        </div>\n    </section>'

    s_start = content.find(start_tag)
    s_end = content.find(end_tag, s_start)

    if s_start != -1 and s_end != -1:
        new_content = content[:s_start] + new_grid + content[s_end:]
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Updated {filepath}")
    else:
        print(f"Could not find grid in {filepath}")

replace_grid('index.html')
replace_grid('services.html')
