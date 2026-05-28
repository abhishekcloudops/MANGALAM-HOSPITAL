import re

with open('doctors.html', 'r') as f:
    content = f.read()

start_tag = '<div class="doctors-grid">'
end_tag = '            </div>\n        </div>\n    </section>'

start_idx = content.find(start_tag)
end_idx = content.find(end_tag)

new_grid = '''<div class="doctors-grid">
                <!-- Top / Highlighted Doctors -->
                <div class="doctor-card">
                    <img class="doctor-avatar" src="assets/images/doctors/Dr%20shamsul%20Hoda.jpeg" alt="Dr. Ravi Raman">
                    <h3 class="doctor-name">Dr. Ravi Raman</h3>
                    <p class="doctor-specialty">MD Medicines</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <img class="doctor-avatar" src="assets/images/doctors/Dr%20Ravi%20Raman.jpeg" alt="Dr. Shamsul Huda">
                    <h3 class="doctor-name">Dr. Shamsul Huda</h3>
                    <p class="doctor-specialty">Orthopedic Surgeons</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <img class="doctor-avatar" src="assets/images/doctors/Dr%20mukesh.jpeg" alt="Dr. Mukesh">
                    <h3 class="doctor-name">Dr. Mukesh</h3>
                    <p class="doctor-specialty">Neurosurgeon</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <img class="doctor-avatar" src="assets/images/doctors/Dr%20anil%20orthopedic.jpeg" alt="Dr. Anil">
                    <h3 class="doctor-name">Dr. Anil</h3>
                    <p class="doctor-specialty">Orthopedic</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <img class="doctor-avatar" src="assets/images/doctors/Dr%20ranjeet%20(cardiologist).jpeg" alt="Dr. Ranjit">
                    <h3 class="doctor-name">Dr. Ranjit</h3>
                    <p class="doctor-specialty">Cardiologist</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <img class="doctor-avatar" src="assets/images/doctors/Dr%20athar%20numani.jpeg" alt="Dr. Athar Numani">
                    <h3 class="doctor-name">Dr. Athar Numani</h3>
                    <p class="doctor-specialty">General Surgeon</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <img class="doctor-avatar" src="assets/images/doctors/Dr%20nirmal%20(general%20surgeon).jpeg" alt="Dr. Nirmal">
                    <h3 class="doctor-name">Dr. Nirmal</h3>
                    <p class="doctor-specialty">General Surgeon</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <img class="doctor-avatar" src="assets/images/doctors/Dr%20Astik.jpeg" alt="Dr. Asthik">
                    <h3 class="doctor-name">Dr. Asthik</h3>
                    <p class="doctor-specialty">Gastroenterologist</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>

                <!-- Other Specialists -->
                <div class="doctor-card">
                    <div class="doctor-avatar">A</div>
                    <h3 class="doctor-name">Dr. Anil</h3>
                    <p class="doctor-specialty">Neurosurgeon</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <div class="doctor-avatar">D</div>
                    <h3 class="doctor-name">Dr. Dheeraj</h3>
                    <p class="doctor-specialty">Neurosurgeon</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <div class="doctor-avatar">AR</div>
                    <h3 class="doctor-name">Dr. Abhay Ranjan</h3>
                    <p class="doctor-specialty">Neurosurgeon</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <div class="doctor-avatar">V</div>
                    <h3 class="doctor-name">Dr. Vishmohan</h3>
                    <p class="doctor-specialty">Orthopedic</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <div class="doctor-avatar">A</div>
                    <h3 class="doctor-name">Dr. Ashutosh</h3>
                    <p class="doctor-specialty">Cardiologist</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <div class="doctor-avatar">S</div>
                    <h3 class="doctor-name">Dr. Shahzad</h3>
                    <p class="doctor-specialty">General Surgeon</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <div class="doctor-avatar">Z</div>
                    <h3 class="doctor-name">Dr. Zahra</h3>
                    <p class="doctor-specialty">Gynecologist</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <div class="doctor-avatar">A</div>
                    <h3 class="doctor-name">Dr. Arpit</h3>
                    <p class="doctor-specialty">Pediatrician</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <div class="doctor-avatar">RK</div>
                    <h3 class="doctor-name">Dr. R.A Khan</h3>
                    <p class="doctor-specialty">Nephrologist</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <div class="doctor-avatar">SD</div>
                    <h3 class="doctor-name">Dr. Shashi Dharan</h3>
                    <p class="doctor-specialty">Urologist</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <div class="doctor-avatar">R</div>
                    <h3 class="doctor-name">Dr. Ranjeet</h3>
                    <p class="doctor-specialty">Anaesthetic</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
                <div class="doctor-card">
                    <div class="doctor-avatar">SK</div>
                    <h3 class="doctor-name">Dr. Shashi Kumar</h3>
                    <p class="doctor-specialty">Dentist</p>
                    <button class="btn btn-outline-small w-100">Book Consultation</button>
                </div>
            </div>\n'''

with open('doctors.html', 'w') as f:
    f.write(content[:start_idx] + new_grid + content[end_idx:])
