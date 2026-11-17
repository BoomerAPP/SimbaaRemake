/* One motion controller for static and asynchronously rendered storefront text. */
(() => {
  'use strict';
  const main = document.querySelector('body:not([data-admin]) main');
  if (!main) return;
  const media = matchMedia('(prefers-reduced-motion: reduce)');
  const page = document.body.dataset.page === 'detail' ? 'services' : document.body.dataset.page;
  document.querySelectorAll('[data-nav]').forEach(link => {
    const active = link.dataset.nav === page;
    link.classList.toggle('active', active);
    if (active) link.setAttribute('aria-current', 'page');
    else link.removeAttribute('aria-current');
  });
  main.setAttribute('data-simbaa-motion', '');
  main.setAttribute('data-simbaa-enter', '');
  if (!('IntersectionObserver' in window)) return;
  const selector = 'h1,h2,h3,.eyebrow,.section-subtitle,.home-intro-copy-v8 > p,.about-copy > p,.contact-card > p';
  const seen = new WeakSet();
  const observer = new IntersectionObserver(entries => {
    entries.forEach(({ target, isIntersecting, boundingClientRect }) => {
      if (isIntersecting) target.classList.add('text-visible');
      // Reset only after fully leaving below the viewport, never while reading.
      else if (boundingClientRect.top >= innerHeight) target.classList.remove('text-visible');
    });
  }, { threshold: 0, rootMargin: '0px 0px -24px 0px' });
  function scan() {
    main.querySelectorAll(selector).forEach(el => {
      if (seen.has(el)) return;
      seen.add(el);
      el.classList.add('text-rise');
      observer.observe(el);
    });
  }
  scan();
  new MutationObserver(scan).observe(main, { childList: true, subtree: true });
  // Browser back/forward restoration must never retain a departing state.
  addEventListener('pageshow', () => {
    main.classList.remove('page-departing');
    main.querySelectorAll('.text-rise').forEach(el => {
      const box = el.getBoundingClientRect();
      if (box.top < innerHeight && box.bottom > 0) el.classList.add('text-visible');
    });
  });
  // Native transitions where available; short exit fallback elsewhere.
  document.addEventListener('click', event => {
    const link = event.target.closest('a[href]');
    if (!link || event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey || link.hasAttribute('download') || (link.target && link.target !== '_self') || media.matches) return;
    const url = new URL(link.href, location.href);
    if (url.origin !== location.origin || !/\/(index|layanan|detail|promo|bantuan|tentang)\.html$/.test(url.pathname) || (url.pathname === location.pathname && url.search === location.search)) return;
    if (window.CSS?.supports('navigation', 'auto') || 'onpageswap' in window) return;
    event.preventDefault();
    if (main.classList.contains('page-departing')) return;
    main.classList.add('page-departing');
    setTimeout(() => location.assign(url.href), 140);
  });
})();
