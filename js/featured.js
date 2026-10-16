// ===== Imóveis em Destaque (dinâmico) =====
// Lê as propriedades/terrenos reais do Supabase (chave anon, protegida por RLS)
// e substitui os cartões estáticos. Em caso de erro ou base vazia, mantém os
// cartões estáticos já presentes no HTML (fallback).
(function () {
    'use strict';

    const cfg = window.LUAR_SUPABASE;
    const grid = document.getElementById('propertiesGrid');
    if (!cfg || !grid) return;

    const TYPE_LABELS = {
        house: 'Casa', apartment: 'Apartamento', office: 'Escritório',
        warehouse: 'Armazém', condo: 'Condomínio', shop: 'Loja',
        urban: 'Terreno urbano', rural: 'Terreno rural'
    };

    const headers = {
        apikey: cfg.anonKey,
        Authorization: 'Bearer ' + cfg.anonKey
    };

    function esc(str) {
        return String(str == null ? '' : str)
            .replace(/&/g, '&amp;').replace(/</g, '&lt;')
            .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    function formatPrice(value, isRent) {
        const n = Number(value || 0);
        const formatted = new Intl.NumberFormat('pt-PT', {
            minimumFractionDigits: 0, maximumFractionDigits: 0
        }).format(n);
        const period = isRent ? '<span class="price-period">/mês</span>' : '';
        return 'AOA ' + formatted + period;
    }

    function firstImage(item) {
        const imgs = item.property_images || item.land_images || [];
        const url = imgs.length && imgs[0] && imgs[0].image_url;
        return url || 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=600&h=400&fit=crop';
    }

    function featuresHtml(item) {
        const bits = [];
        if (item.bedrooms > 0) bits.push('<span><i class="fas fa-bed"></i> ' + item.bedrooms + ' quartos</span>');
        if (item.bathrooms > 0) bits.push('<span><i class="fas fa-bath"></i> ' + item.bathrooms + ' casas de banho</span>');
        if (item.area > 0) bits.push('<span><i class="fas fa-vector-square"></i> ' + Number(item.area).toLocaleString('pt-PT') + ' m²</span>');
        return bits.join('');
    }

    function cardHtml(item) {
        const isRent = item.transaction_type === 'rent';
        const badge = isRent ? 'Arrendamento' : 'Venda';
        const title = esc(item.title);
        const location = esc([item.neighborhood, item.municipality, item.city]
            .filter(Boolean).join(', ') || item.city || 'Angola');
        const wa = 'https://wa.me/' + cfg.whatsapp + '?text=' +
            encodeURIComponent('Olá! Tenho interesse em: ' + item.title);

        return '<div class="property-card">' +
            '<div class="property-badge">' + badge + '</div>' +
            '<div class="property-img"><img src="' + esc(firstImage(item)) +
                '" alt="' + title + '" loading="lazy"></div>' +
            '<div class="property-body">' +
                '<h3>' + title + '</h3>' +
                '<p class="property-location"><i class="fas fa-map-marker-alt"></i> ' + location + '</p>' +
                '<div class="property-features">' + featuresHtml(item) + '</div>' +
                '<div class="property-footer">' +
                    '<span class="property-price">' + formatPrice(item.price, isRent) + '</span>' +
                    '<a href="' + wa + '" class="btn btn-gold btn-sm" target="_blank" rel="noopener">Detalhes</a>' +
                '</div>' +
            '</div></div>';
    }

    function observeCards() {
        const io = new IntersectionObserver((entries) => {
            entries.forEach((e) => {
                if (e.isIntersecting) { e.target.classList.add('visible'); io.unobserve(e.target); }
            });
        }, { threshold: 0.15, rootMargin: '0px 0px -40px 0px' });
        grid.querySelectorAll('.property-card').forEach((el, i) => {
            el.classList.add('fade-up');
            el.style.transitionDelay = (i * 0.1) + 's';
            io.observe(el);
        });
    }

    async function fetchListings(table, imageRelation) {
        const query = 'select=id,title,type,transaction_type,price,area,bedrooms,bathrooms,' +
            'city,municipality,neighborhood,province,is_featured,' + imageRelation + '(image_url)' +
            '&is_available=eq.true&order=is_featured.desc,created_at.desc&limit=8';
        const res = await fetch(cfg.url + '/rest/v1/' + table + '?' + query, { headers });
        if (!res.ok) throw new Error(table + ' HTTP ' + res.status);
        return res.json();
    }

    async function load() {
        try {
            const [props, lands] = await Promise.all([
                fetchListings('properties', 'property_images').catch(() => []),
                fetchListings('lands', 'land_images').catch(() => [])
            ]);

            const all = props.concat(lands)
                .sort((a, b) => (b.is_featured - a.is_featured) ||
                    (new Date(b.created_at || 0) - new Date(a.created_at || 0)))
                .slice(0, 6);

            if (!all.length) return; // mantém o fallback estático

            grid.innerHTML = all.map(cardHtml).join('');
            observeCards();
        } catch (err) {
            // Falha de rede/DB: mantém os cartões estáticos.
            console.warn('[Luar] Não foi possível carregar imóveis dinâmicos:', err);
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', load);
    } else {
        load();
    }
})();
