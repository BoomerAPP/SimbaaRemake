/* SIMBAA Fresh v28 — optional, presentation-only motion helpers. */
(() => {
  'use strict';
  try {
    const main = document.querySelector('body:not([data-admin]) main');
    if (!main) return;

    const reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reduceMotion) return;

    main.setAttribute('data-simbaa-motion', '');
    main.setAttribute('data-simbaa-enter', '');

    if (!('IntersectionObserver' in window)) return;

    const revealTargets = main.querySelectorAll(
      ':scope > .section:not([hidden]), :scope > .detail-page-heading, :scope > .contact-card:not([hidden])'
    );
    if (!revealTargets.length) return;

    const observer = new IntersectionObserver((entries, currentObserver) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.classList.add('is-visible');
        currentObserver.unobserve(entry.target);
      });
    }, { threshold: 0.08, rootMargin: '0px 0px -28px 0px' });

    revealTargets.forEach((element) => {
      if (element.hidden || element.hasAttribute('hidden')) return;
      element.classList.add('simbaa-reveal');
      observer.observe(element);
    });

    // Do not leave a section hidden if the page is restored from browser cache.
    window.addEventListener('pageshow', () => {
      revealTargets.forEach((element) => element.classList.add('is-visible'));
    }, { once: true });
  } catch (error) {
    // Motion is decorative; any issue must never affect navigation or checkout.
  }
})();
