// ===== Menu Toggle =====
const menuToggle = document.getElementById('menuToggle');
const nav = document.getElementById('nav');

if (menuToggle && nav) {
    menuToggle.addEventListener('click', () => {
        const isOpen = menuToggle.classList.toggle('active');
        nav.classList.toggle('active');
        menuToggle.setAttribute('aria-expanded', isOpen);
    });

    document.querySelectorAll('.nav-link').forEach(link => {
        link.addEventListener('click', () => {
            menuToggle.classList.remove('active');
            nav.classList.remove('active');
            menuToggle.setAttribute('aria-expanded', 'false');
        });
    });
}

// ===== Smooth Scroll =====
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            const offset = 80;
            const top = target.getBoundingClientRect().top + window.pageYOffset - offset;
            window.scrollTo({ top, behavior: 'smooth' });
        }
    });
});

// ===== Header Scroll =====
const header = document.querySelector('.header');
window.addEventListener('scroll', () => {
    header.classList.toggle('scrolled', window.scrollY > 50);
});

// ===== Counter Animation =====
function animateCounters() {
    document.querySelectorAll('.stat-number').forEach(counter => {
        if (counter.dataset.animated) return;
        const target = +counter.dataset.target;
        const duration = 2000;
        const step = target / (duration / 16);
        let current = 0;

        const update = () => {
            current += step;
            if (current < target) {
                counter.textContent = Math.floor(current);
                requestAnimationFrame(update);
            } else {
                counter.textContent = target;
                counter.dataset.animated = 'true';
            }
        };
        update();
    });
}

// ===== Intersection Observer =====
const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('visible');
            if (entry.target.classList.contains('hero-stats')) {
                animateCounters();
            }
        }
    });
}, { threshold: 0.15, rootMargin: '0px 0px -40px 0px' });

document.querySelectorAll('.service-card, .property-card, .testimonial-card, .highlight, .hero-stats').forEach(el => {
    el.classList.add('fade-up');
    observer.observe(el);
});

// Stagger delays
document.querySelectorAll('.services-grid .service-card').forEach((el, i) => el.style.transitionDelay = `${i * 0.08}s`);
document.querySelectorAll('.properties-grid .property-card').forEach((el, i) => el.style.transitionDelay = `${i * 0.1}s`);
document.querySelectorAll('.testimonials-grid .testimonial-card').forEach((el, i) => el.style.transitionDelay = `${i * 0.1}s`);
document.querySelectorAll('.about-highlights .highlight').forEach((el, i) => el.style.transitionDelay = `${i * 0.1}s`);

// ===== Active Nav Link =====
const sections = document.querySelectorAll('section[id]');
window.addEventListener('scroll', () => {
    const scrollY = window.pageYOffset + 120;
    sections.forEach(section => {
        const top = section.offsetTop;
        const height = section.offsetHeight;
        const id = section.getAttribute('id');
        const link = document.querySelector(`.nav-link[href="#${id}"]`);
        if (link) {
            link.style.color = (scrollY >= top && scrollY < top + height) ? 'var(--gold)' : '';
        }
    });
});

// ===== Contact Form =====
const contactForm = document.getElementById('contactForm');
if (contactForm) {
    contactForm.addEventListener('submit', function (e) {
        e.preventDefault();
        const fd = new FormData(this);
        let msg = `Olá! Vim pelo site da Luar Company Imobiliária.\n\n`;
        msg += `*Nome:* ${fd.get('name')}\n`;
        msg += `*Email:* ${fd.get('email')}\n`;
        if (fd.get('phone')) msg += `*Telefone:* ${fd.get('phone')}\n`;
        msg += `*Assunto:* ${fd.get('subject')}\n`;
        msg += `*Mensagem:* ${fd.get('message')}`;

        window.open(`https://wa.me/244942203497?text=${encodeURIComponent(msg)}`, '_blank');

        const btn = this.querySelector('.btn-submit');
        const original = btn.innerHTML;
        btn.innerHTML = '<i class="fas fa-check"></i> Enviado!';
        btn.style.background = 'var(--green)';
        btn.style.borderColor = 'var(--green)';
        setTimeout(() => {
            btn.innerHTML = original;
            btn.style.background = '';
            btn.style.borderColor = '';
            contactForm.reset();
        }, 3000);
    });
}
