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
