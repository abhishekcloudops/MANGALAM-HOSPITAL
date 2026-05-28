document.addEventListener('DOMContentLoaded', () => {
    // Inject header and footer from components.js
    const headerPlaceholder = document.getElementById('header-placeholder');
    if (headerPlaceholder && typeof headerHTML !== 'undefined') {
        headerPlaceholder.outerHTML = headerHTML;
    }
    
    const footerPlaceholder = document.getElementById('footer-placeholder');
    if (footerPlaceholder && typeof footerHTML !== 'undefined') {
        footerPlaceholder.outerHTML = footerHTML;
    }

    // Re-initialize Lucide Icons after DOM updates
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }

    // Initialize Header Interactions
    initHeader();

    // Initialize Doctors Filter
    initDoctorsFilter();

    // Initialize OPD Schedule Filter
    initOPDSchedule();

    // Initialize WhatsApp Form
    initWhatsAppForm();
});

function initHeader() {
    const mobileMenuBtn = document.getElementById('mobile-menu-btn');
    const mainNav = document.getElementById('main-nav');
    const header = document.getElementById('header');

    if (mobileMenuBtn && mainNav) {
        mobileMenuBtn.addEventListener('click', () => {
            mainNav.classList.toggle('active');
        });
    }

    // Active Link Switching Based on URL
    const navLinks = document.querySelectorAll('.nav-links a');
    const currentPath = window.location.pathname.split('/').pop() || 'index.html';

    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === currentPath) {
            link.classList.add('active');
        }
    });

    window.addEventListener('scroll', () => {
        // Sticky Header
        if (header) {
            if (window.scrollY > 50) {
                header.classList.add('scrolled');
            } else {
                header.classList.remove('scrolled');
            }
        }
    });

    // Close mobile menu when a link is clicked
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            if (mainNav) {
                mainNav.classList.remove('active');
            }
        });
    });
}

function initDoctorsFilter() {
    const searchInput = document.getElementById('doctor-search');
    const categorySelect = document.getElementById('doctor-category');
    const sortSelect = document.getElementById('doctor-sort');
    const grid = document.querySelector('.doctors-grid');
    
    // Only run if the controls are present on the page
    if (!searchInput || !categorySelect || !sortSelect || !grid) return;

    const cards = Array.from(grid.querySelectorAll('.doctor-card'));
    
    // Store original index for default sorting
    cards.forEach((card, index) => card.dataset.originalIndex = index);

    function filterAndSort() {
        const searchTerm = searchInput.value.toLowerCase();
        const category = categorySelect.value.toLowerCase();
        const sortBy = sortSelect.value;

        // Filter
        let visibleCards = cards.filter(card => {
            const name = card.querySelector('.doctor-name').textContent.toLowerCase();
            const specialty = card.querySelector('.doctor-specialty').textContent.toLowerCase();
            
            const matchesSearch = name.includes(searchTerm) || specialty.includes(searchTerm);
            let matchesCategory = true;
            
            if (category !== 'all') {
                if (category === 'medicine') {
                     matchesCategory = specialty.includes('medicine');
                } else {
                     matchesCategory = specialty.includes(category);
                }
            }
            
            return matchesSearch && matchesCategory;
        });

        // Sort
        if (sortBy === 'az') {
            visibleCards.sort((a, b) => {
                const nameA = a.querySelector('.doctor-name').textContent.replace('Dr. ', '');
                const nameB = b.querySelector('.doctor-name').textContent.replace('Dr. ', '');
                return nameA.localeCompare(nameB);
            });
        } else if (sortBy === 'za') {
            visibleCards.sort((a, b) => {
                const nameA = a.querySelector('.doctor-name').textContent.replace('Dr. ', '');
                const nameB = b.querySelector('.doctor-name').textContent.replace('Dr. ', '');
                return nameB.localeCompare(nameA);
            });
        } else {
            // Default
            visibleCards.sort((a, b) => parseInt(a.dataset.originalIndex) - parseInt(b.dataset.originalIndex));
        }

        // Render
        grid.innerHTML = '';
        if (visibleCards.length > 0) {
            visibleCards.forEach(card => grid.appendChild(card));
        } else {
            grid.innerHTML = '<div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #64748b;">No doctors found matching your criteria.</div>';
        }
    }

    searchInput.addEventListener('input', filterAndSort);
    categorySelect.addEventListener('change', filterAndSort);
    sortSelect.addEventListener('change', filterAndSort);
}

function initWhatsAppForm() {
    const waForm = document.getElementById('whatsapp-form');
    if (waForm) {
        waForm.addEventListener('submit', (e) => {
            e.preventDefault();
            const name = document.getElementById('wa-name').value;
            const phone = document.getElementById('wa-phone').value;
            const service = document.getElementById('wa-service').value;
            const message = document.getElementById('wa-message').value;

            const text = `Hello Mangalam Hospital,\n\nI would like to inquire about your services.\n\n*Name:* ${name}\n*Phone:* ${phone}\n*Service/Department:* ${service}\n*Message:* ${message}\n\n_(Sent from the Mangalam Hospital Website)_`;
            
            const encodedText = encodeURIComponent(text);
            const waNumber = "917033930077"; // Primary contact number for WhatsApp
            const waUrl = `https://wa.me/${waNumber}?text=${encodedText}`;
            
            window.open(waUrl, '_blank');
        });
    }
}

function initOPDSchedule() {
    const searchInput = document.getElementById('opd-search');
    const deptSelect = document.getElementById('opd-dept');
    const grid = document.getElementById('opd-grid');

    if (!searchInput || !deptSelect || !grid) return;

    const cards = Array.from(grid.querySelectorAll('.opd-card'));

    function filterOPD() {
        const searchTerm = searchInput.value.toLowerCase().trim();
        const dept = deptSelect.value;

        cards.forEach(card => {
            const docName = card.dataset.doctor.toLowerCase();
            const docSpecialty = card.dataset.specialty.toLowerCase();

            const matchesSearch = docName.includes(searchTerm) || docSpecialty.includes(searchTerm);
            
            let matchesDept = true;
            if (dept !== 'all') {
                matchesDept = docSpecialty.includes(dept.toLowerCase());
            }

            if (matchesSearch && matchesDept) {
                card.style.display = 'flex';
            } else {
                card.style.display = 'none';
            }
        });

        // Show a "no results" message if no cards are visible
        const visibleCards = cards.filter(card => card.style.display !== 'none');
        const existingNoResults = grid.querySelector('.opd-no-results');
        
        if (visibleCards.length === 0) {
            if (!existingNoResults) {
                const noResults = document.createElement('div');
                noResults.className = 'opd-no-results';
                noResults.style.cssText = 'grid-column: 1 / -1; text-align: center; padding: 40px; color: #64748b; font-weight: 500;';
                noResults.textContent = 'No OPD schedules found matching your criteria.';
                grid.appendChild(noResults);
            }
        } else if (existingNoResults) {
            existingNoResults.remove();
        }
    }

    searchInput.addEventListener('input', filterOPD);
    deptSelect.addEventListener('change', filterOPD);
}

